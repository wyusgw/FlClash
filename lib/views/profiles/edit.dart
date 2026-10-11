import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:fl_clash/views/profiles/profiles.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileView extends ConsumerStatefulWidget {
  final Profile profile;

  const EditProfileView({super.key, required this.profile});

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  late final TextEditingController _labelController;
  late final TextEditingController _urlController;
  late final TextEditingController _autoUpdateDurationController;
  late bool _autoUpdate;
  String? _rawText;
  final _fileInfoNotifier = ValueNotifier<FileInfo?>(null);
  late SetupAction _setupAction;
  Uint8List? _fileData;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.profile.label);
    _urlController = TextEditingController(text: widget.profile.url);
    _autoUpdate = widget.profile.autoUpdate;
    _autoUpdateDurationController = TextEditingController(
      text: widget.profile.autoUpdateDuration.inMinutes.toString(),
    );
    _setupAction = ref.read(setupActionProvider.notifier);
    _updateFileInfo();
  }

  Future<void> _updateFileInfo() async {
    final file = await widget.profile.file;
    final fileInfo = await file.getFileInfo();
    if (!mounted) {
      return;
    }
    _fileInfoNotifier.value = fileInfo;
  }

  String? _invalid(AppLocalizations appLocalizations) {
    if (_labelController.text.isEmpty) {
      return appLocalizations.profileNameNullValidationDesc;
    }
    if (widget.profile.type != ProfileType.url) return null;
    final url = _urlController.text;
    if (url.isEmpty) return appLocalizations.profileUrlNullValidationDesc;
    if (!url.isUrl) return appLocalizations.profileUrlInvalidValidationDesc;
    if (_autoUpdate) {
      final interval = _autoUpdateDurationController.text;
      if (interval.isEmpty) {
        return appLocalizations.profileAutoUpdateIntervalNullValidationDesc;
      }
      if (int.tryParse(interval) == null) {
        return appLocalizations.profileAutoUpdateIntervalInvalidValidationDesc;
      }
    }
    return null;
  }

  Future<void> _handleConfirm() async {
    final problem = _invalid(context.appLocalizations);
    if (problem != null) {
      dialogs.showNotifier(problem, level: MessageLevel.error);
      return;
    }
    var profile = widget.profile.copyWith(
      url: _urlController.text,
      label: _labelController.text,
      autoUpdate: _autoUpdate,
      autoUpdateDuration: Duration(
        minutes: int.tryParse(_autoUpdateDurationController.text) ?? 0,
      ),
    );
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final appLocalizations = context.appLocalizations;
    final hasUpdate = widget.profile.url != profile.url;
    if (_fileData != null) {
      if (profile.type == ProfileType.url && _autoUpdate) {
        final res = await dialogs.showMessage(
          title: appLocalizations.tip,
          message: TextSpan(text: appLocalizations.profileHasUpdate),
        );
        if (res == true) {
          profile = profile.copyWith(autoUpdate: false);
        }
      }
      final savedProfile = await globalState.safeRun(
        () => profile.saveFile(
          _fileData!,
          validate: (path) =>
              ref.read(coreHandlerProvider).validateConfig(path),
        ),
      );
      if (savedProfile == null) {
        return;
      }
      profilesAction.putProfile(savedProfile);
    } else if (!hasUpdate) {
      profilesAction.putProfile(profile);
    } else {
      unawaited(
        globalState.safeRun(() async {
          await Future.delayed(commonDuration);
          if (hasUpdate) {
            await profilesAction.updateProfile(profile);
          }
        }),
      );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _setAutoUpdate(bool value) {
    if (_autoUpdate == value) return;
    setState(() {
      _autoUpdate = value;
    });
  }

  Future<void> _handleSaveEdit(BuildContext context, String data) async {
    final message = await globalState.safeRun<String>(() async {
      final message = await ref
          .read(profilesActionProvider.notifier)
          .validateConfigWithData(data);
      return message;
    }, silence: false);
    if (message?.isNotEmpty == true) {
      unawaited(
        dialogs.showMessage(
          title: currentAppLocalizations.tip,
          message: TextSpan(text: message),
        ),
      );
      return;
    }
    if (context.mounted) {
      Navigator.of(context).pop(data);
    }
  }

  Future<void> _editProfileFile() async {
    final title = widget.profile.label.takeFirstValid([
      widget.profile.id.toString(),
    ]);
    final editorPage = EditorPage(
      title: title,
      load: () async => _rawText ??=
          await readTextFileTask(
            await appPath.getProfilePath(widget.profile.id.toString()),
          ) ??
          '',
      onSave: (context, _, content) => _handleSaveEdit(context, content),
      onPop: (context, _, content) async {
        if (content == _rawText) {
          return true;
        }
        final res = await dialogs.showMessage(
          title: title,
          message: TextSpan(text: context.appLocalizations.hasCacheChange),
        );
        if (res == true && context.mounted) {
          unawaited(_handleSaveEdit(context, content));
        } else {
          return true;
        }
        return false;
      },
    );
    final data = await BaseNavigator.push<String>(context, editorPage);
    if (data == null) {
      return;
    }
    _rawText = data;
    _fileData = Uint8List.fromList(utf8.encode(data));
    _fileInfoNotifier.value = _fileInfoNotifier.value?.copyWith(
      size: _fileData?.length ?? 0,
      lastModified: DateTime.now(),
    );
  }

  Future<void> _uploadProfileFile() async {
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile == null) return;
    _fileData = await platformFile.readBytes();
    if (!mounted) {
      return;
    }
    _fileInfoNotifier.value = _fileInfoNotifier.value?.copyWith(
      size: _fileData?.length ?? 0,
      lastModified: DateTime.now(),
    );
  }

  Future<void> _handleBack() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.fileIsUpdate),
    );
    if (res == true) {
      unawaited(_handleConfirm());
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _urlController.dispose();
    _fileInfoNotifier.dispose();
    _autoUpdateDurationController.dispose();
    super.dispose();
    _setupAction.autoApplyProfile();
  }

  Future<void> _delete() async {
    final profile = widget.profile;
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.profile),
      ),
    );
    if (res != true) {
      return;
    }
    await ref.read(profilesActionProvider.notifier).deleteProfile(profile.id);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profile = widget.profile;
    final isUrl = profile.type == ProfileType.url;
    final actions = ProfileActions(profile);
    return FocusTraversalGroup(
      policy: PageTraversalPolicy(),
      child: PageFocusScope(
        child: CommonPopScope(
          onPop: (context) {
            if (_fileData == null) {
              return true;
            }
            _handleBack();
            return false;
          },
          child: GroupedPage(
            title: appLocalizations.edit,
            onBack: () => Navigator.of(context).maybePop(),
            trailing: GroupedBarAction(
              label: appLocalizations.save,
              tooltip: appLocalizations.save,
              onPressed: _handleConfirm,
            ),
            body: ListView(
              padding: EdgeInsets.fromLTRB(
                groupedPageInset,
                13,
                groupedPageInset,
                20 + BottomInsetScope.of(context),
              ),
              children: [
                GroupedSection(
                  children: [
                    GroupedRow(
                      title: appLocalizations.profileType,
                      value: isUrl
                          ? appLocalizations.subscribe
                          : appLocalizations.file,
                      chevron: true,
                      onTap: () => BaseNavigator.push(
                        context,
                        ProfileTypeView(isFile: !isUrl),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: groupedSectionGap),
                GroupedSection(
                  children: [
                    if (isUrl)
                      GroupedFieldRow(
                        label: appLocalizations.url,
                        hint: appLocalizations.required,
                        controller: _urlController,
                        keyboardType: TextInputType.url,
                        inputFormatters: TextInputLimits.limit(
                          TextInputLimits.url,
                        ),
                      ),
                    GroupedFieldRow(
                      label: appLocalizations.name,
                      hint: appLocalizations.required,
                      controller: _labelController,
                      inputFormatters: TextInputLimits.limit(
                        TextInputLimits.name,
                      ),
                    ),
                    if (isUrl)
                      GroupedRow(
                        title: appLocalizations.autoUpdate,
                        trailing: GroupedSwitch(
                          value: _autoUpdate,
                          onChanged: _setAutoUpdate,
                        ),
                      ),
                    if (isUrl && _autoUpdate)
                      GroupedFieldRow(
                        label: appLocalizations.autoUpdateInterval,
                        hint: '',
                        controller: _autoUpdateDurationController,
                        keyboardType: TextInputType.number,
                        inputFormatters: TextInputLimits.digitsOnly(
                          TextInputLimits.interval,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: groupedSectionGap),
                ValueListenableBuilder<FileInfo?>(
                  valueListenable: _fileInfoNotifier,
                  builder: (context, fileInfo, _) => GroupedSection(
                    footer: fileInfo == null
                        ? null
                        : [
                            fileInfo.size.traffic.show,
                            fileInfo.lastModified?.getLastUpdateTimeDesc(
                                  context,
                                ) ??
                                appLocalizations.unknown,
                          ].join(' · '),
                    children: [
                      GroupedRow(
                        leading: const GroupedIcon(AppGlyphs.edit),
                        title: appLocalizations.edit,
                        chevron: true,
                        onTap: _editProfileFile,
                      ),
                      GroupedRow(
                        leading: const GroupedIcon(AppGlyphs.upload),
                        title: appLocalizations.upload,
                        chevron: true,
                        onTap: _uploadProfileFile,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: groupedSectionGap),
                GroupedSection(
                  children: [
                    GroupedRow(
                      leading: const GroupedIcon(AppGlyphs.export),
                      title: appLocalizations.exportFile,
                      chevron: true,
                      onTap: () => unawaited(actions.exportFile(context)),
                    ),
                    GroupedRow(
                      leading: const GroupedIcon(AppGlyphs.code),
                      title: appLocalizations.copyJson,
                      chevron: true,
                      onTap: () => unawaited(actions.copyJson(context)),
                    ),
                    if (isUrl)
                      GroupedRow(
                        leading: const GroupedIcon(AppGlyphs.copy),
                        title: appLocalizations.copyLink,
                        chevron: true,
                        onTap: () => unawaited(actions.copyLink(context)),
                      ),
                  ],
                ),
                const SizedBox(height: groupedSectionGap),
                GroupedSection(
                  children: [
                    GroupedButtonRow(
                      label: appLocalizations.delete,
                      color: const Color(0xFFFF453A),
                      onTap: _delete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
