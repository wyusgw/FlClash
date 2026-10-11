// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:fl_clash/common/system.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

enum SupportPlatform {
  Windows,
  MacOS,
  Linux,
  Android;

  static SupportPlatform get currentPlatform {
    if (system.isWindows) {
      return SupportPlatform.Windows;
    } else if (system.isMacOS) {
      return SupportPlatform.MacOS;
    } else if (Platform.isLinux) {
      return SupportPlatform.Linux;
    } else if (system.isAndroid) {
      return SupportPlatform.Android;
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }
}

const desktopPlatforms = [
  SupportPlatform.Linux,
  SupportPlatform.MacOS,
  SupportPlatform.Windows,
];

enum GroupType {
  @JsonValue('select')
  Selector('select'),
  @JsonValue('url-test')
  URLTest('url-test'),
  @JsonValue('fallback')
  Fallback('fallback'),
  @JsonValue('load-balance')
  LoadBalance('load-balance'),
  @JsonValue('relay')
  Relay('relay');

  final String value;

  const GroupType(this.value);

  static GroupType parse(String type) {
    return switch (type.toLowerCase()) {
      'url-test' || 'urltest' => URLTest,
      'select' || 'selector' => Selector,
      'fallback' => Fallback,
      'load-balance' || 'loadbalance' => LoadBalance,
      'relay' => Relay,
      String() => throw UnimplementedError(),
    };
  }

  /// The core refuses a relay group, so it stays parseable but unofferable.
  static List<GroupType> get selectableValues =>
      values.where((item) => item != Relay).toList();
}

extension GroupTypeExtension on GroupType {
  static List<String> get valueList =>
      GroupType.values.map((e) => e.toString().split('.').last).toList();

  bool get isComputedSelected {
    return [GroupType.URLTest, GroupType.Fallback].contains(this);
  }

  static GroupType? getGroupType(String value) {
    final index = GroupTypeExtension.valueList.indexOf(value);
    if (index == -1) return null;
    return GroupType.values[index];
  }
}

enum DelayTestPhase { queued, running }

enum Mode { rule, global, direct }

enum ViewMode { mobile, laptop, desktop }

enum LogLevel { debug, info, warning, error, silent }

enum RecordTone { muted, neutral, warning, error }

extension RecordToneExt on RecordTone {
  Color? accentColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      RecordTone.warning => colorScheme.tertiary,
      RecordTone.error => colorScheme.error,
      RecordTone.muted || RecordTone.neutral => null,
    };
  }

  Color? tintColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      RecordTone.warning => colorScheme.tertiaryContainer.withValues(
        alpha: 0.2,
      ),
      RecordTone.error => colorScheme.errorContainer.withValues(alpha: 0.2),
      RecordTone.muted || RecordTone.neutral => null,
    };
  }

  Color labelColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      RecordTone.muted => colorScheme.outline,
      RecordTone.neutral => colorScheme.onSurfaceVariant,
      RecordTone.warning => colorScheme.onTertiaryContainer,
      RecordTone.error => colorScheme.onErrorContainer,
    };
  }

  Color labelContainerColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      RecordTone.muted => colorScheme.surfaceContainerHigh,
      RecordTone.neutral => colorScheme.surfaceContainerHighest,
      RecordTone.warning => colorScheme.tertiaryContainer,
      RecordTone.error => colorScheme.errorContainer,
    };
  }
}

enum MessageLevel { info, success, warning, error }

extension MessageLevelExt on MessageLevel {
  Glyph get glyph {
    return switch (this) {
      MessageLevel.info => AppGlyphs.info,
      MessageLevel.success => AppGlyphs.check,
      MessageLevel.warning => AppGlyphs.warning,
      MessageLevel.error => AppGlyphs.close,
    };
  }

  Duration get duration {
    return switch (this) {
      MessageLevel.info || MessageLevel.success => const Duration(seconds: 3),
      MessageLevel.warning => const Duration(seconds: 5),
      MessageLevel.error => const Duration(seconds: 6),
    };
  }
}

enum TrafficUnit { B, KB, MB, GB, TB }

enum NavigationItemMode { mobile, desktop, more, moreFull }

enum Network { tcp, udp }

enum ProxiesSortType { none, delay, name }

enum TunStack { gvisor, system, mixed, mips }

enum AccessControlMode { acceptSelected, rejectSelected }

enum AccessSortType { none, name, time }

enum ProfileType { file, url }

enum ResultType {
  @JsonValue(0)
  success,
  @JsonValue(-1)
  error,
}

enum CoreEventType { log, delay, crash, routeChanged }

enum InvokeMessageType { protect, process }

enum RestoreOption { all, onlyProfiles }

enum CommonCardType { plain, filled }

