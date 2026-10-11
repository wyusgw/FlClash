import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/backup_and_restore.dart';
import 'package:fl_clash/views/logs.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:fl_clash/views/profiles/profiles.dart';
import 'package:fl_clash/views/stats.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const _dangerColor = Color(0xFFFF453A);

/// Where the app's own data lives: its backups, its logs and the profiles it
/// holds.
class DataView extends ConsumerWidget {
  const DataView({super.key});

  Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.profiles),
      ),
    );
    if (confirmed != true) {
      return;
    }
    final profilesAction = ref.read(profilesActionProvider.notifier);
    for (final profile in ref.read(profilesProvider)) {
      await profilesAction.deleteProfile(profile.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    final hasProfiles = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    final openLogs = ref.watch(
      appSettingProvider.select((state) => state.openLogs),
    );
    return GroupedPage(
      title: appLocalizations.data,
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
                leading: const GroupedIcon(AppGlyphs.dataUsage),
                title: appLocalizations.statistics,
                chevron: true,
                onTap: () => BaseNavigator.push(context, const StatsView()),
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            footer: appLocalizations.backupAndRestoreDesc,
            children: [
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.cloudSync),
                title: appLocalizations.backupAndRestore,
                chevron: true,
                onTap: () =>
                    BaseNavigator.push(context, const BackupAndRestore()),
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.logs,
            children: [
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.logs),
                title: appLocalizations.logs,
                chevron: true,
                onTap: () => BaseNavigator.push(context, const LogsView()),
              ),
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.history),
                title: appLocalizations.logcat,
                trailing: GroupedSwitch(
                  value: openLogs,
                  onChanged: (value) => ref
                      .read(appSettingProvider.notifier)
                      .update((state) => state.copyWith(openLogs: value)),
                ),
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.profiles,
            children: [
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.importFile),
                title: appLocalizations.addProfile,
                chevron: true,
                onTap: () => showAddProfilePage(context),
              ),
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.export),
                title: appLocalizations.exportFile,
                chevron: true,
                onTap: profile == null
                    ? null
                    : () => unawaited(
                        ProfileActions(profile).exportFile(context),
                      ),
              ),
              GroupedRow(
                leading: const GroupedIcon(
                  AppGlyphs.delete,
                  color: _dangerColor,
                ),
                title: appLocalizations.deleteAllProfiles,
                chevron: true,
                onTap: hasProfiles
                    ? () => unawaited(_deleteAll(context, ref))
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
