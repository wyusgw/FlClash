import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/views/dashboard/widgets/proxy_groups.dart';
import 'package:fl_clash/views/dashboard/widgets/row_card.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

Group _group(String name, List<String> proxies) => Group(
  type: GroupType.Selector,
  name: name,
  hidden: false,
  all: [for (final proxy in proxies) Proxy(name: proxy, type: 'ss')],
);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.listen(groupsProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  Future<void> pumpCard(WidgetTester tester, {double unitHeight = 80}) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 320,
                child: DashboardWidgetMetrics(
                  unitHeight: unitHeight,
                  child: const ProxyGroupsCard(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Group nodes(int count) => _group(nodeGroupName, [
    for (var index = 0; index < count; index++) 'N$index',
  ]);

  Finder nodeLabel(int index) => find.text('N$index', findRichText: true);

  int shownRows(WidgetTester tester) {
    final bottom = tester.getRect(find.byType(ProxyGroupsCard)).bottom;
    return [
      for (var index = 0; index < 8; index++)
        if (tester.any(nodeLabel(index)) &&
            tester.getRect(nodeLabel(index)).bottom <= bottom)
          index,
    ].length;
  }

  testWidgets('shows an empty state without nodes', (tester) async {
    await pumpCard(tester);

    expect(find.byType(EmptyIllustration), findsOneWidget);
    expect(find.text('No Proxies yet'), findsOneWidget);
  });

  testWidgets('lists the nodes straight away under a plain heading', (
    tester,
  ) async {
    container.read(groupsProvider.notifier).value = [nodes(3)];
    await pumpCard(tester);

    expect(find.text('Proxies'), findsOneWidget);
    expect(find.text(nodeGroupName), findsNothing);
    expect(nodeLabel(0), findsOneWidget);
    expect(nodeLabel(1), findsOneWidget);
  });

  testWidgets('fits more nodes as the card grows taller', (tester) async {
    container.read(groupsProvider.notifier).value = [nodes(8)];

    await pumpCard(tester);
    final compact = shownRows(tester);
    await pumpCard(tester, unitHeight: 120);
    final tall = shownRows(tester);

    expect(compact, greaterThan(1));
    expect(compact, lessThan(8));
    expect(tall, greaterThan(compact));
  });

  testWidgets('row corners stay under a third of the row height', (
    tester,
  ) async {
    container.read(groupsProvider.notifier).value = [nodes(8)];
    for (final unitHeight in [80.0, 120.0]) {
      await pumpCard(tester, unitHeight: unitHeight);
      final pill = find.byType(RowCardPill).first;
      final material = tester.widget<Material>(
        find.descendant(of: pill, matching: find.byType(Material)).first,
      );
      final shape = material.shape! as RoundedSuperellipseBorder;
      final radius = (shape.borderRadius as BorderRadius).topLeft.x;
      expect(radius, greaterThan(0));
      expect(radius, lessThanOrEqualTo(tester.getSize(pill).height / 3));
    }
  });

  testWidgets('scrolls to the nodes below the fold', (tester) async {
    container.read(groupsProvider.notifier).value = [nodes(8)];
    await pumpCard(tester);

    await tester.drag(nodeLabel(0), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(shownRows(tester), greaterThan(0));
    expect(tester.any(nodeLabel(0)), isFalse);
    expect(tester.any(nodeLabel(7)), isTrue);
  });

  testWidgets('nodes settle on rows of a new height', (tester) async {
    container.read(groupsProvider.notifier).value = [nodes(20)];
    await pumpCard(tester);
    final before = tester.widget<ListView>(find.byType(ListView)).itemExtent;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pump();
    final list = find.byType(ListView);
    expect(tester.widget<ListView>(list).itemExtent, isNot(before));

    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(list),
        scrollDelta: const Offset(0, 10),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    final listView = tester.widget<ListView>(list);
    expect(listView.controller!.offset, listView.itemExtent);
  });

  testWidgets('a long node name shows whole through a tooltip', (tester) async {
    const selected = 'VPS-HongKong-Premium-Dedicated-Line-01-Backup-Route';
    container.read(groupsProvider.notifier).value = [
      _group(nodeGroupName, [selected]),
    ];
    await pumpCard(tester);

    expect(
      tester
          .widgetList<Tooltip>(find.byType(Tooltip))
          .map((tooltip) => tooltip.message),
      [selected],
    );
  });
}