enum ProxiesLayout { loose, standard, tight }

enum ProxyCardType { expand, shrink, min }

enum KeyboardModifier {
  alt([PhysicalKeyboardKey.altLeft, PhysicalKeyboardKey.altRight]),
  capsLock([PhysicalKeyboardKey.capsLock]),
  control([PhysicalKeyboardKey.controlLeft, PhysicalKeyboardKey.controlRight]),
  fn([PhysicalKeyboardKey.fn]),
  meta([PhysicalKeyboardKey.metaLeft, PhysicalKeyboardKey.metaRight]),
  shift([PhysicalKeyboardKey.shiftLeft, PhysicalKeyboardKey.shiftRight]);

  final List<PhysicalKeyboardKey> physicalKeys;

  const KeyboardModifier(this.physicalKeys);
}

enum HotAction {
  start,
  view,
  mode,
  proxy,
  tun,
  ruleMode,
  globalMode,
  directMode,
  delayTest,
  updateProfiles,
  copyEnv,
  exit,
}

enum ProxiesIconStyle { filled, plain, hidden }

enum FontFamily {
  twEmoji('Twemoji'),
  jetBrainsMono('JetBrainsMono');

  final String value;

  const FontFamily(this.value);
}

enum EditorFontSize {
  standard(16),
  large(18),
  extraLarge(20);

  final double value;

  const EditorFontSize(this.value);
}

enum RouteMode { bypassPrivate, config }

enum AuthorizeCode { none, success, error }

enum TunAuthorizationState { none, authorized, unauthorized }

enum FunctionTag {
  updateConfig,
  setupConfig,
  updateGroups,
  applyProfile,
  savePreferences,
  changeProxy,
  handleWill,
  updateDelay,
  vpnTip,
  autoLaunch,
  updatePageIndex,
  pageChange,
  proxiesTabChange,
  logs,
  requests,
  dnsQueries,
  autoScrollToEnd,
  loadedProvider,
  saveSharedFile,
  removeProxy,
  suspend,
  coreErrorNotifier,
  reloadPackages,
}

enum IpType { residential, mobile, business, hosting }

enum IpQualityLevel { good, normal, risky }

enum IpQualitySource {
  identMe('ident.me'),
  ipApiCom('ip-api.com'),
  ipQuery('ipquery.io'),
  ipLocate('iplocate.io'),
  proxyCheck('proxycheck.io'),
  ipApiIs('ipapi.is');

  const IpQualitySource(this.label);

  final String label;
}

enum IpQualitySourceStatus { noType, timeout, rateLimited, failed, ipMismatch }

enum PageLabel { dashboard, proxies, profiles, tools, logs }

enum RestoreStrategy { compatible, override }

enum TabAnimation { slide, fade }

enum Language { yaml, javaScript, json }

enum ScrollPositionCacheKey { tools, profiles, proxiesList, proxiesTabList }

enum QueryTag { proxies, access }

enum LoadingTag {
  profiles,
  scripts,
  backup_restore,
  access,
  proxies,
  batteryOptimization,
  checkUpdate,
}

enum CoreStatus { connecting, connected, disconnected }

/// How a node's latency is measured: a TCP connect to its server, or a URL
/// request through it.
enum DelayTestMethod { tcp, url }

/// How the app shows itself in the menu bar: with a Dock icon while its
/// window is open, as the menu bar item alone, or not at all.
enum TrayMode { embedded, standalone, off }

enum UpdatingScope { core, local }

enum ItemPosition {
  start,
  middle,
  end,
  startAndEnd;

  static ItemPosition get(int index, int length) {
    ItemPosition position = ItemPosition.middle;
    if (length == 1) {
      position = ItemPosition.startAndEnd;
    } else if (index == length - 1) {
      position = ItemPosition.end;
    } else if (index == 0) {
      position = ItemPosition.start;
    }
    return position;
  }

  static ItemPosition calculateVisualPosition<T>(
    int currentIndex,
    List<T> items,
    Set<T> deletedItems,
  ) {
    if (deletedItems.isEmpty) {
      return ItemPosition.get(currentIndex, items.length);
    }
    final currentItem = items[currentIndex];
    if (deletedItems.contains(currentItem)) {
      return ItemPosition.middle;
    }
    final int visualLength = items.length - deletedItems.length;
    if (visualLength <= 0) return ItemPosition.middle;
    int deletedCountBeforeMe = 0;
    for (int i = 0; i < currentIndex; i++) {
      if (deletedItems.contains(items[i])) {
        deletedCountBeforeMe++;
      }
    }
    final int visualIndex = currentIndex - deletedCountBeforeMe;
    return ItemPosition.get(visualIndex, visualLength);
  }
}
