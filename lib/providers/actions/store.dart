part of '../action.dart';

@Riverpod(keepAlive: true)
class StoreAction extends _$StoreAction {
  @override
  void build() {}

  Future<void> shakingStore() async {
    final profileIds = ref.read(profilesProvider).map((item) => item.id);
    final pathsToDelete = await shakingProfileTask((profileIds: profileIds));
    await Future.wait(pathsToDelete.map(safeDeletePath));
  }

  void savePreferencesDebounce() {
    debouncer.call(FunctionTag.savePreferences, () async {
      await preferences.saveConfig(ref.read(configProvider));
    });
  }

  /// Puts the core, network and VPN settings back to their defaults and has
  /// the profile in use rebuilt from them.
  void resetCoreSettings() {
    ref.read(coreSettingProvider.notifier).value = defaultCoreConfig;
    ref.read(networkSettingProvider.notifier).value = defaultNetworkProps;
    ref.read(vpnSettingProvider.notifier).value = defaultVpnProps;
    ref.read(setupActionProvider.notifier).applyProfileDebounce(force: true);
  }

  Future handleClear() async {
    debouncer.cancel(FunctionTag.savePreferences);

    await preferences.clearPreferences();
    commonPrint.log('clear preferences');
    await database.close();
    await File(await appPath.databasePath).safeDelete(recursive: true);
    await Directory(await appPath.profilesPath).safeDelete(recursive: true);
    unawaited(ref.read(systemActionProvider.notifier).handleExit(false));
  }
}
