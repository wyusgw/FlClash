import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:tray/tray.dart';

import 'app_localizations.dart';
import 'l10n_labels.dart';
import 'app_ports.dart';
import 'constant.dart';
import 'keyboard.dart';
import 'provider_reader.dart';
import 'string.dart';
import 'system.dart';
import 'window.dart';
import 'xray_config.dart';

class AppTray implements TrayPort {
  static AppTray? _instance;

  final bool isMacOS;
  final bool isWindows;

  bool _isShutDown = false;
  bool _isHidden = false;
  AppTray._internal({required this.isMacOS, required this.isWindows});

  factory AppTray() {
    _instance ??= AppTray._internal(
      isMacOS: system.isMacOS,
      isWindows: system.isWindows,
    );
    return _instance!;
  }

  @visibleForTesting
  factory AppTray.forPlatform({
    required bool isMacOS,
    required bool isWindows,
  }) {
    return AppTray._internal(isMacOS: isMacOS, isWindows: isWindows);
  }

  String get _trayIconSuffix {
    return isWindows ? 'ico' : 'png';
  }

  String get _trayIconDir {
    if (isWindows) {
      return 'assets/images/tray/windows';
    }
    return isMacOS ? 'assets/images/tray/macos' : 'assets/images/tray/unix';
  }

  String getTrayIcon({
    required bool isStart,
    required bool tunEnable,
    required bool safeMode,
  }) {
    final status = switch ((safeMode, isMacOS || !isStart, tunEnable)) {
      (true, _, _) => 4,
      (false, true, _) => 1,
      (false, false, false) => 2,
      (false, false, true) => 3,
    };
    return '$_trayIconDir/status_$status.$_trayIconSuffix';
  }

  @override
  Future<void> shutdown() async {
    _isShutDown = true;
    await Tray.instance.hide();
  }

  @override
  Future<void> update({
    required TrayState trayState,
    required Traffic traffic,
    required ProviderReader read,
  }) async {
    if (_isShutDown) {
      return;
    }
    _isHidden = trayState.trayMode == TrayMode.off;
    if (_isHidden) {
      await Tray.instance.hide();
      return;
    }
    await Tray.instance.show(
      TraySpec(
        icon: TrayIcon.asset(
          getTrayIcon(
            isStart: trayState.isStart,
            tunEnable: trayState.tunEnable,
            safeMode: trayState.safeMode,
          ),
          isTemplate: isMacOS,
          size: isMacOS ? 18 : 16,
        ),
        toolTip: trayState.safeMode
            ? currentAppLocalizations.safeModeAppTitle(appName)
            : appName,
        menu: _buildMenu(trayState: trayState, read: read),
      ),
    );
    await updateTitle(showTrayTitle: trayState.showTrayTitle, traffic: traffic);
  }

  Future<void> updateTitle({
    required bool showTrayTitle,
    required Traffic traffic,
  }) async {
    if (_isShutDown || _isHidden || !isMacOS) {
      return;
    }
    await Tray.instance.setTitle(showTrayTitle ? traffic.trayTitle : '');
  }

