import 'dart:io';

import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingSystemAction extends SystemAction {
  static final exits = <bool>[];

  @override
  Future<void> handleExit([bool needSave = true]) async {
    exits.add(needSave);
  }
}

class _TestProfiles extends Profiles {
  _TestProfiles(this._profiles);

  final List<Profile> _profiles;

  @override
  List<Profile> build() => _profiles;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory home;
  late db.Database testDatabase;

  setUpAll(() {
    home = Directory.systemTemp.createTempSync('flclash-store-');
    AppPath.supportDirectory = () async => home;
    AppPath.temporaryDirectory = () async => home;
    AppPath.cacheDirectory = () async => home;
    AppPath.downloadDirectory = () async => home;
  });

  tearDownAll(() {
    if (home.existsSync()) home.deleteSync(recursive: true);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await preferences.setVersion(7);
    testDatabase = db.Database(NativeDatabase.memory());
    db.database = testDatabase;
    _RecordingSystemAction.exits.clear();
    debouncer.cancel(FunctionTag.savePreferences);

    final profilesDir = Directory(await appPath.profilesPath);
    if (profilesDir.existsSync()) profilesDir.deleteSync(recursive: true);
  });

  tearDown(() async {
    await testDatabase.close();
  });

  ProviderContainer buildContainer({List<Profile> profiles = const []}) {
    final container = ProviderContainer(
      overrides: [
        systemActionProvider.overrideWith(_RecordingSystemAction.new),
        profilesProvider.overrideWith(() => _TestProfiles(profiles)),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    return container;
  }

  group('StoreAction.handleClear', () {
    test('empties the preferences it was asked to clear', () async {
      final container = buildContainer();
      expect(await preferences.getVersion(), 7);

      await container.read(storeActionProvider.notifier).handleClear();

      expect(await preferences.getVersion(), 0);
    });

    test('removes the profiles directory', () async {
      final profilesDir = Directory(await appPath.profilesPath)
        ..createSync(recursive: true);
      File(join(profilesDir.path, '3.json')).writeAsStringSync('{}');
      final container = buildContainer();

      await container.read(storeActionProvider.notifier).handleClear();

      expect(profilesDir.existsSync(), isFalse);
    });

    test('exits without asking for a save', () async {
      final container = buildContainer();

      await container.read(storeActionProvider.notifier).handleClear();

      expect(
        _RecordingSystemAction.exits,
        [false],
        reason:
            'saving on the way out would write the config back over the '
            'preferences that were just cleared.',
      );
    });

    test('a pending preference save never lands after the clear', () async {
      final container = buildContainer();
      final action = container.read(storeActionProvider.notifier);

      action.savePreferencesDebounce();
      await action.handleClear();
      await Future<void>.delayed(const Duration(milliseconds: 700));

      expect(
        await preferences.getConfigMap(),
        isNull,
        reason:
            'handleClear cancels the debounced save first; without that the '
            'timer fires afterwards and writes the config straight back into '
            'the preferences that were just cleared.',
      );
    });
  });
}
