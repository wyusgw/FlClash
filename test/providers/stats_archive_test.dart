import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:riverpod/riverpod.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

const _carried = TrafficStats(
  all: Traffic(up: 1000, down: 3000),
  proxy: Traffic(up: 400, down: 1000),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory home;
  late _MockCore core;
  late ProviderContainer container;

  setUpAll(() async {
    home = Directory.systemTemp.createTempSync('stats_archive_test');
    PathProviderPlatform.instance = _FakePathProvider(home.path);
    await appPath.homeDirPath;
  });

  tearDownAll(() => home.deleteSync(recursive: true));

  setUp(() async {
    core = _MockCore();
    final file = File('${home.path}/stats_archive.json');
    if (await file.exists()) await file.delete();
    container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    addTearDown(container.dispose);
    container.listen(appSettingProvider, (_, _) {});
    globalState.container = container;
  });

  CommonAction action() => container.read(commonActionProvider.notifier);

  void run({int minutes = 5, TrafficStats stats = _carried}) {
    container.read(runTimeProvider.notifier).value = Duration(
      minutes: minutes,
    ).inMilliseconds;
    container.read(statsSnapshotProvider.notifier).value = stats;
  }

  void archiveOn() => container
      .read(appSettingProvider.notifier)
      .update((state) => state.copyWith(archiveStats: true));

  group('TrafficStats', () {
    test('the direct part is what no proxy carried', () {
      expect(_carried.direct, const Traffic(up: 600, down: 2000));
    });

    test('a proxy count above the total never makes a negative rest', () {
      const odd = TrafficStats(
        all: Traffic(up: 1, down: 1),
        proxy: Traffic(up: 5, down: 5),
      );

      expect(odd.direct, const Traffic());
    });
  });

  group('StatsRecord', () {
    test('survives a round trip through json', () {
      final record = StatsRecord(
        start: DateTime.fromMillisecondsSinceEpoch(1000),
        end: DateTime.fromMillisecondsSinceEpoch(61000),
        stats: _carried,
      );

      final back = StatsRecord.fromJson(record.toJson());

      expect(back.start, record.start);
      expect(back.duration, const Duration(minutes: 1));
      expect(back.stats, _carried);
    });
  });

  group('archiveSession', () {
    test('keeps nothing while archiving is off', () async {
      run();

      await action().archiveSession();

      expect(await const StatsArchive().load(), isEmpty);
    });

    test('keeps the run that ends, newest first', () async {
      archiveOn();
      run(minutes: 5);
      await action().archiveSession();
      run(minutes: 9);
      await action().archiveSession();

      final records = await const StatsArchive().load();
      expect(records, hasLength(2));
      expect(records.first.duration, const Duration(minutes: 9));
      expect(records.first.stats, _carried);
      expect(container.read(statsRecordsProvider), hasLength(2));
    });

    test('skips a run that carried nothing or never started', () async {
      archiveOn();
      run(stats: const TrafficStats());
      await action().archiveSession();
      container.read(runTimeProvider.notifier).value = null;
      container.read(statsSnapshotProvider.notifier).value = _carried;
      await action().archiveSession();

      expect(await const StatsArchive().load(), isEmpty);
    });

    test('a record can be removed and the rest stays', () async {
      archiveOn();
      run(minutes: 5);
      await action().archiveSession();
      run(minutes: 9);
      await action().archiveSession();
      await action().loadStatsArchive();
      final newest = container.read(statsRecordsProvider).first;

      await action().removeStatsRecords([newest]);

      final records = await const StatsArchive().load();
      expect(records.single.duration, const Duration(minutes: 5));
    });
  });

  test('resetting clears the counters and the shown figures', () {
    when(() => core.resetTraffic()).thenReturn(null);
    run();
    container.read(totalTrafficProvider.notifier).value = const Traffic(
      up: 1,
      down: 1,
    );

    action().resetStatistics();

    verify(() => core.resetTraffic()).called(1);
    expect(container.read(statsSnapshotProvider), const TrafficStats());
    expect(container.read(totalTrafficProvider), const Traffic());
  });
}