  List<TrayMenuItem> _buildMenu({
    required TrayState trayState,
    required ProviderReader read,
  }) {
    final commonAction = read(commonActionProvider.notifier);
    final systemAction = read(systemActionProvider.notifier);
    final setupAction = read(setupActionProvider.notifier);
    final proxiesAction = read(proxiesActionProvider.notifier);
    final appLocalizations = currentAppLocalizations;
    String? shortcut(HotAction action) => _shortcut(trayState, action);
    TrayShortcut? keyEquivalent(HotAction action) =>
        _keyEquivalent(trayState, action);
    final nodeGroup = trayState.groups.getGroup(nodeGroupName);
    final pendingNodes = nodeGroup == null
        ? const <String>{}
        : read(trayPendingDelaysProvider)[nodeGroup.name] ?? const {};
    // The macOS menu is the plain one the system draws: no delays or spinners.
    final shownDelays = isMacOS || nodeGroup == null
        ? const <String, int>{}
        : read(trayDelaysProvider)[nodeGroup.name] ?? const {};
    final shownPending = isMacOS ? const <String>{} : pendingNodes;
    final selectedNode = nodeGroup == null
        ? ''
        : read(
            selectedProxyNameProvider(nodeGroupName),
          ).takeFirstValid([nodeGroup.all.firstOrNull?.name]);

    return [
      TrayMenuAction(
        label: appLocalizations.openApp(appName),
        detail: shortcut(HotAction.view),
        shortcut: keyEquivalent(HotAction.view),
        onSelected: () {
          window?.show();
        },
      ),
      TrayMenuCheckbox(
        label: !trayState.isStart
            ? appLocalizations.notConnected
            : _withValue(appLocalizations.connected, selectedNode),
        checked: trayState.isStart,
        detail: shortcut(HotAction.start),
        shortcut: keyEquivalent(HotAction.start),
        onSelected: commonAction.toggleRunning,
      ),
      const TrayMenuSeparator(),
      TrayMenuSubmenu(
        label: _withValue(appLocalizations.globalRouting, trayState.mode.label),
        detail: shortcut(HotAction.mode),
        items: [
          for (final mode in Mode.values)
            TrayMenuCheckbox(
              label: mode.label,
              checked: mode == trayState.mode,
              detail: shortcut(_modeHotAction(mode)),
              shortcut: keyEquivalent(_modeHotAction(mode)),
              onSelected: () {
                setupAction.changeMode(mode);
              },
            ),
        ],
      ),
      if (nodeGroup != null) ...[
        _buildServerSubmenu(
          nodeGroup,
          selectedName: selectedNode,
          delays: shownDelays,
          pending: shownPending,
          onSelected: (proxyName) {
            proxiesAction.changeProxy(
              groupName: nodeGroup.name,
              proxyName: proxyName,
            );
          },
        ),
        TrayMenuAction(
          label: appLocalizations.connectivityTest,
          detail: shortcut(HotAction.delayTest),
          busy: shownPending.isNotEmpty,
          shortcut: keyEquivalent(HotAction.delayTest),
          onSelected: () {
            if (pendingNodes.isEmpty) {
              proxiesAction.delayTestGroups([nodeGroup]);
            }
          },
        ),
      ],
      TrayMenuCheckbox(
        label: appLocalizations.tun,
        checked: trayState.tunEnable,
        detail: shortcut(HotAction.tun),
        shortcut: keyEquivalent(HotAction.tun),
        onSelected: systemAction.updateTun,
      ),
      if (isMacOS) ...[
        const TrayMenuSeparator(),
        TrayMenuAction(
          label: appLocalizations.toggleSpeedView,
          detail: shortcut(HotAction.speedView),
          shortcut: keyEquivalent(HotAction.speedView),
          onSelected: commonAction.updateSpeedStatistics,
        ),
      ],
      const TrayMenuSeparator(),
      TrayMenuAction(
        label: isMacOS
            ? appLocalizations.quitFromMenuBar
            : appLocalizations.exit,
        detail: shortcut(HotAction.exit),
        shortcut: keyEquivalent(HotAction.exit),
        onSelected: () {
          systemAction.handleExit();
        },
      ),
    ];
  }

  HotAction _modeHotAction(Mode mode) {
    return switch (mode) {
      Mode.rule => HotAction.ruleMode,
      Mode.global => HotAction.globalMode,
      Mode.direct => HotAction.directMode,
    };
  }

  TrayShortcut? _keyEquivalent(TrayState trayState, HotAction action) {
    final hotKey = trayState.hotKeys[action];
    final key = hotKey?.key;
    if (!isMacOS || hotKey == null || key == null) {
      return null;
    }
    final character = menuKeyEquivalent(key);
    final modifiers = {
      for (final modifier in hotKey.modifiers)
        switch (modifier) {
          KeyboardModifier.control => TrayShortcutModifier.control,
          KeyboardModifier.alt => TrayShortcutModifier.option,
          KeyboardModifier.shift => TrayShortcutModifier.shift,
          KeyboardModifier.meta => TrayShortcutModifier.command,
          KeyboardModifier.capsLock || KeyboardModifier.fn => null,
        },
    };
    if (character == null || modifiers.contains(null)) {
      return null;
    }
    return TrayShortcut(
      key: character,
      modifiers: modifiers.whereType<TrayShortcutModifier>().toSet(),
    );
  }

  String _withValue(String label, String value) {
    return value.isEmpty ? label : '$label: $value';
  }

  String? _shortcut(TrayState trayState, HotAction action) {
    final hotKey = trayState.hotKeys[action];
    final key = hotKey?.key;
    if (hotKey == null || key == null) {
      return null;
    }
    return ShortcutLabels(
      isMacOS: isMacOS,
      isWindows: isWindows,
    ).text(hotKey.modifiers, key);
  }

  TrayDetailTone? _delayTone(int? delay) {
    if (delay == null) {
      return null;
    }
    return switch (delay) {
      <= 0 => TrayDetailTone.error,
      < 600 => TrayDetailTone.success,
      _ => TrayDetailTone.warning,
    };
  }

  String? _delayText(int? delay) {
    if (delay == null) {
      return null;
    }
    return delay > 0 ? '${delay}ms' : currentAppLocalizations.timeout;
  }

  TrayMenuSubmenu _buildServerSubmenu(
    Group group, {
    required String selectedName,
    required Map<String, int> delays,
    required Set<String> pending,
    required void Function(String proxyName) onSelected,
  }) {
    return TrayMenuSubmenu(
      label: _withValue(currentAppLocalizations.server, selectedName),
      detail: _delayText(delays[selectedName]),
      detailTone: _delayTone(delays[selectedName]),
      busy: pending.contains(selectedName),
      items: [
        for (final proxy in group.all)
          TrayMenuCheckbox(
            label: proxy.name,
            checked: selectedName == proxy.name,
            detail: _delayText(delays[proxy.name]),
            detailTone: _delayTone(delays[proxy.name]),
            busy: pending.contains(proxy.name),
            onSelected: () {
              onSelected(proxy.name);
            },
          ),
      ],
    );
  }
}

final appTray = system.isDesktop ? AppTray() : null;
