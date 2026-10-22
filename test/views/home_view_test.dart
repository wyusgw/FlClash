import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/home/delay_test.dart';
import 'package:fl_clash/views/home/home.dart';
import 'package:fl_clash/views/config/network.dart';
import 'package:fl_clash/views/home/route_mode.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:fl_clash/views/profiles/edit_server.dart';
import 'package:fl_clash/widgets/widgets.dart';
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

class _RecordingImportAction extends ProfilesAction {
  static final imported = <ClipboardImport>[];

  @override
  Future<void> importFromClipboard(ClipboardImport source) async {
    imported.add(source);
  }
}

class _StoredNodeAction extends ProfilesAction {
  _StoredNodeAction(this.outbound);

  final Map<String, dynamic>? outbound;

  @override
  Future<Map<String, dynamic>?> readNodeOutbound(
    Profile profile,
    String tag,
  ) async => outbound;
}

class _CountingCommonAction extends CommonAction {
  static var toggles = 0;

  @override
  void toggleRunning() => toggles++;
}

class _RecordingUpdateAction extends ProfilesAction {
  static final updated = <Profile>[];

  @override
  Future<void> updateProfile(
    Profile profile, {
    bool showLoading = false,
  }) async {
    updated.add(profile);
  }
}

class _FailingUpdateAction extends ProfilesAction {
  @override
  Future<void> updateProfile(
    Profile profile, {
    bool showLoading = false,
  }) async {
    throw Exception('subscription unreachable');
  }
}

