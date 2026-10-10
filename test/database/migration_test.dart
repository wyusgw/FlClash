import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart' as fl;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

const _currentVersion = 11;

Set<String> _tables(Database raw) => {
  for (final row in raw.select(
    "SELECT name FROM sqlite_master WHERE type='table' "
    "AND name NOT LIKE 'sqlite_%'",
  ))
    row['name'] as String,
};

Set<String> _columnsOf(Database raw, String table) => {
  for (final row in raw.select('PRAGMA table_info($table)'))
    row['name'] as String,
};

int _userVersion(Database raw) =>
    raw.select('PRAGMA user_version').single['user_version'] as int;

const _legacyTables = [
  'scripts',
  'rules',
  'profile_rule_mapping',
  'proxy_groups',
  'custom_proxies',
  'clash_providers',
];

/// The shape release 10 left behind: the Clash tables beside `profiles` with
/// its overwrite columns, one of them without a default.
void _createV10(Database raw) {
  raw.execute('''
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
  raw.execute(
    'CREATE TABLE icon_records (url TEXT NOT NULL PRIMARY KEY, '
    'last_accessed INTEGER NOT NULL)',
  );
  for (final table in _legacyTables) {
    raw.execute('CREATE TABLE $table (id INTEGER PRIMARY KEY)');
  }
  raw.execute(
    'INSERT INTO profiles (id, label, url, overwrite_type, '
    'auto_update_duration_millis, auto_update, selected_map, unfold_set, '
    '"order") VALUES (7, \'Kept\', \'https://example.com/sub\', \'custom\', '
    '86400000, 1, \'{"PROXY":"node-a"}\', \'["PROXY"]\', 2)',
  );
  raw.execute('INSERT INTO rules (id) VALUES (1)');
  raw.execute('PRAGMA user_version = 10');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Database raw;

  setUp(() => raw = sqlite3.openInMemory());

  tearDown(() => raw.close());

  Future<fl.Database> open() async {
    final database = fl.Database(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    addTearDown(database.close);
    await database.customSelect('SELECT 1').get();
    return database;
  }

  test(
    'a new database holds the subscriptions and the icon cache only',
    () async {
      await open();

      expect(_tables(raw), {'profiles', 'icon_records'});
      expect(_userVersion(raw), _currentVersion);
    },
  );

  test('the v11 upgrade drops the tables only Clash used', () async {
    _createV10(raw);

    await open();

    expect(_tables(raw), {'profiles', 'icon_records'});
    expect(_userVersion(raw), _currentVersion);
  });

  test('the v11 upgrade keeps every subscription and its choices', () async {
    _createV10(raw);

    final database = await open();

    final profile = (await database.profilesDao.query().get()).single;
    expect(profile.id, 7);
    expect(profile.label, 'Kept');
    expect(profile.url, 'https://example.com/sub');
    expect(profile.autoUpdateDuration, const Duration(days: 1));
    expect(profile.selectedMap, {'PROXY': 'node-a'});
    expect(profile.unfoldSet, {'PROXY'});
    expect(profile.order, 2);
  });

  test('the v11 upgrade removes the overwrite columns from profiles', () async {
    _createV10(raw);

    await open();

    expect(
      _columnsOf(raw, 'profiles'),
      isNot(
        anyOf(
          contains('overwrite_type'),
          contains('script_id'),
          contains('match_target'),
        ),
      ),
    );
  });

  test('a profile can be added after the upgrade', () async {
    _createV10(raw);
    final database = await open();

    final profile = (await database.profilesDao.query().get()).single;
    await database.profiles.put(
      profile.copyWith(id: 8, label: 'Added').toCompanion(),
    );

    expect(await database.profilesDao.query().get(), hasLength(2));
  });

  test(
    'a database from before the schema rebuild is brought up to date',
    () async {
      raw.execute('''
      CREATE TABLE profiles (
        id INTEGER NOT NULL, label TEXT NOT NULL,
        current_group_name TEXT NULL, url TEXT NOT NULL,
        last_update_date INTEGER NULL,
        auto_update_duration_millis INTEGER NOT NULL,
        subscription_info TEXT NULL, auto_update INTEGER NOT NULL,
        selected_map TEXT NOT NULL, unfold_set TEXT NOT NULL,
        "order" INTEGER NULL, PRIMARY KEY (id)
      )
    ''');
      raw.execute(
        'INSERT INTO profiles (id, label, url, auto_update_duration_millis, '
        "auto_update, selected_map, unfold_set) VALUES (1, 'Old', '', 0, 1, "
        "'{}', '[]')",
      );
      raw.execute('PRAGMA user_version = 4');

      final database = await open();

      expect(_tables(raw), {'profiles', 'icon_records'});
      expect((await database.profilesDao.query().get()).single.label, 'Old');
      expect(_userVersion(raw), _currentVersion);
    },
  );

  test('the icon cache survives the upgrade', () async {
    _createV10(raw);
    raw.execute(
      "INSERT INTO icon_records (url, last_accessed) VALUES ('u', 1)",
    );

    final database = await open();

    expect(await database.iconRecordsDao.get('u'), isNotNull);
  });
}
