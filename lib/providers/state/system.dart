part of '../state.dart';

/// The rules of the rule set in use; empty while the built-in rules apply,
/// which they do until the default config is first edited.
@riverpod
List<Map<String, dynamic>> activeRules(Ref ref) {
  final id = ref.watch(currentRuleSetIdProvider) ?? defaultRuleSetId;
  final sets = ref.watch(ruleSetsProvider);
  for (final set in sets) {
    if (set.id == id) {
      return set.rules;
    }
  }
  return const [];
}

/// Everything the generated config is built from besides the profile itself.
@riverpod
({
  CoreConfig config,
  RouteMode routeMode,
  List<String> authentication,
  List<Map<String, dynamic>> rules,
})
configInputs(Ref ref) {
  final routeMode = ref.watch(
    networkSettingProvider.select((state) => state.routeMode),
  );
  final authentication = ref.watch(
    networkSettingProvider.select((state) => state.authentication.credentials),
  );
  final config = ref.watch(coreSettingProvider);
  final rules = ref.watch(activeRulesProvider);
  return (
    config: config,
    routeMode: routeMode,
    authentication: authentication,
    rules: rules,
  );
}

@riverpod
TrayState trayState(Ref ref) {
  final isStart = ref.watch(runTimeProvider.select((state) => state != null));
  final coreConfig = ref.watch(
    coreSettingProvider.select(
      (state) => (mode: state.mode, tunEnable: state.tun.enable),
    ),
  );
  final appSetting = ref.watch(
    appSettingProvider.select(
      (state) => (showTrayTitle: state.showTrayTitle, trayMode: state.trayMode),
    ),
  );
  final groups = ref.watch(currentGroupsStateProvider).value;
  final selectedMap = ref.watch(selectedMapProvider);
  final safeMode = ref.watch(safeModeProvider);
  final hotKeys = _trayHotKeys(ref);

  return TrayState(
    mode: coreConfig.mode,
    tunEnable: coreConfig.tunEnable,
    isStart: isStart,
    groups: groups,
    selectedMap: selectedMap,
    showTrayTitle: appSetting.showTrayTitle,
    safeMode: safeMode,
    trayMode: appSetting.trayMode,
    hotKeys: hotKeys,
  );
}

Map<HotAction, HotKeyAction> _trayHotKeys(Ref ref) {
  final failures = ref.watch(hotKeyFailuresProvider);
  return {
    for (final hotKeyAction in ref.watch(hotKeyActionsProvider))
      if (isValidHotKey(hotKeyAction.modifiers, hotKeyAction.key) &&
          !failures.containsKey(hotKeyAction.action))
        hotKeyAction.action: hotKeyAction,
  };
}

/// Measured delays of the proxies the tray lists, by group and then proxy
/// name. Resolved like a proxy card, so a nested group shows its selection.
@riverpod
Map<String, Map<String, int>> trayDelays(Ref ref) {
  final delayMap = ref.watch(delayDataSourceProvider);
  if (delayMap.isEmpty) {
    return const {};
  }
  final groups = ref.watch(currentGroupsStateProvider).value;
  final allGroups = ref.watch(groupsProvider);
  final selectedMap = ref.watch(selectedMapProvider);
  final defaultTestUrl = ref.watch(
    appSettingProvider.select((state) => state.testUrl),
  );
  final delays = <String, Map<String, int>>{};
  for (final group in groups) {
    final testUrl = group.testUrl.takeFirstValid([defaultTestUrl]);
    final groupDelays = <String, int>{};
    for (final proxy in group.all) {
      final delay = computeProxyDelayState(
        proxyName: proxy.name,
        testUrl: testUrl,
        groups: allGroups,
        selectedMap: selectedMap,
        delayMap: delayMap,
      ).delay;
      if (delay != 0) {
        groupDelays[proxy.name] = delay;
      }
    }
    if (groupDelays.isNotEmpty) {
      delays[group.name] = groupDelays;
    }
  }
  return delays;
}

/// Proxies the tray lists whose delay test is queued or running, by group.
/// Keyed like [trayDelays], so a nested group counts as its resolved proxy.
@riverpod
Map<String, Set<String>> trayPendingDelays(Ref ref) {
  final pending = ref.watch(pendingDelayTestsProvider);
  if (pending.isEmpty) {
    return const {};
  }
  final groups = ref.watch(currentGroupsStateProvider).value;
  final allGroups = ref.watch(groupsProvider);
  final selectedMap = ref.watch(selectedMapProvider);
  final defaultTestUrl = ref.watch(
    appSettingProvider.select((state) => state.testUrl),
  );
  final busy = <String, Set<String>>{};
  for (final group in groups) {
    final groupUrl = group.testUrl.takeFirstValid([defaultTestUrl]);
    for (final proxy in group.all) {
      final state = computeRealSelectedProxyState(
        proxy.name,
        groups: allGroups,
        selectedMap: selectedMap,
      );
      final key = delayTestKey(
        state.testUrl.takeFirstValid([groupUrl]),
        state.proxyName,
      );
      if (pending.containsKey(key)) {
        (busy[group.name] ??= {}).add(proxy.name);
      }
    }
  }
  return busy;
}

