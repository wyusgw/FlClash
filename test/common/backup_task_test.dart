import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/migration.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqlite3/sqlite3.dart';

class _FakePathProvider extends PathProviderPlatform {
  final String root;

  _FakePathProvider(this.root);

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

/// The public entry points hand their work to a background isolate, which
/// cannot reach the mocked platform channels, so the tests drive the worker
/// functions the isolate calls. Those take every path as an argument, so each
/// test runs against its own temporary tree.
void main() {
  late Directory root;

  setUpAll(() async {
    root = Directory.systemTemp.createTempSync('backup_task_test');
    // File.copy does not create parent directories; in production these are the
    // already-existing temp and cache dirs the platform hands out.
    Directory(join(root.path, 'tmp')).createSync(recursive: true);
    Directory(join(root.path, 'archive')).createSync(recursive: true);
    PathProviderPlatform.instance = _FakePathProvider(root.path);
  });

  tearDownAll(() {
    try {
      root.deleteSync(recursive: true);
    } catch (_) {}
  });

  Directory makeDir(String name) =>
      Directory(join(root.path, name, uniqueId))..createSync(recursive: true);

  File writeFile(String path, String content) => File(path)
    ..createSync(recursive: true)
    ..writeAsStringSync(content);

  group('backup and restore', () {
    late Directory home;
    late Directory staging;
    late String databasePath;

    setUp(() async {
      home = makeDir('home');
      staging = makeDir('staging');
      databasePath = join(home.path, 'database.sqlite');
    });

    Future<void> seedDatabase() async {
      final database = db.Database(NativeDatabase(File(databasePath)));
      await database.profilesDao.putAll([
        const Profile(
          id: 1,
          label: 'Backed up',
          autoUpdateDuration: Duration.zero,
        ).toCompanion(),
      ]);
      await database.close();
    }

    Future<String> backup({
      Map<String, Object?> configMap = const {'version': 1},
      List<String>? entries,
    }) async {
      entries ??= BackupEntries.of(profileIds: const [1]);
      final archivePath = join(root.path, 'archive', '$uniqueId.zip');
      await writeBackupArchive(
        archivePath: archivePath,
        configMap: configMap,
        databaseSnapshotPath: databasePath,
        homeDirPath: home.path,
        entries: entries,
      );
      return archivePath;
    }

    Future<String> zipOf(Map<String, List<int>> files) async {
      final archivePath = join(root.path, 'archive', '$uniqueId.zip');
      final encoder = ZipFileEncoder()..create(archivePath);
      for (final MapEntry(:key, :value) in files.entries) {
        encoder.addArchiveFile(ArchiveFile.bytes(key, value));
      }
      await encoder.close();
      return archivePath;
    }

    Future<MigrationData> restore(String archivePath) {
      return readBackupArchive(
        archivePath: archivePath,
        stagingDirPath: staging.path,
      );
    }

    Matcher failsWith(BackupFailure failure) => throwsA(
      isA<BackupException>().having(
        (error) => error.failure,
        'failure',
        failure,
      ),
    );

    test('the archive carries the database, the config and only the listed '
        'files', () async {
      await seedDatabase();
      writeFile(join(home.path, 'profiles', '1.json'), '{"outbounds":[]}');
      writeFile(join(home.path, 'profiles', '9.json'), 'not listed');

      final archivePath = await backup();

      final names = ZipDecoder()
          .decodeStream(InputFileStream(archivePath))
          .files
          .map((file) => file.name)
          .toSet();
      expect(names, {backupDatabaseName, configJsonName, 'profiles/1.json'});
    });

    test('restoring returns the rows and stages the files', () async {
      await seedDatabase();
      writeFile(join(home.path, 'profiles', '1.json'), '{"outbounds":[]}');
      final archivePath = await backup();

      final data = await restore(archivePath);

      expect(data.profiles.single.label, 'Backed up');
      expect(data.configMap?['version'], 1);
      expect(
        BackupEntries.ofData(data).map(
          (entry) => File(
            BackupEntries.resolve(staging.path, entry),
          ).readAsStringSync(),
        ),
        ['{"outbounds":[]}'],
      );
    });

    test(
      'an archive from the Clash era still yields its subscriptions',
      () async {
        final legacy = sqlite3.open(databasePath);
        legacy.execute('''
        CREATE TABLE profiles (
          id INTEGER NOT NULL, label TEXT NOT NULL,
          current_group_name TEXT NULL, url TEXT NOT NULL,
          last_update_date INTEGER NULL, overwrite_type TEXT NOT NULL,
          script_id INTEGER NULL, match_target TEXT NULL,
          auto_update_duration_millis INTEGER NOT NULL,
          subscription_info TEXT NULL, auto_update INTEGER NOT NULL,
          selected_map TEXT NOT NULL, unfold_set TEXT NOT NULL,
          "order" INTEGER NULL, PRIMARY KEY (id)
        )
      ''');
        legacy.execute('CREATE TABLE rules (id INTEGER PRIMARY KEY)');
        legacy.execute(
          'INSERT INTO profiles (id, label, url, overwrite_type, '
          'auto_update_duration_millis, auto_update, selected_map, unfold_set) '
          "VALUES (5, 'Clash era', 'https://example.com/sub', 'standard', 0, 1, "
          "'{}', '[]')",
        );
        legacy.execute('PRAGMA user_version = 10');
        legacy.close();
        final archivePath = await backup(entries: const []);

        final data = await restore(archivePath);

        expect(data.profiles.single.label, 'Clash era');
        expect(data.profiles.single.url, 'https://example.com/sub');
      },
    );

    test(
      'an entry that climbs out of the staging directory is dropped',
      () async {
        final archivePath = await zipOf({
          configJsonName: utf8.encode(json.encode({'version': 1})),
          '../escaped.txt': utf8.encode('outside'),
        });

        await restore(archivePath);

        expect(
          File(join(staging.parent.path, 'escaped.txt')).existsSync(),
          isFalse,
        );
      },
    );

    test('an archive without a config document is rejected', () async {
      final archivePath = await zipOf({'unrelated.txt': utf8.encode('x')});

      await expectLater(restore(archivePath), failsWith(BackupFailure.invalid));
    });

    test('a file that is not a zip archive is rejected', () async {
      final archivePath = writeFile(
        join(root.path, 'archive', '$uniqueId.zip'),
        'not a zip',
      ).path;

      await expectLater(restore(archivePath), failsWith(BackupFailure.invalid));
    });

    test('a config from a newer data version is rejected', () async {
      final archivePath = await zipOf({
        configJsonName: utf8.encode(
          json.encode({'version': Migration.currentVersion + 1}),
        ),
      });

      await expectLater(
        restore(archivePath),
        failsWith(BackupFailure.newerVersion),
      );
    });

    test('a database from a newer schema is rejected', () async {
      await seedDatabase();
      final raw = db.Database(NativeDatabase(File(databasePath)));
      await raw.customStatement(
        'PRAGMA user_version = ${raw.schemaVersion + 1}',
      );
      await raw.close();
      final archivePath = await backup();

      await expectLater(
        restore(archivePath),
        failsWith(BackupFailure.newerVersion),
      );
    });

    test('an archive without a database yields just the config', () async {
      final archivePath = await zipOf({
        configJsonName: utf8.encode(json.encode({'version': 1})),
      });

      final data = await restore(archivePath);

      expect(data.configMap?['version'], 1);
      expect(data.profiles, isEmpty);
    });
  });
}
