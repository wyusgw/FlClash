part of '../action.dart';

@Riverpod(keepAlive: true)
class ProfilesAction extends _$ProfilesAction {
  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  void build() {}

  void updateCurrentSelectedMap(String groupName, String proxyName) {
    final currentProfile = ref.read(currentProfileProvider);
    if (currentProfile != null &&
        currentProfile.selectedMap[groupName] != proxyName) {
      final selectedMap = Map<String, String>.from(currentProfile.selectedMap)
        ..[groupName] = proxyName;
      ref
          .read(profilesProvider.notifier)
          .put(currentProfile.copyWith(selectedMap: selectedMap));
    }
  }

  Future<void> deleteProfile(int id) async {
    await ref.read(profilesProvider.notifier).del(id);
    await clearEffect(id);
    final currentProfileId = ref.read(currentProfileIdProvider);
    if (currentProfileId == id) {
      final profiles = ref.read(profilesProvider);
      if (profiles.isNotEmpty) {
        final updateId = profiles.first.id;
        ref.read(currentProfileIdProvider.notifier).value = updateId;
      } else {
        ref.read(currentProfileIdProvider.notifier).value = null;
        unawaited(ref.read(setupActionProvider.notifier).setRunning(false));
      }
    }
    _notifySuccess(currentAppLocalizations.deleteSuccess);
  }

  void _notifySuccess(String text) {
    dialogs.showNotifier(text, level: MessageLevel.success);
  }

  Future<String> validateConfigWithData(String data) async {
    return _core.validateConfigWithData(data);
  }

  Future<void> autoUpdateProfiles() async {
    for (final profile in ref.read(profilesProvider)) {
      if (!profile.autoUpdate) continue;
      final isNotNeedUpdate = profile.lastUpdateDate
          ?.add(profile.autoUpdateDuration)
          .isBeforeNow;
      if (isNotNeedUpdate == false || profile.type == ProfileType.file) {
        continue;
      }
      try {
        await updateProfile(profile);
      } catch (e) {
        commonPrint.log(compactError(e), logLevel: LogLevel.warning);
      }
    }
  }

  void putProfile(Profile profile) {
    ref.read(profilesProvider.notifier).put(profile);
    if (ref.read(currentProfileIdProvider) != null) return;
    ref.read(currentProfileIdProvider.notifier).value = profile.id;
  }

  Future<void> updateProfiles() async {
    for (final profile in ref.read(profilesProvider)) {
      if (profile.type == ProfileType.file) continue;
      await updateProfile(profile, showLoading: true);
    }
  }

  Future<void> updateProfile(
    Profile profile, {
    bool showLoading = false,
  }) async {
    final operation = showLoading
        ? ref.read(updatingKeysProvider.notifier).start(profile.updatingKey)
        : null;
    try {
      ref.read(profilesProvider.notifier).put(profile);
      final newProfile = await profile.update(
        validate: (path) => _core.validateConfig(path),
      );
      ref.read(profilesProvider.notifier).put(newProfile);
      if (profile.id == ref.read(currentProfileIdProvider)) {
        ref
            .read(setupActionProvider.notifier)
            .applyProfileDebounce(silence: true);
      }
      if (showLoading) {
        _notifySuccess(currentAppLocalizations.updateSuccess);
      }
    } finally {
      if (operation != null) {
        ref
            .read(updatingKeysProvider.notifier)
            .stop(profile.updatingKey, operation);
      }
    }
  }