@riverpod
TrayTitleState trayTitleState(Ref ref) {
  final showTrayTitle = ref.watch(
    appSettingProvider.select((state) => state.showTrayTitle),
  );
  final traffic = ref.watch(
    trafficsProvider.select((state) => state.list.safeLast(const Traffic())),
  );
  return TrayTitleState(showTrayTitle: showTrayTitle, traffic: traffic);
}

@riverpod
VpnState vpnState(Ref ref) {
  final vpnProps = ref.watch(vpnSettingProvider);
  final stack = ref.watch(
    coreSettingProvider.select((state) => state.tun.stack),
  );
  return VpnState(stack: stack, vpnProps: vpnProps);
}

@riverpod
PackageListSelectorState packageListSelectorState(Ref ref) {
  final packages = ref.watch(packagesProvider);
  final accessControlProps = ref.watch(
    vpnSettingProvider.select((state) => state.accessControlProps),
  );
  return PackageListSelectorState(
    packages: packages,
    accessControlProps: accessControlProps,
  );
}

@riverpod
HotKeyAction getHotKeyAction(Ref ref, HotAction hotAction) {
  return ref.watch(
    hotKeyActionsProvider.select((state) {
      final index = state.indexWhere((item) => item.action == hotAction);
      return index != -1 ? state[index] : HotKeyAction(action: hotAction);
    }),
  );
}

@riverpod
bool shouldPatchSystemDns(Ref ref) {
  final autoSetSystemDns = ref.watch(
    networkSettingProvider.select((state) => state.autoSetSystemDns),
  );
  if (!autoSetSystemDns || ref.watch(safeModeProvider)) {
    return false;
  }
  final isStart = ref.watch(runTimeProvider.select((state) => state != null));
  final tunEnable = ref.watch(
    coreSettingProvider.select((state) => state.tun.enable),
  );
  final authorizationState = ref.watch(authorizedTunEnableProvider);
  return isStart &&
      tunEnable &&
      authorizationState == TunAuthorizationState.authorized;
}

@riverpod
SharedState sharedState(Ref ref) {
  ref.watch(loadedLocaleProvider);
  final currentProfile = ref.watch(
    currentProfileProvider.select(
      (state) => CurrentProfileSelectorState(label: state?.label ?? ''),
    ),
  );
  final appSetting = ref.watch(
    appSettingProvider.select(
      (state) => (
        onlyStatisticsProxy: state.onlyStatisticsProxy,
        showStopAction: state.showNotificationStopAction,
        crashlytics: state.crashlytics,
        testUrl: state.testUrl,
      ),
    ),
  );
  final networkSetting = ref.watch(
    networkSettingProvider.select(
      (state) => (
        bypassDomain: state.bypassDomain,
        routeMode: state.routeMode,
        authenticated: state.authentication.credentials.isNotEmpty,
      ),
    ),
  );
  final coreConfig = ref.watch(
    coreSettingProvider.select(
      (state) => (
        stack: state.tun.stack.name,
        mixedPort: state.mixedPort,
        routeAddress: state.tun.resolveRouteAddress(networkSetting.routeMode),
      ),
    ),
  );
  final vpnSetting = ref.watch(vpnSettingProvider);
  final safeMode = ref.watch(safeModeProvider);
  final currentProfileName = currentProfile.label;
  final onlyStatisticsProxy = appSetting.onlyStatisticsProxy;
  final crashlytics = appSetting.crashlytics;
  final testUrl = appSetting.testUrl;
  final stack = coreConfig.stack;
  final port = coreConfig.mixedPort;
  return SharedState(
    currentProfileName: currentProfileName,
    onlyStatisticsProxy: onlyStatisticsProxy,
    showStopAction: appSetting.showStopAction,
    stopText: currentAppLocalizations.stop,
    crashlytics: crashlytics,
    stopTip: currentAppLocalizations.stopVpn,
    startTip: currentAppLocalizations.startVpn,
    localNetworkTip: currentAppLocalizations.localNetworkDeniedTip,
    setupParams: SetupParams(testUrl: testUrl),
    vpnOptions: VpnOptions(
      enable: vpnSetting.enable && !safeMode,
      stack: stack,
      // VpnService.setHttpProxy cannot carry credentials, so an authenticated
      // mixed port must not be declared as the system HTTP proxy; traffic
      // still flows through TUN.
      systemProxy:
          vpnSetting.systemProxy && !networkSetting.authenticated && !safeMode,
      port: port,
      ipv6: vpnSetting.ipv6,
      dnsHijacking: vpnSetting.dnsHijacking,
      accessControlProps: vpnSetting.accessControlProps,
      allowBypass: vpnSetting.allowBypass,
      bypassDomain: networkSetting.bypassDomain,
      routeAddress: coreConfig.routeAddress,
    ),
  );
}

@riverpod
class AccessControlState extends _$AccessControlState
    with AutoDisposeNotifierMixin {
  @override
  AccessControlProps build() => const AccessControlProps();
}

@riverpod
bool suspend(Ref ref) {
  final currentSSID = ref.watch(currentSSIDProvider);
  final excludeSSIDs = ref.watch(excludeSSIDsProvider);
  return excludeSSIDs.contains(currentSSID);
}
