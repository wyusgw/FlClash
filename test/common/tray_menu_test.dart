import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/l10n_labels.dart';
import 'package:fl_clash/common/tray.dart';
import 'package:fl_clash/common/xray_config.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tray/tray.dart';

const _channel = MethodChannel('tray');

const _proxyGroup = Group(
  name: nodeGroupName,
  type: GroupType.Selector,
  all: [
    Proxy(name: 'A', type: 'Direct'),
    Proxy(name: 'B', type: 'Direct'),
    Proxy(name: 'C', type: 'Direct'),
  ],
);

HotKeyAction _bind(HotAction action, PhysicalKeyboardKey key) {
  return HotKeyAction(
    action: action,
    key: key.usbHidUsage,
    modifiers: const {KeyboardModifier.control, KeyboardModifier.shift},
  );
}

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

TrayState _trayState({
  bool isStart = false,
  bool tunEnable = false,
  bool showTrayTitle = false,
  bool safeMode = false,
  Mode mode = Mode.rule,
  List<Group> groups = const [],
  Map<HotAction, HotKeyAction> hotKeys = const {},
}) {
  return TrayState(
    mode: mode,
    tunEnable: tunEnable,
    isStart: isStart,
    groups: groups,
    selectedMap: const {},
    showTrayTitle: showTrayTitle,
    safeMode: safeMode,
    hotKeys: hotKeys,
  );
}

List<Map<Object?, Object?>> _items(MethodCall? call) {
  final menu = (call?.arguments as Map?)?['menu'] as List?;
  return menu?.cast<Map<Object?, Object?>>() ?? const [];
}

Map<Object?, Object?> _item(MethodCall? call, String label) {
  return _items(call).firstWhere((item) => item['label'] == label);
}

