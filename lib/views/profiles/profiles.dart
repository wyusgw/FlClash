import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add.dart';
import 'edit.dart';
import 'preview.dart';
import 'subscription_info.dart';

class ProfilesView extends ConsumerStatefulWidget {
  const ProfilesView({super.key});

  @override
  ConsumerState<ProfilesView> createState() => _ProfilesViewState();
}

class _ProfilesViewState extends ConsumerState<ProfilesView> {
  bool _isUpdating = false;

  Future<void> _updateProfiles(List<Profile> profiles) async {
    if (_isUpdating) {
      return;
    }
    _isUpdating = true;
    final appLocalizations = context.appLocalizations;
    final profilesAction = ref.read(profilesActionProvider.notifier);
    await Future.wait(
      profiles.map<Future>((profile) async {
        if (profile.type == ProfileType.file) return;
        try {
          await profilesAction.updateProfile(profile, showLoading: true);
        } catch (e) {
          dialogs.showNotifier(
            '${profile.realLabel}：${userFacingErrorMessage(e, appLocalizations)}',
            level: MessageLevel.error,
          );
        }
      }),
    );
    _isUpdating = false;
  }

  void _sort(List<Profile> profiles) {
    BaseNavigator.push(context, ReorderableProfilesView(profiles: profiles));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profiles = ref.watch(profilesProvider);
    final currentId = ref.watch(currentProfileIdProvider);
    final hasProfiles = profiles.isNotEmpty;
    return GroupedPage(
      title: appLocalizations.profiles,
      leading: GroupedBarAction(
        glyph: AppGlyphs.scanFrame,
        tooltip: appLocalizations.qrcode,
        onPressed: () => scanProfileQrCode(context, ref),
      ),
      trailing: GroupedBarAction(
        glyph: AppGlyphs.add,
        tooltip: appLocalizations.addProfile,
        onPressed: () => showAddProfilePage(context),
      ),
      body: ListView(
        key: profilesStoreKey,
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
                leading: const GroupedIcon(AppGlyphs.cloudDownload),
                title: appLocalizations.addProfile,
                chevron: true,
                onTap: () => showAddProfilePage(context),
              ),
              if (hasProfiles)
                GroupedRow(
                  leading: const GroupedIcon(AppGlyphs.sync),
                  title: appLocalizations.updateAll,
                  chevron: true,
                  onTap: () => unawaited(_updateProfiles(profiles)),
                ),
              if (hasProfiles)
                GroupedRow(
                  leading: const GroupedIcon(AppGlyphs.sort),
                  title: appLocalizations.profilesSort,
                  chevron: true,
                  onTap: () => _sort(profiles),
                ),
            ],
          ),
          if (hasProfiles) ...[
            const SizedBox(height: groupedSectionGap),
            GroupedSection(
              header: appLocalizations.profiles,
              footer: appLocalizations.profileInUseTip,
              children: [
                for (final profile in profiles)
                  _ProfileRow(
                    key: ValueKey(profile.id),
                    profile: profile,
                    selected: profile.id == currentId,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A row of the profile list: the file's name, when it was written and how
/// big it is, a check where it is the one in use, and the menu of what can be
/// done to it.
class _ProfileRow extends ConsumerStatefulWidget {
  const _ProfileRow({super.key, required this.profile, required this.selected});

  final Profile profile;
  final bool selected;

  @override
  ConsumerState<_ProfileRow> createState() => _ProfileRowState();
}

class _ProfileRowState extends ConsumerState<_ProfileRow> {
  late Future<int?> _size = _readSize();

  Future<int?> _readSize() async {
    try {
      final file = await widget.profile.file;
      return await file.length();
    } catch (_) {
      return null;
    }
  }

  @override
  void didUpdateWidget(covariant _ProfileRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.lastUpdateDate != widget.profile.lastUpdateDate) {
      _size = _readSize();
    }
  }

  String _subtitle(int? size) {
    final date = widget.profile.lastUpdateDate?.showFull;
    return [?date, if (size != null) formatFileSize(size)].join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final profile = widget.profile;
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final actions = ProfileActions(profile);
    return FutureBuilder<int?>(
      future: _size,
      builder: (_, snapshot) => SwipeActions(
        enabled: !isUpdating && !system.isDesktop,
        leading: [
          SwipeAction(
            label: context.appLocalizations.delete,
            color: groupedDanger,
            fullSwipe: true,
            slideOut: true,
            onPressed: () => actions.deleteProfile(context, ref),
          ),
        ],
        child: GroupedRow(
          title: profile.realLabel,
          subtitle: _subtitle(snapshot.data),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              if (widget.selected)
                GlyphIcon(AppGlyphs.check, size: 18, color: palette.icon),
              if (isUpdating)
                SizedBox.square(
                  dimension: 17,
                  child: IosSpinner(color: palette.icon),
                )
              else
                CommonPopupBox(
                  popupBuilder: (_) =>
                      CommonPopupMenu(items: actions.menuItems(context, ref)),
                  targetBuilder: (open) => Tooltip(
                    message: context.appLocalizations.more,
                    child: InkResponse(
                      onTap: open,
                      radius: 16,
                      child: GlyphIcon(
                        AppGlyphs.info,
                        size: 19,
                        color: palette.icon,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onTap: () =>
              ref.read(currentProfileIdProvider.notifier).value = profile.id,
        ),
      ),
    );
  }
}

/// What can be done to one profile, as the entries of its popup menu.
class ProfileActions {
  const ProfileActions(this.profile);

  final Profile profile;

  Future<void> deleteProfile(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      title: profile.realLabel,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.profile),
      ),
      destructive: true,
    );
    if (confirmed != true) return;
    await ref.read(profilesActionProvider.notifier).deleteProfile(profile.id);
  }

  Future<void> _handlePreview(BuildContext context) async {
    unawaited(
      BaseNavigator.push<String>(context, PreviewProfileView(profile: profile)),
    );
  }

  void _handleShowSubscriptionInfo(BuildContext context) {
    unawaited(
      BaseNavigator.push<void>(
        context,
        SubscriptionInfoPage(subscriptionInfo: profile.subscriptionInfo!),
      ),
    );
  }

  Future updateProfile(WidgetRef ref) async {
    if (profile.type == ProfileType.file) return;
    await globalState.loadingRun(
      () async {
        await ref
            .read(profilesActionProvider.notifier)
            .updateProfile(profile, showLoading: true);
      },
      tag: LoadingTag.profiles,
      silence: true,
    );
  }

  void showEditPage(BuildContext context) {
    unawaited(BaseNavigator.push(context, EditProfileView(profile: profile)));
  }

  Future<void> copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: profile.url));
    if (context.mounted) {
      context.showNotifier(
        context.appLocalizations.copySuccess,
        level: MessageLevel.success,
      );
    }
  }

  Future<void> copyJson(BuildContext context) async {
    final text = await readTextFileTask(
      await appPath.getProfilePath(profile.id.toString()),
    );
    if (text == null) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      context.showNotifier(
        context.appLocalizations.copySuccess,
        level: MessageLevel.success,
      );
    }
  }

  Future<void> exportFile(BuildContext context) async {
    final appLocalizations = context.appLocalizations;
    final res = await globalState.safeRun<bool>(() async {
      final mFile = await profile.file;
      final value = await picker.saveFile(
        profile.realLabel,
        mFile.readAsBytesSync(),
      );
      if (value == null) return false;
      return true;
    }, title: appLocalizations.tip);
    if (res == true && context.mounted) {
      context.showNotifier(
        appLocalizations.exportSuccess,
        level: MessageLevel.success,
      );
    }
  }

  List<CommonPopupMenuItem> menuItems(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final isUrl = profile.type == ProfileType.url;
    final subscriptionInfo = profile.subscriptionInfo;
    final hasSubscriptionInfo =
        isUrl && subscriptionInfo != null && subscriptionInfo.total > 0;
    return [
      CommonPopupMenuItem(
        glyph: AppGlyphs.edit,
        label: appLocalizations.edit,
        onPressed: () {
          showEditPage(context);
        },
      ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.eye,
        label: appLocalizations.preview,
        onPressed: () {
          _handlePreview(context);
        },
      ),
      if (isUrl)
        CommonPopupMenuItem(
          glyph: AppGlyphs.sync,
          label: appLocalizations.sync,
          onPressed: () {
            updateProfile(ref);
          },
        ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.moreCircle,
        label: appLocalizations.more,
        subItems: [
          if (hasSubscriptionInfo)
            CommonPopupMenuItem(
              glyph: AppGlyphs.dataUsage,
              label: appLocalizations.subscriptionInfo,
              onPressed: () {
                _handleShowSubscriptionInfo(context);
              },
            ),
          if (isUrl)
            CommonPopupMenuItem(
              glyph: AppGlyphs.copy,
              label: appLocalizations.copyLink,
              onPressed: () {
                copyLink(context);
              },
            ),
          CommonPopupMenuItem(
            glyph: AppGlyphs.export,
            label: appLocalizations.exportFile,
            onPressed: () {
              exportFile(context);
            },
          ),
        ],
      ),
      CommonPopupMenuItem(
        danger: true,
        glyph: AppGlyphs.delete,
        label: appLocalizations.delete,
        onPressed: () {
          deleteProfile(context, ref);
        },
      ),
    ];
  }
}

class ReorderableProfilesView extends ConsumerStatefulWidget {
  final List<Profile> profiles;

