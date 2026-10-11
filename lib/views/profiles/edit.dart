import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/l10n/l10n.dart';
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
  late bool _autoUpdate;
  final _fileInfoNotifier = ValueNotifier<FileInfo?>(null);
  late SetupAction _setupAction;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.profile.label);
    _urlController = TextEditingController(text: widget.profile.url);
    _autoUpdate = widget.profile.autoUpdate;
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
    return null;
  }

  Future<void> _handleConfirm() async {
    final problem = _invalid(context.appLocalizations);
    if (problem != null) {
      dialogs.showNotifier(problem, level: MessageLevel.error);
      return;
    }
    final profile = widget.profile.copyWith(
      url: _urlController.text,
      label: _labelController.text,
      autoUpdate: _autoUpdate,
    );
    final profilesAction = ref.read(profilesActionProvider.notifier);
    if (widget.profile.url == profile.url) {
      profilesAction.putProfile(profile);
    } else {
      unawaited(
        globalState.safeRun(() async {
          await Future.delayed(commonDuration);
          await profilesAction.updateProfile(profile);
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

  @override
  void dispose() {
    _labelController.dispose();
    _urlController.dispose();
    _fileInfoNotifier.dispose();
    super.dispose();
    _setupAction.autoApplyProfile();
  }

  Future<void> _delete() async {
    await ref
        .read(profilesActionProvider.notifier)
        .deleteProfile(widget.profile.id);
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
    );
  }
}