  /// Adds a server typed in by hand to the local profile: the one in use when
  /// it is a file, else the first file profile, else a new one.
  Future<void> addManualNode(Map<String, dynamic> outbound) async {
    final current = ref.read(currentProfileProvider);
    final target =
        (current?.type == ProfileType.file ? current : null) ??
        ref
            .read(profilesProvider)
            .where((profile) => profile.type == ProfileType.file)
            .firstOrNull ??
        Profile.normal(label: currentAppLocalizations.localProfile);
    final saved = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        final text = await readTextFileTask(
          await appPath.getProfilePath(target.id.toString()),
        );
        final nodes = text == null
            ? const <Map<String, dynamic>>[]
            : parseSubscription(text);
        return target.saveFile(
          Uint8List.fromList(
            utf8.encode(
              json.encode({
                'outbounds': [...nodes, outbound],
              }),
            ),
          ),
          validate: (path) => _core.validateConfig(path),
        );
      },
      title: currentAppLocalizations.addProfile,
    );
    if (saved == null) return;
    putProfile(saved);
    if (saved.id == ref.read(currentProfileIdProvider)) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
    }
    _notifySuccess(currentAppLocalizations.addSuccess);
  }

  /// The outbound of the node [tag] in [profile], as the profile stores it.
  Future<Map<String, dynamic>?> readNodeOutbound(
    Profile profile,
    String tag,
  ) async {
    final text = await readTextFileTask(
      await appPath.getProfilePath(profile.id.toString()),
    );
    if (text == null) return null;
    for (final node in parseSubscription(text)) {
      if (node['tag'] == tag) return node;
    }
    return null;
  }

  /// Puts [outbound] where the node [tag] of [profile] stood. A node that is
  /// renamed keeps being the one chosen when it was.
  Future<void> replaceNode(
    Profile profile,
    String tag,
    Map<String, dynamic> outbound,
  ) async {
    final appLocalizations = currentAppLocalizations;
    final text = await readTextFileTask(
      await appPath.getProfilePath(profile.id.toString()),
    );
    final nodes = text == null
        ? <Map<String, dynamic>>[]
        : parseSubscription(text);
    final index = nodes.indexWhere((node) => node['tag'] == tag);
    final newTag = '${outbound['tag']}';
    if (index == -1) return;
    if (newTag != tag && nodes.any((node) => node['tag'] == newTag)) {
      dialogs.showNotifier(
        appLocalizations.existsTip(appLocalizations.name),
        level: MessageLevel.error,
      );
      return;
    }
    nodes[index] = outbound;
    final saved = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () => profile.saveFile(
        Uint8List.fromList(utf8.encode(json.encode({'outbounds': nodes}))),
        validate: (path) => _core.validateConfig(path),
      ),
      title: appLocalizations.save,
    );
    if (saved == null) return;
    final selectedMap = {...saved.selectedMap};
    if (selectedMap[nodeGroupName] == tag) {
      selectedMap[nodeGroupName] = newTag;
    }
    putProfile(saved.copyWith(selectedMap: selectedMap));
    if (saved.id == ref.read(currentProfileIdProvider)) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
    }
    _notifySuccess(appLocalizations.saveSuccess);
  }

  Future<void> addProfileFormFile() async {
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile == null) return;
    final bytes = await platformFile.readBytes();
    globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    ref.read(currentPageLabelProvider.notifier).toProfiles();
    final profile = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        return Profile.normal(
          label: platformFile.name,
        ).saveFile(bytes, validate: (path) => _core.validateConfig(path));
      },
      title: currentAppLocalizations.addProfile,
    );
    if (profile != null) {
      putProfile(profile);
      _notifySuccess(currentAppLocalizations.addSuccess);
    }
  }

  Future<void> addProfileFormURL(String url, {String? label}) async {
    if (globalState.navigatorKey.currentState?.canPop() ?? false) {
      globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    ref.read(currentPageLabelProvider.notifier).value = PageLabel.profiles;
    final profile = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        return Profile.normal(
          label: label,
          url: url,
        ).update(validate: (path) => _core.validateConfig(path));
      },
      title: currentAppLocalizations.addProfile,
    );
    if (profile != null) {
      putProfile(profile);
      _notifySuccess(currentAppLocalizations.addSuccess);
    }
  }

  void setProfileAndAutoApply(Profile profile) {
    ref.read(profilesProvider.notifier).put(profile);
    if (profile.id == ref.read(currentProfileIdProvider)) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
    }
  }

  Future<void> addProfileFormQrCode() async {
    final url = await globalState.safeRun(picker.pickerConfigQRCode);
    if (url == null) return;
    unawaited(addProfileFormURL(url));
  }

  void reorder(List<Profile> profiles) {
    ref.read(profilesProvider.notifier).reorder(profiles);
  }

  Future<void> clearEffect(int profileId) async {
    final profilePath = await appPath.getProfilePath(profileId.toString());
    final profileFile = File(profilePath);
    final isExists = await profileFile.exists();
    if (isExists) {
      await profileFile.safeDelete(recursive: true);
    }
  }
}
