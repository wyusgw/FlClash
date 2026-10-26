import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/route_state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/data.dart';
import 'package:fl_clash/views/stats.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/test_app.dart';

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

AppLocalizations get l10n => currentAppLocalizations;

void main() {
  late Directory home;
  late ProviderContainer container;
  late _MockCore core;

  setUpAll(() async {
    registerFallbackValue(const OutboundIpParams(timeout: 0));
    home = Directory.systemTemp.createTempSync('stats_view_test');
    PathProviderPlatform.instance = _FakePathProvider(home.path);
    await appPath.homeDirPath;
  });

  tearDownAll(() => home.deleteSync(recursive: true));

  Future<void> pump(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    core = _MockCore();
    when(() => core.resetTraffic()).thenReturn(null);
    when(() => core.outboundIp(any())).thenAnswer((_) async => null);
    container = ProviderContainer(
      overrides: [
        routeTrackerProvider.overrideWithBuild(
          (_, _) => const RouteState(
            coreEpoch: 1,
            picksVersion: 1,
            hostEpoch: 1,
            proxied: true,
            synced: true,
            live: true,
          ),
        ),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    addTearDown(container.dispose);
    container.listen(appSettingProvider, (_, _) {});
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1000, 1400));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the data page lists the statistics', (tester) async {
    await pump(tester, const DataView());

    expect(find.widgetWithText(GroupedRow, 'Statistics'), findsOneWidget);
    await tester.tap(find.text('Statistics'));
    await tester.pumpAndSettle();

    expect(find.byType(StatsView), findsOneWidget);
  });

  testWidgets('without a run it shows dashes and no traffic', (tester) async {
    await pump(tester, const StatsView());

    expect(find.text('—'), findsNWidgets(2));
    expect(find.text('0B'), findsWidgets);
  });

  testWidgets('a run shows when it began, how long, and the split', (
    tester,
  ) async {
    await pump(tester, const StatsView());

    container.read(runTimeProvider.notifier).value = const Duration(
      hours: 5,
      minutes: 58,
      seconds: 20,
    ).inMilliseconds;
    container.read(statsSnapshotProvider.notifier).value = const TrafficStats(
      all: Traffic(up: 2048, down: 4 * 1024 * 1024),
      proxy: Traffic(up: 1024, down: 1024 * 1024),
    );
    await tester.pump();

    expect(find.text('05:58:20'), findsOneWidget);
    expect(find.text('—'), findsNothing);
    expect(find.text('2KB'), findsOneWidget);
    expect(find.text('4MB'), findsWidgets);
    expect(find.text('1KB'), findsWidgets);
    expect(find.text('3MB'), findsWidgets);
  });

  testWidgets('the speed curve shows the rates now and its scale', (
    tester,
  ) async {
    await pump(tester, const StatsView());
    expect(find.byKey(const ValueKey('speed-curve')), findsOneWidget);

    final traffics = container.read(trafficsProvider.notifier);
    traffics.addTraffic(const Traffic(up: 1024, down: 512 * 1024));
    traffics.addTraffic(const Traffic(up: 2048, down: 2 * 1024 * 1024));
    await tester.pump();

    expect(find.text('2MB/s'), findsNWidgets(2));
    expect(find.text('2KB/s'), findsOneWidget);
  });

  testWidgets('the archive switch writes the setting', (tester) async {
    await pump(tester, const StatsView());
    expect(container.read(appSettingProvider).archiveStats, isFalse);

    await tester.tap(find.byType(GroupedSwitch));
    await tester.pump();

    expect(container.read(appSettingProvider).archiveStats, isTrue);
  });

  testWidgets('resetting asks first, then clears the counters', (tester) async {
    await pump(tester, const StatsView());

    await tester.tap(find.byTooltip('Reset statistics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => core.resetTraffic());

    await tester.tap(find.byTooltip('Reset statistics'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(Dialog), matching: find.text('Reset')),
    );
    await tester.pumpAndSettle();
    verify(() => core.resetTraffic()).called(1);
  });

  testWidgets('the archive page says so when it is empty, then lists runs', (
    tester,
  ) async {
    await pump(tester, const ArchiveView());
    expect(find.text('Nothing archived yet'), findsOneWidget);

    container.read(statsRecordsProvider.notifier).value = [
      StatsRecord(
        start: DateTime(2026, 10, 11, 14, 58, 58),
        end: DateTime(2026, 10, 11, 20, 57, 18),
        stats: const TrafficStats(
          all: Traffic(up: 1024, down: 1024),
          proxy: Traffic(up: 512, down: 512),
        ),
      ),
    ];
    await tester.pump();

    expect(find.text('2026-10-11 14:58:58'), findsOneWidget);
    expect(find.textContaining('05:58:20'), findsOneWidget);
    expect(find.text('2KB'), findsOneWidget);
    expect(find.text('Clear archive'), findsOneWidget);
  });
}