List<String> _labels(MethodCall? call) {
  return _items(call).map((item) => item['label']).whereType<String>().toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> calls;
  late ProviderContainer container;
  late AppTray tray;

  late Directory root;

  setUpAll(() async {
    root = Directory.systemTemp.createTempSync('tray_menu_test');
    PathProviderPlatform.instance = _FakePathProvider(root.path);
    await AppLocalizations.load(const Locale('en'));
  });

  tearDownAll(() {
    // The shared system temp dir is not exclusively ours; another suite running
    // alongside this one can take the tree out from under the teardown, either
    // before the check or between the check and the delete.
    try {
      if (root.existsSync()) {
        root.deleteSync(recursive: true);
      }
    } on FileSystemException {
      return;
    }
  });

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    calls = [];
    tray = AppTray.forPlatform(isMacOS: true, isWindows: false);
    container = ProviderContainer();
    Tray.instance.resetForTesting();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call);
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
    container.dispose();
    debugDefaultTargetPlatformOverride = null;
  });

  MethodCall? showCall() {
    for (final call in calls.reversed) {
      if (call.method == 'show') {
        return call;
      }
    }
    return null;
  }

  Future<void> update(
    TrayState trayState, {
    AppTray? on,
    Traffic traffic = const Traffic(),
  }) {
    return (on ?? tray).update(
      trayState: trayState,
      traffic: traffic,
      read: container.read,
    );
  }

  test(
    'SystemAction.updateTray builds the menu without reading itself',
    () async {
      globalState.container = container;
      trayPort = tray;
      addTearDown(() => trayPort = null);

      await container.read(systemActionProvider.notifier).updateTray();

      expect(showCall(), isNotNull);
      expect(
        _labels(showCall()),
        contains(currentAppLocalizations.quitFromMenuBar),
      );
    },
  );

  test(
    'the stopped menu reads not connected and drops the old toggles but the TUN one',
    () async {
      await update(_trayState());

      final labels = _labels(showCall());
      final l10n = currentAppLocalizations;
      expect(labels, contains(l10n.openApp(appName)));
      expect(labels, contains(l10n.quitFromMenuBar));
      expect(labels, contains(l10n.toggleSpeedView));
      expect(_item(showCall(), l10n.notConnected)['checked'], isFalse);
      for (final dropped in [
        l10n.start,
        l10n.stop,
        l10n.systemProxy,
        l10n.autoLaunch,
        l10n.copyEnvVar,
      ]) {
        expect(labels, isNot(contains(dropped)));
      }
    },
  );

  test('the running menu names the selected server', () async {
    container.dispose();
    container = ProviderContainer(
      overrides: [
        selectedProxyNameProvider(nodeGroupName).overrideWithValue('B'),
      ],
    );
    await update(_trayState(isStart: true, groups: [_proxyGroup]));

    final l10n = currentAppLocalizations;
    expect(_item(showCall(), '${l10n.connected}: B')['checked'], isTrue);
    expect(_item(showCall(), '${l10n.server}: B')['type'], 'submenu');
  });

  test('the connectivity test follows the server submenu', () async {
    await update(
      _trayState(
        groups: [_proxyGroup],
        hotKeys: {
          HotAction.delayTest: _bind(
            HotAction.delayTest,
            PhysicalKeyboardKey.keyD,
          ),
        },
      ),
    );

    final items = _items(showCall());
    final index = items.indexWhere((item) => item['type'] == 'submenu');
    expect(
      items[index]['label'],
      startsWith(currentAppLocalizations.globalRouting),
    );
    expect(
      items[index + 1]['label'],
      startsWith(currentAppLocalizations.server),
    );
    expect(items[index + 2]['label'], currentAppLocalizations.connectivityTest);
    expect(items[index + 2]['detail'], '⌃⇧D');
  });

  test('the TUN entry follows the setting and its shortcut', () async {
    final l10n = currentAppLocalizations;
    await update(
      _trayState(
        hotKeys: {
          HotAction.tun: _bind(HotAction.tun, PhysicalKeyboardKey.keyT),
        },
      ),
    );
    expect(_item(showCall(), l10n.tun)['type'], 'checkbox');
    expect(_item(showCall(), l10n.tun)['checked'], isFalse);
    expect(_item(showCall(), l10n.tun)['detail'], '⌃⇧T');

    await update(_trayState(tunEnable: true));
    expect(_item(showCall(), l10n.tun)['checked'], isTrue);
  });

  test('the rates are never listed in the menu', () async {
    for (final showTrayTitle in [false, true]) {
      await update(
        _trayState(showTrayTitle: showTrayTitle),
        traffic: const Traffic(up: 800, down: 3300),
      );

      expect(_labels(showCall()).where((l) => l.startsWith('▲')), isEmpty);
      expect(_labels(showCall()).where((l) => l.startsWith('▼')), isEmpty);
    }
  });

  test('without a node group the server entries are left out', () async {
    await update(_trayState());

    final labels = _labels(showCall());
    final l10n = currentAppLocalizations;
    expect(labels.where((label) => label.startsWith(l10n.server)), isEmpty);
    expect(labels, isNot(contains(l10n.connectivityTest)));
  });

  group('safe mode', () {
    test('keeps the full menu', () async {
      await update(
        _trayState(isStart: true, safeMode: true, groups: [_proxyGroup]),
      );

      final labels = _labels(showCall());
      final l10n = currentAppLocalizations;
      expect(labels, contains('${l10n.connected}: A'));
      expect(labels, contains(l10n.connectivityTest));
      expect(labels, contains(l10n.quitFromMenuBar));
    });

    test('names the mode in the tooltip and ships the safe icon', () async {
      await update(_trayState(isStart: true, safeMode: true));

      final arguments = showCall()!.arguments as Map;
      final l10n = currentAppLocalizations;
      expect(arguments['toolTip'], '$appName (${l10n.safeMode})');
      final reps = ((arguments['icon'] as Map)['reps'] as List).cast<Map>();
      final base = reps.firstWhere((rep) => rep['scale'] == 1.0);
      expect(
        base['bytes'],
        base64Encode(
          File('assets/images/tray/macos/status_4.png').readAsBytesSync(),
        ),
      );
    });
  });

  test('offers every outbound mode in the routing submenu', () async {
    await update(_trayState(mode: Mode.global));

    final routing = _item(
      showCall(),
      '${currentAppLocalizations.globalRouting}: ${Mode.global.label}',
    );
    final children = (routing['items'] as List).cast<Map<Object?, Object?>>();
    expect(children.map((item) => item['label']), [
      for (final mode in Mode.values) mode.label,
    ]);
    expect(
      children
          .where((item) => item['checked'] == true)
          .map((item) => item['label']),
      [Intl.message(Mode.global.name)],
    );
  });

  test('sends icon, tooltip and menu in a single show call', () async {
    await update(_trayState(isStart: true, tunEnable: true));

    final showCalls = calls.where((call) => call.method == 'show').toList();
    expect(showCalls, hasLength(1));

    final arguments = showCalls.single.arguments as Map;
    expect(arguments['toolTip'], appName);
    expect(arguments['menu'], isNotEmpty);
    final reps = ((arguments['icon'] as Map)['reps'] as List).cast<Map>();
    expect(reps.map((rep) => rep['scale']), containsAll([1.0, 2.0, 3.0, 4.0]));
    expect(reps.map((rep) => rep['bytes']), everyElement(isNotEmpty));
    expect((arguments['icon'] as Map)['isTemplate'], isTrue);
  });

  test('skips the platform call when the tray state is unchanged', () async {
    await update(_trayState(isStart: true));
    await update(_trayState(isStart: true));

    expect(calls.where((call) => call.method == 'show'), hasLength(1));
  });

  test('menu item ids are stable across identical rebuilds', () async {
    await update(_trayState());
    final first = _items(showCall()).map((item) => item['id']).toList();

    Tray.instance.resetForTesting();
    calls.clear();

    await update(_trayState());
    final second = _items(showCall()).map((item) => item['id']).toList();

    expect(second, first);
    expect(first.first, 1024);
  });

  test('the server submenu carries the nodes as nested items', () async {
    await update(_trayState(groups: [_proxyGroup]));

    final l10n = currentAppLocalizations;
    final submenu = _item(showCall(), '${l10n.server}: A');
    final children = (submenu['items'] as List).cast<Map<Object?, Object?>>();
    expect(children.map((item) => item['label']), ['A', 'B', 'C']);
    expect(children.first['checked'], isTrue);
  });

  test('the server submenu lists the nodes by name, with no icons', () async {
    const group = Group(
      name: nodeGroupName,
      type: GroupType.Selector,
      all: [
        Proxy(name: '日本 01', type: 'Direct'),
        Proxy(name: '\u{1F1FA}\u{1F1F8} Los Angeles', type: 'Direct'),
        Proxy(name: 'Seoul', type: 'Direct', region: 'DE'),
      ],
    );
    await update(_trayState(groups: [group]));

    final submenu = _item(
      showCall(),
      '${currentAppLocalizations.server}: 日本 01',
    );
    expect(submenu, isNot(contains('icon')));
    final children = (submenu['items'] as List).cast<Map<Object?, Object?>>();
    expect(children.map((item) => item['label']), [
      '日本 01',
      '\u{1F1FA}\u{1F1F8} Los Angeles',
      'Seoul',
    ]);
    expect(children, everyElement(isNot(contains('icon'))));
  });

  test('a platform that cannot draw menu icons sends none', () async {
    final windows = AppTray.forPlatform(isMacOS: false, isWindows: true);
    const group = Group(
      name: nodeGroupName,
      type: GroupType.Selector,
      all: [Proxy(name: '日本 01', type: 'Direct')],
    );
    await update(_trayState(groups: [group]), on: windows);

    final submenu = _item(
      showCall(),
      '${currentAppLocalizations.server}: 日本 01',
    );
    final children = (submenu['items'] as List).cast<Map<Object?, Object?>>();
    expect(children.single['label'], '日本 01');
    expect(children.single.containsKey('icon'), isFalse);
  });

  test(
    'a bound hotkey also selects its entry while the menu is open',
    () async {
      await update(
        _trayState(
          groups: [_proxyGroup],
          hotKeys: {
            HotAction.start: _bind(HotAction.start, PhysicalKeyboardKey.keyS),
            HotAction.speedView: HotKeyAction(
              action: HotAction.speedView,
              key: PhysicalKeyboardKey.keyK.usbHidUsage,
              modifiers: const {KeyboardModifier.meta},
            ),
            HotAction.exit: HotKeyAction(
              action: HotAction.exit,
              key: PhysicalKeyboardKey.f4.usbHidUsage,
              modifiers: const {KeyboardModifier.fn, KeyboardModifier.alt},
            ),
          },
        ),
      );

      final l10n = currentAppLocalizations;
      final call = showCall();
      expect(_item(call, l10n.notConnected)['shortcut'], {
        'key': 's',
        'modifiers': ['control', 'shift'],
      });
      expect(_item(call, l10n.toggleSpeedView)['shortcut'], {
        'key': 'k',
        'modifiers': ['command'],
      });
      expect(_item(call, l10n.quitFromMenuBar), isNot(contains('shortcut')));
      expect(_item(call, l10n.connectivityTest), isNot(contains('shortcut')));
    },
  );

  test('a platform that is not macOS sends no key equivalent', () async {
    await update(
      _trayState(
        hotKeys: {
          HotAction.start: _bind(HotAction.start, PhysicalKeyboardKey.keyS),
        },
      ),
      on: AppTray.forPlatform(isMacOS: false, isWindows: true),
    );

    final item = _item(showCall(), currentAppLocalizations.notConnected);
    expect(item['detail'], 'Ctrl+Shift+S');
    expect(item, isNot(contains('shortcut')));
  });

  test('shows each bound hotkey dimmed beside its entry', () async {
    await update(
      _trayState(
        isStart: true,
        hotKeys: {
          HotAction.view: _bind(HotAction.view, PhysicalKeyboardKey.keyV),
          HotAction.globalMode: _bind(
            HotAction.globalMode,
            PhysicalKeyboardKey.keyG,
          ),
          HotAction.start: _bind(HotAction.start, PhysicalKeyboardKey.keyS),
          HotAction.mode: _bind(HotAction.mode, PhysicalKeyboardKey.keyM),
        },
      ),
    );

    final l10n = currentAppLocalizations;
    final call = showCall();
    expect(_item(call, l10n.openApp(appName))['detail'], '⌃⇧V');
    expect(_item(call, l10n.connected)['detail'], '⌃⇧S');
    final routing = _item(call, '${l10n.globalRouting}: ${Mode.rule.label}');
    expect(routing['detail'], '⌃⇧M');
    final modes = (routing['items'] as List).cast<Map<Object?, Object?>>();
    expect(
      modes.firstWhere((item) => item['label'] == Mode.global.label)['detail'],
      '⌃⇧G',
    );
    expect(
      modes.firstWhere((item) => item['label'] == Mode.rule.label),
      isNot(contains('detail')),
    );
    expect(_item(call, l10n.quitFromMenuBar), isNot(contains('detail')));
  });

  test(
    'group submenus show the delay of the selection and of each proxy',
    () async {
      container.dispose();
      container = ProviderContainer(
        overrides: [
          selectedProxyNameProvider(nodeGroupName).overrideWithValue('A'),
          trayDelaysProvider.overrideWithValue({
            nodeGroupName: {'A': 120, 'B': -1},
          }),
        ],
      );
      await update(
        _trayState(groups: [_proxyGroup]),
        on: AppTray.forPlatform(isMacOS: false, isWindows: true),
      );

      final submenu = _item(showCall(), '${currentAppLocalizations.server}: A');
      expect(submenu['detail'], '120ms');
      final children = (submenu['items'] as List).cast<Map<Object?, Object?>>();
      expect(children.map((item) => item['detail']), [
        '120ms',
        currentAppLocalizations.timeout,
        null,
      ]);
      expect(submenu['detailTone'], 'success');
      expect(children.map((item) => item['detailTone']), [
        'success',
        'error',
        null,
      ]);
    },
  );

  test('nodes under test spin until their delay arrives', () async {
    container.dispose();
    container = ProviderContainer(
      overrides: [
        selectedProxyNameProvider(nodeGroupName).overrideWithValue('A'),
        trayDelaysProvider.overrideWithValue({
          nodeGroupName: {'A': 120},
        }),
        trayPendingDelaysProvider.overrideWithValue({
          nodeGroupName: {'A', 'C'},
        }),
      ],
    );
    await update(
      _trayState(groups: [_proxyGroup]),
      on: AppTray.forPlatform(isMacOS: false, isWindows: true),
    );

    final l10n = currentAppLocalizations;
    final submenu = _item(showCall(), '${l10n.server}: A');
    final children = (submenu['items'] as List).cast<Map<Object?, Object?>>();
    expect(submenu['busy'], isTrue);
    expect(children.map((item) => item['busy']), [true, null, true]);
    expect(_item(showCall(), l10n.connectivityTest)['busy'], isTrue);
  });

  test('the macOS menu shows no delay and no spinner', () async {
    container.dispose();
    container = ProviderContainer(
      overrides: [
        selectedProxyNameProvider(nodeGroupName).overrideWithValue('A'),
        trayDelaysProvider.overrideWithValue({
          nodeGroupName: {'A': 120, 'B': -1},
        }),
        trayPendingDelaysProvider.overrideWithValue({
          nodeGroupName: {'A', 'C'},
        }),
      ],
    );
    await update(_trayState(groups: [_proxyGroup]));

    final l10n = currentAppLocalizations;
    final submenu = _item(showCall(), '${l10n.server}: A');
    final children = (submenu['items'] as List).cast<Map<Object?, Object?>>();
    for (final item in [
      submenu,
      ...children,
      _item(showCall(), l10n.connectivityTest),
    ]) {
      expect(item, isNot(contains('detail')));
      expect(item, isNot(contains('detailTone')));
      expect(item, isNot(contains('busy')));
    }
  });

  test('nothing spins while no delay test is pending', () async {
    await update(_trayState(groups: [_proxyGroup]));

    final l10n = currentAppLocalizations;
    final submenu = _item(showCall(), '${l10n.server}: A');
    final children = (submenu['items'] as List).cast<Map<Object?, Object?>>();
    expect(submenu, isNot(contains('busy')));
    expect(children, everyElement(isNot(contains('busy'))));
    expect(_item(showCall(), l10n.connectivityTest), isNot(contains('busy')));
  });

  test('a slow node is tinted as a warning', () async {
    container.dispose();
    container = ProviderContainer(
      overrides: [
        selectedProxyNameProvider(nodeGroupName).overrideWithValue('A'),
        trayDelaysProvider.overrideWithValue({
          nodeGroupName: {'A': 600, 'B': 599},
        }),
      ],
    );
    await update(
      _trayState(groups: [_proxyGroup]),
      on: AppTray.forPlatform(isMacOS: false, isWindows: true),
    );

    final submenu = _item(showCall(), '${currentAppLocalizations.server}: A');
    final children = (submenu['items'] as List).cast<Map<Object?, Object?>>();
    expect(children.take(2).map((item) => item['detailTone']), [
      'warning',
      'success',
    ]);
  });

  group('a platform that is not macOS', () {
    late AppTray windows;

    setUp(() {
      windows = AppTray.forPlatform(isMacOS: false, isWindows: true);
    });

    test(
      'gets a plain icon and the same menu without the speed toggle',
      () async {
        await update(
          _trayState(isStart: true, groups: [_proxyGroup]),
          on: windows,
        );

        final arguments = showCall()!.arguments as Map;
        expect((arguments['icon'] as Map)['isTemplate'], isFalse);
        final l10n = currentAppLocalizations;
        expect(
          _items(showCall()).where((item) => item['type'] == 'submenu'),
          hasLength(2),
        );
        expect(_labels(showCall()), contains(l10n.connectivityTest));
        expect(_labels(showCall()), isNot(contains(l10n.toggleSpeedView)));
      },
    );

    test('joins modifiers with + in the hotkey hints', () async {
      await update(
        _trayState(
          hotKeys: {
            HotAction.view: _bind(HotAction.view, PhysicalKeyboardKey.keyV),
          },
        ),
        on: windows,
      );

      expect(
        _item(showCall(), currentAppLocalizations.openApp(appName))['detail'],
        'Ctrl+Shift+V',
      );
    });

    test('never pushes a tray title', () async {
      await windows.updateTitle(showTrayTitle: true, traffic: const Traffic());

      expect(calls.where((call) => call.method == 'setTitle'), isEmpty);
    });
  });
}
