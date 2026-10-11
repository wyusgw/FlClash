import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/tab.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

final _tabStateProvider = NotifierProvider<_TabStateNotifier, ProxiesTabState>(
  _TabStateNotifier.new,
);

class _TabStateNotifier extends Notifier<ProxiesTabState> {
  @override
  ProxiesTabState build() => _tabState([_group('B'), _group('C')]);

  void set(ProxiesTabState value) => state = value;
}

void main() {
  late ProviderContainer globalContainer;
  late ProviderSubscription<Profile?> currentProfileSubscription;

  setUp(() {
    final profile = Profile.normal().copyWith(currentGroupName: 'B');
    globalContainer = ProviderContainer(
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentGroupsStateProvider.overrideWithValue(
          GroupsState(value: [_group('A'), _group('B'), _group('C')]),
        ),
        proxiesTabStateProvider.overrideWith(
          (ref) => ref.watch(_tabStateProvider),
        ),
      ],
    );
    globalState.container = globalContainer;
    currentProfileSubscription = globalContainer.listen(
      currentProfileProvider,
      (_, _) {},
    );
  });

  tearDown(() {
    currentProfileSubscription.close();
    globalContainer.dispose();
  });

  Future<GlobalKey<ProxiesTabViewState>> pumpTabView(
    WidgetTester tester,
  ) async {
    final key = GlobalKey<ProxiesTabViewState>();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: globalContainer,
        child: TestApp(
          child: ProxiesTabView(key: key),
          homeBuilder: (child) => Scaffold(body: child),
        ),
      ),
    );
    await tester.pump();
    return key;
  }

  testWidgets('shows the nodes without a tab bar', (tester) async {
    globalContainer
        .read(_tabStateProvider.notifier)
        .set(
          _tabState([
            const Group(
              type: GroupType.Selector,
              name: 'B',
              all: [Proxy(name: 'HK-01', type: 'ss')],
            ),
          ]),
        );
    await pumpTabView(tester);

    expect(find.byType(TabBar), findsNothing);
    expect(find.text('HK-01', findRichText: true), findsOneWidget);
  });

  testWidgets('falls back to the empty state when the nodes go away', (
    tester,
  ) async {
    final key = await pumpTabView(tester);

    globalContainer.read(_tabStateProvider.notifier).set(_tabState([]));
    await tester.pumpAndSettle();

    expect(find.byType(ProxyGroupView), findsNothing);
    expect(key.currentState?.currentGroup, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scroll to selected brings the row to the top of the grid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final group = Group(
      type: GroupType.Selector,
      name: 'B',
      all: [for (var i = 0; i < 80; i++) Proxy(name: 'B-$i', type: 'ss')],
    );
    globalContainer.read(groupsProvider.notifier).value = [group];
    final profile = globalContainer.read(currentProfileProvider)!;
    globalContainer
        .read(profilesProvider.notifier)
        .put(profile.copyWith(selectedMap: {'B': 'B-41'}));
    globalContainer
        .read(_tabStateProvider.notifier)
        .set(_tabState([_group('A'), group]));
    final key = await pumpTabView(tester);
    await tester.pumpAndSettle();
    final firstRowTop = tester
        .getRect(find.text('B-0', findRichText: true).first)
        .top;

    key.currentState?.scrollToGroupSelected();
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.text('B-41', findRichText: true).first).top,
      firstRowTop,
    );
  });
}

ProxiesTabState _tabState(List<Group> groups) {
  return ProxiesTabState(
    groups: groups,
    currentGroupName: 'B',
    proxyCardType: ProxyCardType.expand,
  );
}

Group _group(String name) {
  return Group(type: GroupType.Selector, name: name);
}
