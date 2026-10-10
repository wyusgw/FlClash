import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

part 'converter.dart';
part 'generated/database.g.dart';
part 'icons.dart';
part 'profiles.dart';

const _legacyTables = [
  'rules',
  'profile_rule_mapping',
  'proxy_groups',
  'custom_proxies',
  'clash_providers',
  'scripts',
];

@DriftDatabase(
  tables: [Profiles, IconRecords],
  daos: [ProfilesDao, IconRecordsDao],
)
class Database extends _$Database {
  Database([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 11;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final databaseFile = File(await appPath.databasePath);
      return NativeDatabase.createInBackground(databaseFile);
    });
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 11) {
          await _dropLegacyTables();
          await _createIconRecordsIfMissing(m);
          await m.alterTable(TableMigration(profiles));
        }
      },
      beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
    );
  }

  /// Releases that still spoke Clash kept rules, groups, providers and scripts
  /// here; none of them has a meaning for the Xray engine.
  Future<void> _dropLegacyTables() async {
    for (final table in _legacyTables) {
      await customStatement('DROP TABLE IF EXISTS $table');
    }
  }

  Future<void> _createIconRecordsIfMissing(Migrator m) async {
    final tableInfo = await customSelect(
      'PRAGMA table_info(icon_records)',
    ).get();
    if (tableInfo.isEmpty) {
      await m.createTable(iconRecords);
      await m.createIndex(lastAccessedUrl);
    }
  }

  Future<void> restore(
    List<Profile> profiles, {
    bool isOverride = false,
  }) async {
    if (profiles.isEmpty) {
      return;
    }
    await transaction(() async {
      await batch((b) {
        if (isOverride) {
          profilesDao.setAllWithBatch(b, profiles);
          return;
        }
        profilesDao.putAllWithBatch(
          b,
          profiles.map((item) => item.toCompanion()),
        );
      });
    });
  }

  Future<void> deleteProfile(int profileId) {
    return profiles.remove((t) => t.id.equals(profileId));
  }
}

// SQLite builds before 3.32 cap a statement at 999 bound parameters.
const _maxBoundValues = 900;

extension TableInfoExt<Tbl extends Table, Row> on TableInfo<Tbl, Row> {
  void setAll(
    Batch batch,
    Iterable<Insertable<Row>> items, {
    required Expression<bool> Function(Tbl tbl) deleteFilter,
    bool preDelete = false,
  }) async {
    if (preDelete) {
      batch.deleteWhere(this, deleteFilter);
    }
    batch.insertAllOnConflictUpdate(this, items);
    if (!preDelete) {
      batch.deleteWhere(this, deleteFilter);
    }
  }

  void deleteInChunks<V extends Object>(
    Batch batch,
    Iterable<V> values,
    Expression<bool> Function(Tbl tbl, List<V> chunk) filter,
  ) {
    for (final chunk in values.chunks(_maxBoundValues)) {
      batch.deleteWhere(this, (tbl) => filter(tbl, chunk));
    }
  }

  Selectable<int?> get count {
    final countExp = countAll();
    final query = select().addColumns([countExp]);
    return query.map((row) => row.read(countExp));
  }

  Future<int> remove(Expression<bool> Function(Tbl tbl) filter) async {
    return (delete()..where(filter)).go();
  }

  Future<int> put(Insertable<Row> item) async {
    return insertOnConflictUpdate(item);
  }
}

extension SimpleSelectStatementExt<T extends HasResultSet, D>
    on SimpleSelectStatement<T, D> {
  Selectable<int> get count {
    final countExp = countAll();
    final query = addColumns([countExp]);
    return query.map((row) => row.read(countExp)!);
  }
}

extension JoinedSelectStatementExt<T extends HasResultSet, D>
    on JoinedSelectStatement<T, D> {
  Selectable<int> get count {
    final countExp = countAll();
    addColumns([countExp]);
    return map((row) => row.read(countExp)!);
  }
}

Database _database = Database();

Database get database => _database;

@visibleForTesting
set database(Database value) => _database = value;