void main() {
  late ProviderContainer container;

  Future<void> pumpHome(
    WidgetTester tester, {
    Profile? profile,
    List<Proxy> nodes = const [],
    Widget page = const HomeView(),
    List<Override> overrides = const [],
    List<Profile> others = const [],
    bool withStatusManager = false,
  }) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container = ProviderContainer(
      overrides: [
        ...overrides,
        profilesProvider.overrideWith(
          () => TestProfiles([?profile, ...others]),
        ),
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
        child: TestApp(withStatusManager: withStatusManager, child: page),
      ),
    );
    await tester.pump();
  }

  testWidgets('without a profile it still shows the controls and add node', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('Not connected'), findsOneWidget);
    expect(find.byType(GroupedSwitch), findsOneWidget);
    expect(find.text('Global routing'), findsOneWidget);
    expect(find.text('Connectivity test'), findsOneWidget);
    expect(find.text('Add node'), findsOneWidget);
    expect(
      find.text('Tap a subscription to fold or expand its nodes.'),
      findsOneWidget,
    );
  });

  testWidgets('add node opens the add page', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Add node'));
    await tester.pumpAndSettle();

    expect(find.byType(AddProfileView), findsOneWidget);
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

  group('bar logo', () {
    final many = [
      for (var i = 0; i < 30; i++)
        Proxy(name: 'Node $i', type: 'vless', network: 'tcp'),
    ];
    double titleOpacity(WidgetTester tester) => tester
        .widget<Opacity>(
          find.ancestor(of: find.text(appName), matching: find.byType(Opacity)),
        )
        .opacity;
    final logo = find.byWidgetPredicate((w) => w is Image && w.width == 26);
    double logoOpacity(WidgetTester tester) => tester
        .widget<Opacity>(
          find.ancestor(of: logo, matching: find.byType(Opacity)).first,
        )
        .opacity;

    testWidgets('the name gives way to the logo as the switch rows go', (
      tester,
    ) async {
      await pumpHome(tester, profile: _profile(), nodes: many);
      expect(titleOpacity(tester), 1);
      expect(logoOpacity(tester), 0);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -90));
      await tester.pump();
      final title = titleOpacity(tester);
      expect(title, inExclusiveRange(0, 1));
      expect(logoOpacity(tester), closeTo(1 - title, 1e-9));

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pump();
      expect(titleOpacity(tester), 0);
      expect(logoOpacity(tester), 1);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 600));
      await tester.pumpAndSettle();
      expect(titleOpacity(tester), 1);
    });

    testWidgets('the logo turns the proxy on and off once it shows', (
      tester,
    ) async {
      _CountingCommonAction.toggles = 0;
      await pumpHome(
        tester,
        profile: _profile(),
        nodes: many,
        overrides: [
          commonActionProvider.overrideWith(_CountingCommonAction.new),
        ],
      );
      await tester.tap(logo, warnIfMissed: false);
      expect(_CountingCommonAction.toggles, 0);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pump();
      await tester.tap(logo);
      expect(_CountingCommonAction.toggles, 1);
    });

    testWidgets('the logo is grey until the proxy runs', (tester) async {
      await pumpHome(tester, profile: _profile(), nodes: many);
      ColorFilter filter() => tester
          .widget<ColorFiltered>(
            find.ancestor(of: logo, matching: find.byType(ColorFiltered)),
          )
          .colorFilter;
      final off = filter();

      container.read(runTimeProvider.notifier).value = 1;
      await tester.pumpAndSettle();

      expect(filter(), isNot(off));
      expect(
        filter(),
        const ColorFilter.matrix([
          1, 0, 0, 0, 0, //
          0, 1, 0, 0, 0, //
          0, 0, 1, 0, 0, //
          0, 0, 0, 1, 0,
        ]),
      );
    });
  });

  group('subscription menu', () {
    Future<void> openMenu(WidgetTester tester) async {
      await tester.tap(
        find.text('My subscription').last,
        buttons: kSecondaryButton,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a right click on a subscription opens its menu', (
      tester,
    ) async {
      await pumpHome(tester, profile: _profile(), nodes: _nodes);
      await openMenu(tester);

      final items = tester
          .widgetList<PopupMenuItem<Object?>>(
            find.byWidgetPredicate((w) => w is PopupMenuItem && w.enabled),
          )
          .map((item) => (item.child! as Text).data)
          .toList();
      expect(items, [
        'Test',
        'Update',
        'URL',
        'Edit',
        'Hide',
        'QR code',
        'Copy link',
        'Paste',
        'Delete',
      ]);
    });

    testWidgets('a subscription from a file has no link to update or share', (
      tester,
    ) async {
      await pumpHome(
        tester,
        profile: _profile().copyWith(url: ''),
        nodes: _nodes,
      );
      await openMenu(tester);

      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Update'), findsNothing);
      expect(find.text('URL'), findsNothing);
      expect(find.text('QR code'), findsNothing);
      expect(find.text('Copy link'), findsNothing);
      expect(find.text('Paste'), findsOneWidget);
    });

    testWidgets('hide keeps it off the page until it is shown again', (
      tester,
    ) async {
      await pumpHome(tester, profile: _profile(), nodes: _nodes);
      await openMenu(tester);
      await tester.tap(find.text('Hide'));
      await tester.pumpAndSettle();

      expect(find.text('My subscription'), findsNothing);
      expect(container.read(profilesProvider), hasLength(1));
      expect(find.text('Hidden subscriptions: 1'), findsOneWidget);

      await tester.tap(find.text('Hidden subscriptions: 1'));
      await tester.pumpAndSettle();

      expect(find.text('My subscription'), findsOneWidget);
      expect(find.textContaining('Hidden subscriptions'), findsNothing);
    });

    testWidgets('URL changes the link and reads the subscription from it', (
      tester,
    ) async {
      _RecordingUpdateAction.updated.clear();
      await pumpHome(
        tester,
        profile: _profile(),
        nodes: _nodes,
        overrides: [
          profilesActionProvider.overrideWith(_RecordingUpdateAction.new),
        ],
      );
      await openMenu(tester);
      await tester.tap(find.text('URL'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'https://example.com/moved',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(
        container.read(profilesProvider).single.url,
        'https://example.com/moved',
      );
      expect(
        _RecordingUpdateAction.updated.single.url,
        'https://example.com/moved',
      );
    });

    testWidgets('copy link puts the subscription link on the clipboard', (
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
      await pumpHome(tester, profile: _profile(), nodes: _nodes);
      await openMenu(tester);
      await tester.tap(find.text('Copy link'));
      await tester.pumpAndSettle();

      expect(copied, 'https://example.com/sub');
    });
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
    expect(
      find.text('↑:0.00GB,↓:0.00GB,TOT:1.00GB EXPIRES:2026-12-05'),
      findsOneWidget,
    );
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
    double drawer() => tester.getSize(find.byType(SizeTransition)).height;
    final open = drawer();

    await tester.tap(find.text('My subscription').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    // The nodes slide back into the header rather than vanish at once.
    expect(find.text('SHADOWSOCKS / TCP'), findsOneWidget);
    expect(drawer(), inExclusiveRange(0, open));

    await tester.pumpAndSettle();
    expect(find.text('SHADOWSOCKS / TCP'), findsNothing);
    expect(find.text('VLESS / WS'), findsNothing);

    await tester.tap(find.text('My subscription').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('SHADOWSOCKS / TCP'), findsOneWidget);
    expect(drawer(), inExclusiveRange(0, open));

    await tester.pumpAndSettle();
    expect(drawer(), open);
    expect(find.text('VLESS / WS'), findsOneWidget);
  });

  testWidgets('the nodes fold at once when motion is reduced', (tester) async {
    await pumpHome(
      tester,
      profile: _profile(),
      nodes: _nodes,
      page: const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: HomeView(),
      ),
    );

    await tester.tap(find.text('My subscription').last);
    await tester.pump();
    await tester.pump();

    expect(find.text('SHADOWSOCKS / TCP'), findsNothing);
  });

  group('several subscriptions', () {
    const other = Profile(
      id: 2,
      label: 'Second subscription',
      autoUpdateDuration: Duration.zero,
      url: 'https://example.com/second',
    );
    const otherNodes = [Proxy(name: '美国 03', type: 'trojan', network: 'grpc')];

    Future<void> pumpTwo(WidgetTester tester) => pumpHome(
      tester,
      profile: _profile(),
      nodes: _nodes,
      others: [other],
      overrides: [
        profileNodesProvider(
          other.id,
          other.lastUpdateDate,
        ).overrideWith((_) async => otherNodes),
      ],
    );

    testWidgets('only the one in use starts open', (tester) async {
      await pumpTwo(tester);

      expect(find.text('VLESS / WS'), findsOneWidget);
      expect(find.text('TROJAN / GRPC'), findsNothing);
    });

    testWidgets('another opens beside it without being switched to', (
      tester,
    ) async {
      await pumpTwo(tester);

      await tester.tap(find.text('Second subscription'));
      await tester.pumpAndSettle();

      expect(find.text('VLESS / WS'), findsOneWidget);
      expect(find.text('TROJAN / GRPC'), findsOneWidget);
      expect(container.read(currentProfileIdProvider), _profile().id);

      await tester.tap(find.text('Second subscription'));
      await tester.pumpAndSettle();

      expect(find.text('TROJAN / GRPC'), findsNothing);
      expect(find.text('VLESS / WS'), findsOneWidget);
    });

    testWidgets('nodes read after it opens push it on smoothly', (
      tester,
    ) async {
      final read = Completer<List<Proxy>>();
      await pumpHome(
        tester,
        profile: _profile(),
        nodes: _nodes,
        others: [other],
        overrides: [
          profileNodesProvider(
            other.id,
            other.lastUpdateDate,
          ).overrideWith((_) => read.future),
        ],
      );
      final drawer = find.descendant(
        of: find.ancestor(
          of: find.text('Second subscription'),
          matching: find.byType(GroupedSection),
        ),
        matching: find.byType(SizeTransition),
      );

      await tester.tap(find.text('Second subscription'));
      await tester.pumpAndSettle();
      expect(tester.getSize(drawer).height, 0);

      read.complete(otherNodes);
      // One frame for the read to land, one for the section to build them.
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final growing = tester.getSize(drawer).height;

      await tester.pumpAndSettle();
      final grown = tester.getSize(drawer).height;
      expect(growing, inExclusiveRange(0, grown));
      expect(find.text('TROJAN / GRPC'), findsOneWidget);
    });

    SwipeActions swipeOf(WidgetTester tester, String label) =>
        tester.widget<SwipeActions>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(SwipeActions),
          ),
        );
    List<String> labels(List<SwipeAction> actions) => [
      for (final action in actions) action.label,
    ];

    testWidgets('a subscription swipes to test and update, or QR and delete', (
      tester,
    ) async {
      await pumpTwo(tester);
      final l10n = AppLocalizations.current;

      final inUse = swipeOf(tester, 'My subscription');
      expect(labels(inUse.leading), [l10n.test, l10n.update]);
      expect(labels(inUse.trailing), [l10n.qrcode, l10n.delete]);
      expect(inUse.leading.first.color, swipeActionGo);
      expect(inUse.trailing.last.color, groupedDanger);

      // The core runs only the one in use, so another cannot be tested.
      final another = swipeOf(tester, 'Second subscription');
      expect(labels(another.leading), [l10n.update]);
      expect(labels(another.trailing), [l10n.qrcode, l10n.delete]);
    });

    testWidgets('the QR action shows the subscription link as a code', (
      tester,
    ) async {
      await pumpTwo(tester);

      swipeOf(tester, 'My subscription').trailing.first.onPressed();
      await tester.pumpAndSettle();

      expect(find.byType(QrCodeView), findsOneWidget);
      expect(find.text('https://example.com/sub'), findsOneWidget);
    });

    testWidgets('a subscription with no link has only delete', (tester) async {
      await pumpHome(
        tester,
        profile: _profile().copyWith(url: ''),
        nodes: _nodes,
      );

      final swipe = swipeOf(tester, 'My subscription');
      expect(labels(swipe.leading), [AppLocalizations.current.test]);
      expect(labels(swipe.trailing), [AppLocalizations.current.delete]);
    });

    testWidgets('a node of another one switches to it with that node', (
      tester,
    ) async {
      await pumpTwo(tester);
      await tester.tap(find.text('Second subscription'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('美国 03', findRichText: true));
      await tester.pump();

      expect(container.read(currentProfileIdProvider), other.id);
      expect(container.read(currentProfileProvider)?.selectedMap, {
        nodeGroupName: '美国 03',
      });
    });
  });

  testWidgets('the routing row opens the routing page', (tester) async {
    await pumpHome(tester, profile: _profile(), nodes: _nodes);

    await tester.tap(find.text('Global routing'));
    await tester.pumpAndSettle();

    expect(find.byType(RouteModeView), findsOneWidget);
  });

  testWidgets('the routing page offers the TUN switch on a desktop', (
    tester,
  ) async {
    await pumpHome(tester, page: const RouteModeView(desktop: true));

    expect(find.byType(TUNItem), findsOneWidget);
  });

  testWidgets('the routing page has no TUN switch off a desktop', (
    tester,
  ) async {
    await pumpHome(tester, page: const RouteModeView(desktop: false));

    expect(find.byType(TUNItem), findsNothing);
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

    testWidgets('an update that fails says so', (tester) async {
      await pumpHome(
        tester,
        profile: _profile(),
        nodes: _nodes,
        overrides: [
          profilesActionProvider.overrideWith(_FailingUpdateAction.new),
        ],
        withStatusManager: true,
      );

      await tester.tap(find.byTooltip('Update').first);
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('subscription unreachable'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('the buttons carry no hover or press shade', (tester) async {
      await pumpHome(tester, profile: _profile(), nodes: _nodes);

      for (final tooltip in ['Update', 'Delay test', 'Edit', '日本 01 details']) {
        final inks = tester.widgetList<InkResponse>(
          find.descendant(
            of: find.byTooltip(tooltip),
            matching: find.byType(InkResponse),
          ),
        );
        expect(inks, isNotEmpty, reason: tooltip);
        for (final ink in inks) {
          expect(ink.hoverColor, Colors.transparent, reason: tooltip);
          expect(ink.highlightColor, Colors.transparent, reason: tooltip);
          expect(ink.splashFactory, NoSplash.splashFactory, reason: tooltip);
        }
      }
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

    testWidgets('deleting a ticked profile asks first and then removes it', (
      tester,
    ) async {
      await pumpHome(tester, profile: _profile(), nodes: _nodes);
      await enterEdit(tester);

      await tester.tap(find.text('My subscription'));
      await tester.pump();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pump();
      for (var i = 0; i < 50; i++) {
        if (container.read(profilesProvider).isEmpty) break;
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 500));

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

  group('paste button', () {
    String? clipboard;

    setUp(() {
      clipboard = null;
      _RecordingImportAction.imported.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.getData') {
              final text = clipboard;
              return text == null ? null : <String, Object?>{'text': text};
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    Future<void> pump(WidgetTester tester) => pumpHome(
      tester,
      profile: _profile(),
      nodes: _nodes,
      page: const StatusManager(child: HomeView()),
      overrides: [
        profilesActionProvider.overrideWith(_RecordingImportAction.new),
      ],
    );

    testWidgets('shows while the clipboard permission is off', (tester) async {
      await pump(tester);

      expect(find.byGlyph(AppGlyphs.paste), findsOneWidget);
      expect(find.byTooltip('Paste'), findsOneWidget);
    });

    testWidgets('hides once the permission is on', (tester) async {
      await pump(tester);

      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(clipboardDetection: true));
      await tester.pumpAndSettle();

      expect(find.byGlyph(AppGlyphs.paste), findsNothing);
    });

    testWidgets('imports what is on the clipboard when tapped', (tester) async {
      await pump(tester);
      clipboard = 'https://example.com/other';

      await tester.tap(find.byGlyph(AppGlyphs.paste));
      await tester.pumpAndSettle();

      final imported = _RecordingImportAction.imported.single;
      expect(
        (imported as ClipboardSubscription).url,
        'https://example.com/other',
      );
    });

    testWidgets('says so when the clipboard holds nothing to import', (
      tester,
    ) async {
      await pump(tester);
      clipboard = 'meeting at noon';

      await tester.tap(find.byGlyph(AppGlyphs.paste));
      await tester.pumpAndSettle();

      expect(_RecordingImportAction.imported, isEmpty);
      expect(
        find.text(AppLocalizations.current.clipboardNothingToImport),
        findsOneWidget,
      );
    });
  });
}
