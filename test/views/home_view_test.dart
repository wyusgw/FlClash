import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/home/delay_test.dart';
import 'package:fl_clash/views/home/home.dart';
import 'package:fl_clash/views/home/route_mode.dart';
import 'package:fl_clash/views/profiles/edit_server.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod/misc.dart' show Override;

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

Profile _profile({SubscriptionInfo? info, String selected = ''}) => Profile(
  id: 1,
  label: 'My subscription',
  autoUpdateDuration: Duration.zero,
  url: 'https://example.com/sub',
  subscriptionInfo: info,
  selectedMap: selected.isEmpty ? const {} : {nodeGroupName: selected},
);

const _nodes = [
  Proxy(name: '日本 01', type: 'shadowsocks', network: 'tcp'),
  Proxy(name: '香港 02', type: 'vless', network: 'ws'),
];

class _StoredNodeAction extends ProfilesAction {
  _StoredNodeAction(this.outbound);

  final Map<String, dynamic>? outbound;

  @override
  Future<Map<String, dynamic>?> readNodeOutbound(
    Profile profile,
    String tag,
  ) async => outbound;
}

void main() {
  late ProviderContainer container;

  Future<void> pumpHome(
    WidgetTester tester, {
    Profile? profile,
    List<Proxy> nodes = const [],
    Widget page = const HomeView(),
    List<Override> overrides = const [],
  }) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container = ProviderContainer(
      overrides: [
        ...overrides,
        profilesProvider.overrideWith(() => TestProfiles([?profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile?.id),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.listen(appSettingProvider, (_, _) {});
    container.read(viewSizeProvider.notifier).value = const Size(900, 900);
    if (nodes.isNotEmpty) {
      container.read(groupsProvider.notifier).value = [
        Group(type: GroupType.Selector, name: nodeGroupName, all: nodes),
      ];
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: page),
      ),
    );
    await tester.pump();
  }

  testWidgets('without a profile it offers to add one', (tester) async {
    await pumpHome(tester);

    expect(find.text('Add profile'), findsOneWidget);
    expect(find.byType(GroupedSwitch), findsNothing);
  });

  testWidgets('shows the profile, its routing mode and a connectivity row', (
    tester,
  ) async {
    await pumpHome(tester, profile: _profile(), nodes: _nodes);

    expect(find.text('My subscription'), findsOneWidget);
    expect(find.text('Global routing'), findsOneWidget);
    expect(find.text('Rule'), findsOneWidget);
    expect(find.text('Connectivity test'), findsOneWidget);
  });

  Finder switchRow() => find.ancestor(
    of: find.byType(GroupedSwitch),
    matching: find.byType(GroupedRow),
  );

  Future<void> connect(WidgetTester tester) async {
    container.read(runTimeProvider.notifier).value = 1;
    await tester.pump();
  }

  testWidgets('the switch row says not connected until the proxy runs', (
    tester,
  ) async {
    await pumpHome(
      tester,
      profile: _profile(selected: '香港 02'),
      nodes: _nodes,
    );

    expect(
      find.descendant(of: switchRow(), matching: find.text('Not connected')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: switchRow(), matching: find.text('香港 02')),
      findsNothing,
    );
  });

  testWidgets('once connected the switch row names the chosen node', (
    tester,
  ) async {
    await pumpHome(
      tester,
      profile: _profile(selected: '香港 02'),
      nodes: _nodes,
    );
    await connect(tester);

    expect(
      find.descendant(of: switchRow(), matching: find.text('香港 02')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: switchRow(), matching: find.text('Not connected')),
      findsNothing,
    );
    expect(
      find.descendant(of: switchRow(), matching: find.text('My subscription')),
      findsNothing,
    );
  });

  testWidgets('connected with no choice yet the row names the first node', (
    tester,
  ) async {
    await pumpHome(tester, profile: _profile(), nodes: _nodes);
    await connect(tester);

    expect(
      find.descendant(of: switchRow(), matching: find.text('日本 01')),
      findsOneWidget,
    );
  });

  testWidgets(
    'connected without nodes the row falls back to the subscription',
    (tester) async {
      await pumpHome(tester, profile: _profile());
      await connect(tester);

      expect(
        find.descendant(
          of: switchRow(),
          matching: find.text('My subscription'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('the switch follows whether the proxy is running', (
    tester,
  ) async {
    await pumpHome(tester, profile: _profile(), nodes: _nodes);
    expect(
      tester.widget<GroupedSwitch>(find.byType(GroupedSwitch)).value,
      false,
    );

    container.read(runTimeProvider.notifier).value = 1;
    await tester.pump();

    expect(
      tester.widget<GroupedSwitch>(find.byType(GroupedSwitch)).value,
      true,
    );
  });

  testWidgets('lists every node with its protocol and transport', (
    tester,
  ) async {
    await pumpHome(tester, profile: _profile(), nodes: _nodes);

    expect(find.text('香港 02', findRichText: true), findsOneWidget);
    expect(find.text('SHADOWSOCKS / TCP'), findsOneWidget);
    expect(find.text('VLESS / WS'), findsOneWidget);
  });

  testWidgets('the subscription line carries traffic and expiry', (
    tester,
  ) async {
    await pumpHome(
      tester,
      profile: _profile(
        info: const SubscriptionInfo(
          upload: 1024,
          download: 2048,
          total: 1073741824,
          expire: 1796428800,
        ),
      ),
      nodes: _nodes,
    );

    expect(find.textContaining('TOT:1.00GB'), findsOneWidget);
    expect(find.textContaining('EXPIRES:2026-12-05'), findsOneWidget);
  });

  testWidgets('tapping a node selects it', (tester) async {
    await pumpHome(tester, profile: _profile(), nodes: _nodes);

    await tester.tap(find.text('香港 02', findRichText: true));
    await tester.pump();

    expect(container.read(currentProfileProvider)?.selectedMap, {
      nodeGroupName: '香港 02',
    });
    debouncer.cancel((FunctionTag.changeProxy, nodeGroupName));
  });

  testWidgets('tapping the subscription header folds its nodes', (
    tester,
  ) async {
    await pumpHome(tester, profile: _profile(), nodes: _nodes);

    await tester.tap(find.text('My subscription').last);
    await tester.pump();

    expect(find.text('SHADOWSOCKS / TCP'), findsNothing);
    expect(find.text('VLESS / WS'), findsNothing);

    await tester.tap(find.text('My subscription').last);
    await tester.pump();

    expect(find.text('SHADOWSOCKS / TCP'), findsOneWidget);
    expect(find.text('VLESS / WS'), findsOneWidget);
  });

  testWidgets('the routing row opens the routing page', (tester) async {
    await pumpHome(tester, profile: _profile(), nodes: _nodes);

    await tester.tap(find.text('Global routing'));
    await tester.pumpAndSettle();

    expect(find.byType(RouteModeView), findsOneWidget);
  });

  testWidgets('the routing page marks the mode and switches it', (
    tester,
  ) async {
    await pumpHome(tester, page: const RouteModeView());

    final check = find.byGlyph(AppGlyphs.check);
    expect(check, findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(GroupedRow, 'Rule'),
        matching: check,
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Global'));
    await tester.pump();

    expect(container.read(coreSettingProvider).mode, Mode.global);
    expect(
      find.descendant(
        of: find.widgetWithText(GroupedRow, 'Global'),
        matching: check,
      ),
      findsOneWidget,
    );
  });

  group('connectivity test', () {
    testWidgets('the row wears the glyph of the method in use', (tester) async {
      await pumpHome(tester, profile: _profile(), nodes: _nodes);
      final row = find.widgetWithText(GroupedRow, 'Connectivity test');

      expect(
        find.descendant(of: row, matching: find.byGlyph(AppGlyphs.circleT)),
        findsOneWidget,
      );

      container
          .read(appSettingProvider.notifier)
          .update((s) => s.copyWith(delayTestMethod: DelayTestMethod.url));
      await tester.pump();

      expect(
        find.descendant(of: row, matching: find.byGlyph(AppGlyphs.circleC)),
        findsOneWidget,
      );
    });

    testWidgets('the method glyph opens the method page, not the test', (
      tester,
    ) async {
      await pumpHome(tester, profile: _profile(), nodes: _nodes);
      final row = find.widgetWithText(GroupedRow, 'Connectivity test');

      await tester.tap(
        find.descendant(of: row, matching: find.byGlyph(AppGlyphs.circleT)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DelayMethodView), findsOneWidget);
      expect(find.textContaining('ms'), findsNothing);
    });

    testWidgets('the row tests every node and each shows its latency', (
      tester,
    ) async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(server.close);
      final address = '127.0.0.1:${server.port}';
      await pumpHome(
        tester,
        profile: _profile(),
        nodes: [
          Proxy(name: '日本 01', type: 'shadowsocks', address: address),
          Proxy(name: '香港 02', type: 'vless', address: address),
        ],
      );
      expect(find.textContaining('ms'), findsNothing);

      await tester.tap(find.text('Connectivity test'));
      for (var i = 0; i < 50; i++) {
        if (find.textContaining('ms').evaluate().length >= 2) break;
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.textContaining('ms'), findsNWidgets(2));
    });

    testWidgets('the row does nothing while there are no nodes', (
      tester,
    ) async {
      await pumpHome(tester, profile: _profile());

      await tester.tap(find.text('Connectivity test'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('ms'), findsNothing);
    });

    testWidgets('a right click on a node opens its menu', (tester) async {
      await pumpHome(tester, profile: _profile(), nodes: _nodes);

      await tester.tap(
        find.text('香港 02', findRichText: true),
        buttons: kSecondaryButton,
      );
      await tester.pumpAndSettle();

      expect(find.text('Delay test'), findsOneWidget);
      expect(find.text('Copy name'), findsOneWidget);
      expect(find.text('Copy address'), findsNothing);
    });

    testWidgets('the menu tests just that node', (tester) async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(server.close);
      await pumpHome(
        tester,
        profile: _profile(),
        nodes: [
          Proxy(
            name: '日本 01',
            type: 'shadowsocks',
            address: '127.0.0.1:${server.port}',
          ),
          const Proxy(name: '香港 02', type: 'vless'),
        ],
      );

      await tester.longPress(find.text('日本 01', findRichText: true).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delay test'));
      for (var i = 0; i < 50; i++) {
        if (find.textContaining('ms').evaluate().isNotEmpty) break;
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.textContaining('ms'), findsOneWidget);
    });

    testWidgets('the details button opens the node for editing', (
      tester,
    ) async {
      final outbound = buildNodeOutbound(NodeKind.shadowsocks, {
        ...nodeDefaults(NodeKind.shadowsocks),
        'address': '1.2.3.4',
        'port': '8388',
        'password': 'pw',
        'remark': '日本 01',
      });
      await pumpHome(
        tester,
        profile: _profile(),
        nodes: _nodes,
        overrides: [
          profilesActionProvider.overrideWith(
            () => _StoredNodeAction(outbound),
          ),
        ],
      );

      await tester.tap(find.byTooltip('日本 01 details'));
      await tester.pumpAndSettle();

      expect(find.byType(EditServerView), findsOneWidget);
      expect(find.text('Edit server'), findsOneWidget);
    });

    testWidgets('a node the form cannot hold is only shown', (tester) async {
      await pumpHome(
        tester,
        profile: _profile(),
        nodes: _nodes,
        overrides: [
          profilesActionProvider.overrideWith(() => _StoredNodeAction(null)),
        ],
      );

      await tester.tap(find.byTooltip('日本 01 details'));
      await tester.pumpAndSettle();

      expect(find.byType(EditServerView), findsNothing);
      expect(find.text('SHADOWSOCKS'), findsWidgets);
    });

    testWidgets('copying a node name puts it on the clipboard', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpHome(tester, profile: _profile(), nodes: _nodes);

      await tester.longPress(find.text('香港 02', findRichText: true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy name'));
      await tester.pumpAndSettle();

      expect(copied, '香港 02');
    });

    testWidgets('the settings page keeps only values that are valid', (
      tester,
    ) async {
      await pumpHome(tester, page: const UrlTestSettingsView());
      final timeout = find.descendant(
        of: find
            .ancestor(of: find.text('Timeout'), matching: find.byType(Row))
            .first,
        matching: find.byType(TextField),
      );
      final url = find.descendant(
        of: find
            .ancestor(of: find.text('Test URL'), matching: find.byType(Row))
            .first,
        matching: find.byType(TextField),
      );
      expect(
        container.read(appSettingProvider).delayTestTimeoutSeconds,
        defaultDelayTestTimeoutSeconds,
      );

      await tester.enterText(timeout, '12');
      await tester.pump();
      expect(container.read(appSettingProvider).delayTestTimeoutSeconds, 12);

      await tester.enterText(timeout, '0');
      await tester.pump();
      expect(container.read(appSettingProvider).delayTestTimeoutSeconds, 12);

      await tester.enterText(timeout, '999');
      await tester.pump();
      expect(container.read(appSettingProvider).delayTestTimeoutSeconds, 12);

      await tester.enterText(url, 'https://example.com/204');
      await tester.pump();
      expect(
        container.read(appSettingProvider).testUrl,
        'https://example.com/204',
      );

      await tester.enterText(url, 'not a url');
      await tester.pump();
      expect(
        container.read(appSettingProvider).testUrl,
        'https://example.com/204',
      );
    });

    testWidgets('a node row shows its measured latency', (tester) async {
      await pumpHome(tester, profile: _profile(), nodes: _nodes);
      final testUrl = container.read(appSettingProvider).testUrl;

      container
          .read(delayDataSourceProvider.notifier)
          .setDelay(Delay(url: testUrl, name: '香港 02', value: 120));
      container
          .read(delayDataSourceProvider.notifier)
          .setDelay(Delay(url: testUrl, name: '日本 01', value: -1));
      await tester.pump();

      expect(find.text('120ms'), findsOneWidget);
      expect(find.text('Timeout'), findsOneWidget);
    });
  });

  group('edit mode', () {
    Finder moreButton() => find.byTooltip('More');

    Future<void> enterEdit(WidgetTester tester) async {
      await tester.tap(moreButton());
      await tester.pump();
    }

    testWidgets('the more button turns the page into an edit page', (
      tester,
    ) async {
      await pumpHome(tester, profile: _profile(), nodes: _nodes);
      expect(find.text('Done'), findsNothing);
      expect(find.text('Delete'), findsNothing);

      await enterEdit(tester);

      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text(appName), findsNothing);
      expect(find.byGlyph(AppGlyphs.close), findsOneWidget);
      expect(find.byGlyph(AppGlyphs.dragHandle), findsOneWidget);
    });

    testWidgets('done and the close icon both leave it', (tester) async {
      await pumpHome(tester, profile: _profile(), nodes: _nodes);

      await enterEdit(tester);
      await tester.tap(find.text('Done'));
      await tester.pump();
      expect(find.text('Done'), findsNothing);
      expect(find.text(appName), findsOneWidget);

      await enterEdit(tester);
      await tester.tap(find.byTooltip('Done').last);
      await tester.pump();
      expect(find.text('Done'), findsNothing);
    });

    testWidgets('the switch is dimmed and cannot be flipped', (tester) async {
      await pumpHome(tester, profile: _profile(), nodes: _nodes);

      await enterEdit(tester);
      await tester.tap(find.byType(GroupedSwitch));
      await tester.pump();

      expect(container.read(runTimeProvider), isNull);
      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byType(GroupedSwitch),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, lessThan(1));
    });

    testWidgets('tapping a row ticks it instead of choosing the node', (
      tester,
    ) async {
      await pumpHome(tester, profile: _profile(), nodes: _nodes);
      await enterEdit(tester);

      await tester.tap(find.text('香港 02', findRichText: true));
      await tester.pump();

      expect(container.read(currentProfileProvider)?.selectedMap, isEmpty);
      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);

      await tester.tap(find.text('香港 02', findRichText: true));
      await tester.pump();

      expect(find.byGlyph(AppGlyphs.check), findsNothing);
    });

    testWidgets('delete waits for a profile to be ticked', (tester) async {
      await pumpHome(tester, profile: _profile(), nodes: _nodes);
      await enterEdit(tester);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm'), findsNothing);

      await tester.tap(find.text('香港 02', findRichText: true));
      await tester.pump();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm'), findsNothing);
    });

    testWidgets('deleting a ticked profile removes it without asking', (
      tester,
    ) async {
      await pumpHome(tester, profile: _profile(), nodes: _nodes);
      await enterEdit(tester);

      await tester.tap(find.text('My subscription'));
      await tester.pump();
      await tester.tap(find.text('Delete'));
      await tester.pump();
      for (var i = 0; i < 50; i++) {
        if (container.read(profilesProvider).isEmpty) break;
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }

      expect(find.text('Confirm'), findsNothing);
      expect(container.read(profilesProvider), isEmpty);
    });

    testWidgets('copy puts the ticked addresses and links on the clipboard', (
      tester,
    ) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpHome(
        tester,
        profile: _profile(),
        nodes: const [
          Proxy(name: '日本 01', type: 'ss', address: '1.2.3.4:443'),
          Proxy(name: '香港 02', type: 'vless'),
        ],
      );
      await enterEdit(tester);

      await tester.tap(find.text('My subscription'));
      await tester.tap(find.text('香港 02', findRichText: true));
      await tester.pump();
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      expect(copied, 'https://example.com/sub\n香港 02');
    });

    testWidgets('the toolbar keeps its four icons close together', (
      tester,
    ) async {
      await pumpHome(tester, profile: _profile(), nodes: _nodes);

      final delay = tester.getCenter(find.byGlyph(AppGlyphs.signpost));
      final add = tester.getCenter(find.byGlyph(AppGlyphs.copy));
      final update = tester.getCenter(find.byGlyph(AppGlyphs.sync));
      final more = tester.getCenter(find.byGlyph(AppGlyphs.more));

      for (final pair in [(delay, add), (add, update), (update, more)]) {
        expect((pair.$2.dx - pair.$1.dx).abs(), lessThanOrEqualTo(32));
      }
    });
  });
}