  const ReorderableProfilesView({super.key, required this.profiles});

  @override
  ConsumerState<ReorderableProfilesView> createState() =>
      _ReorderableProfilesViewState();
}

class _ReorderableProfilesViewState
    extends ConsumerState<ReorderableProfilesView> {
  late List<Profile> profiles;

  @override
  void initState() {
    super.initState();
    profiles = List.from(widget.profiles);
  }

  Widget _buildItem(int index) {
    final profile = profiles[index];
    return ReorderableDelayedDragStartListener(
      key: Key(profile.id.toString()),
      index: index,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (index > 0) const GroupedHairline(inset: groupedRowPadding + 1),
          GroupedRow(
            title: profile.realLabel,
            trailing: GlyphIcon(
              AppGlyphs.dragHandle,
              size: 19,
              color: GroupedPalette.of(context).tertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    Navigator.of(context).pop();
    ref.read(profilesProvider.notifier).reorder(profiles);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return GroupedPage(
      title: appLocalizations.profilesSort,
      onBack: () => Navigator.of(context).maybePop(),
      trailing: GroupedBarAction(
        label: appLocalizations.save,
        tooltip: appLocalizations.save,
        onPressed: _handleSave,
      ),
      body: GroupedBody(
        children: [
          GroupedCard(
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) =>
                  Material(type: MaterialType.transparency, child: child),
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  profiles = profiles.copyAndReorder(oldIndex, newIndex);
                });
              },
              itemBuilder: (_, index) => _buildItem(index),
              itemCount: profiles.length,
            ),
          ),
        ],
      ),
    );
  }
}
