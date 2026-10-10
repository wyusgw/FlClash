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
