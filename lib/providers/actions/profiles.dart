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
      await globalState.safeRun(
        () => updateProfile(profile, showLoading: true),
      );
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
  Profile manualNodeProfile() {
    final current = ref.read(currentProfileProvider);
    return (current?.type == ProfileType.file ? current : null) ??
        ref
            .read(profilesProvider)
            .where((profile) => profile.type == ProfileType.file)
            .firstOrNull ??
        Profile.normal(label: currentAppLocalizations.localProfile);
  }

  Future<List<String>> readNodeTags(Profile profile) async {
    final text = await readTextFileTask(
      await appPath.getProfilePath(profile.id.toString()),
    );
    if (text == null) return const [];
    return [for (final node in parseSubscription(text)) '${node['tag']}'];
  }

  /// Adds [outbound] to [into], or to the profile servers added by hand go to.
  Future<void> addManualNode(
    Map<String, dynamic> outbound, {
    Profile? into,
  }) async {
    final target = into ?? manualNodeProfile();
    final saved = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        final text = await readTextFileTask(
          await appPath.getProfilePath(target.id.toString()),
        );
        final nodes = text == null
            ? <Map<String, dynamic>>[]
            : parseSubscription(text);
        final merged = _mergeManualNode(nodes, outbound);
        if (merged == null) {
          return null;
        }
        return target.saveFile(
          Uint8List.fromList(utf8.encode(json.encode({'outbounds': merged}))),
          validate: (path) => _core.validateConfig(path),
        );
      },
      title: currentAppLocalizations.addProfile,
      silence: true,
    );
    if (saved == null) return;
    putProfile(saved);
    if (saved.id == ref.read(currentProfileIdProvider)) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
    }
    _notifySuccess(currentAppLocalizations.addSuccess);
  }

  /// [nodes] with [outbound] added. A name already taken replaces that node
  /// when overwriting is on, else gets a number when renaming is on, else the
  /// add is refused with null.
  List<Map<String, dynamic>>? _mergeManualNode(
    List<Map<String, dynamic>> nodes,
    Map<String, dynamic> outbound,
  ) {
    final settings = ref.read(appSettingProvider);
    final tag = '${outbound['tag']}';
    final index = nodes.indexWhere((node) => node['tag'] == tag);
    if (index == -1) {
      return [...nodes, outbound];
    }
    if (settings.overwriteExistingNodes) {
      return [...nodes]..[index] = outbound;
    }
    if (!settings.autoRenameNodes) {
      final appLocalizations = currentAppLocalizations;
      dialogs.showNotifier(
        appLocalizations.existsTip(appLocalizations.name),
        level: MessageLevel.error,
      );
      return null;
    }
    final renamed = uniqueLabelFor(
      tag,
      fallback: '${outbound['protocol']}',
      taken: (label) => nodes.any((node) => node['tag'] == label),
    );
    return [
      ...nodes,
      {...outbound, 'tag': renamed},
    ];
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
    if (newTag != tag) {
      for (final (i, node) in nodes.indexed) {
        final stream = node['streamSettings'];
        final sockopt = stream is Map ? stream['sockopt'] : null;
        if (sockopt is Map && sockopt['dialerProxy'] == tag) {
          nodes[i] = {
            ...node,
            'streamSettings': {
              ...stream as Map<String, dynamic>,
              'sockopt': {...sockopt, 'dialerProxy': newTag},
            },
          };
        }
      }
    }
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
      // What the Core is given leaves out a node's country, so a change to it
      // alone does not rebuild the list the setup would.
      await ref.read(proxiesActionProvider.notifier).updateGroups();
    }
    _notifySuccess(appLocalizations.saveSuccess);
  }

  /// A subscription brings the node back on its next update.
  Future<void> deleteNode(Profile profile, String tag) async {
    final appLocalizations = currentAppLocalizations;
    final text = await readTextFileTask(
      await appPath.getProfilePath(profile.id.toString()),
    );
    final nodes = text == null
        ? <Map<String, dynamic>>[]
        : parseSubscription(text);
    final left = [
      for (final node in nodes)
        if (node['tag'] != tag) node,
    ];
    if (left.length == nodes.length) return;
    final saved = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () => profile.saveFile(
        Uint8List.fromList(utf8.encode(json.encode({'outbounds': left}))),
        validate: (path) => _core.validateConfig(path),
      ),
      title: appLocalizations.delete,
    );
    if (saved == null) return;
    final selectedMap = {...saved.selectedMap};
    if (selectedMap[nodeGroupName] == tag) {
      selectedMap.remove(nodeGroupName);
    }
    putProfile(saved.copyWith(selectedMap: selectedMap));
    if (saved.id == ref.read(currentProfileIdProvider)) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
      await ref.read(proxiesActionProvider.notifier).updateGroups();
    }
  }

  Future<void> addProfileFormFile() async {
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile == null) return;
    final bytes = await platformFile.readBytes();
    final profile = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        return Profile.normal(
          label: platformFile.name,
        ).saveFile(bytes, validate: (path) => _core.validateConfig(path));
      },
      title: currentAppLocalizations.addProfile,
      silence: true,
    );
    if (profile != null) {
      putProfile(profile);
      _notifySuccess(currentAppLocalizations.addSuccess);
    }
  }

  Future<void> addProfileFormURL(String url, {String? label}) async {
    final profile = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        return Profile.normal(
          label: label,
          url: url,
        ).update(validate: (path) => _core.validateConfig(path));
      },
      title: currentAppLocalizations.addProfile,
      silence: true,
    );
    if (profile != null) {
      putProfile(profile);
      _notifySuccess(currentAppLocalizations.addSuccess);
    }
  }

  /// Takes in what [readClipboardImport] found: a subscription by its address,
  /// or each share link as a server added by hand.
  Future<void> importFromClipboard(ClipboardImport source) async {
    switch (source) {
      case ClipboardSubscription(:final url):
        await addProfileFormURL(url);
      case ClipboardNodes(:final outbounds):
        for (final outbound in outbounds) {
          await addManualNode(outbound);
        }
    }
  }

  /// Points [profile] at [url] and reads it from there.
  Future<void> changeProfileUrl(Profile profile, String url) async {
    final changed = profile.copyWith(url: url);
    putProfile(changed);
    await updateProfile(changed, showLoading: true);
  }

  /// Keeps [profile] off the home page, or brings it back, without deleting it.
  void setProfileHidden(Profile profile, bool hidden) {
    ref
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            hiddenProfiles: hidden
                ? {...state.hiddenProfiles, profile.id}.toList()
                : [
                    for (final id in state.hiddenProfiles)
                      if (id != profile.id) id,
                  ],
          ),
        );
  }

  /// Brings every hidden profile back to the home page.
  void showHiddenProfiles() {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(hiddenProfiles: const []));
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
