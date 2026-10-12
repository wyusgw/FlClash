import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Profile _profile(int id, {int? order, String? label}) => Profile(
  id: id,
  label: label ?? 'Profile $id',
  autoUpdateDuration: const Duration(hours: 6),
  order: order,
);

void main() {
  late Database database;

  setUp(() => database = Database(NativeDatabase.memory()));

  tearDown(() => database.close());

  test('profiles keep their fields, order and file names', () async {
    final first = _profile(1, order: 1).copyWith(
      currentGroupName: 'PROXY',
      lastUpdateDate: DateTime(2026, 1, 2),
      subscriptionInfo: const SubscriptionInfo(
        upload: 1,
        download: 2,
        total: 3,
        expire: 4,
      ),
      selectedMap: const {'PROXY': 'node-a'},
      unfoldSet: const {'PROXY'},
    );
    await database.profilesDao.putAll([
      first.toCompanion(),
      _profile(2, order: 0).toCompanion(),
    ]);

    final profiles = await database.profilesDao.query().get();
    expect(profiles.map((profile) => profile.id), [2, 1]);
    expect(profiles.last, first);
    expect(await database.profilesDao.fileNames().get(), ['1.json', '2.json']);
    expect(await database.profiles.count.getSingle(), 2);
  });

  test('setAll replaces the list and numbers it in order', () async {
    await database.profilesDao.setAll([_profile(1), _profile(2)]);
    await database.profilesDao.setAll([_profile(3), _profile(1)]);

    final profiles = await database.profilesDao.query().get();
    expect(profiles.map((profile) => profile.id), [3, 1]);
    expect(profiles.map((profile) => profile.order), [0, 1]);
  });

  test('deleteProfile removes only that profile', () async {
    await database.profilesDao.setAll([_profile(1), _profile(2)]);

    await database.deleteProfile(1);

    final profiles = await database.profilesDao.query().get();
    expect(profiles.map((profile) => profile.id), [2]);
    expect(await database.profiles.remove((t) => t.id.equals(2)), 1);
  });

  test('restore merges, and replaces everything when overriding', () async {
    await database.restore(const []);
    expect(await database.profiles.count.getSingle(), 0);

    await database.profilesDao.setAll([_profile(1), _profile(2)]);
    await database.restore([_profile(2, label: 'Restored'), _profile(3)]);
    final merged = await database.profilesDao.query().get();
    expect(merged.map((profile) => profile.id), [1, 2, 3]);
    expect(merged[1].label, 'Restored');

    await database.restore([_profile(9)], isOverride: true);
    final replaced = await database.profilesDao.query().get();
    expect(replaced.map((profile) => profile.id), [9]);
  });

  test('deleteInChunks splits a delete past the bound-value limit', () async {
    final ids = List.generate(1000, (index) => index + 1);
    await database.profilesDao.putAll(
      ids.map((id) => _profile(id).toCompanion()),
    );

    await database.batch((batch) {
      database.profiles.deleteInChunks<int>(
        batch,
        ids,
        (table, chunk) => table.id.isIn(chunk),
      );
    });

    expect(await database.profiles.count.getSingle(), 0);
  });

  test('icon records evict down to their capacity', () async {
    final dao = database.iconRecordsDao;
    for (var index = 0; index <= dao.maxCapacity; index++) {
      await dao.put('https://example.com/$index.png');
    }

    expect(await database.iconRecords.count.getSingle(), dao.maxCapacity);
  });

  test('icon records avoid duplicates and filter queries', () async {
    final dao = database.iconRecordsDao;
    await dao.put('https://example.com/a.png');
    await dao.putIfAbsent('https://example.com/a.png');
    await dao.putIfAbsent('https://other.com/b.png');

    final found = await dao.query('example.com');
    expect(found.map((record) => record.url), ['https://example.com/a.png']);
    expect((await dao.get('https://example.com/a.png'))?.url, isNotNull);
    expect(await dao.get('missing'), isNull);
    expect(await database.iconRecords.count.getSingle(), 2);
  });
}
