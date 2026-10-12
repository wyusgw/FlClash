import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/service_probe.dart';
import 'package:fl_clash/features/ip_quality/ip_quality.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/outbound_ip.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/providers/routed_probe.dart';
import 'package:fl_clash/views/backup_and_restore.dart';
import 'package:fl_clash/views/logs.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:fl_clash/views/profiles/profiles.dart';
import 'package:fl_clash/views/stats.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Where the app's own data lives: the address it exits through, its backups,
/// its logs and the profiles it holds, with the statistics last.
class DataView extends ConsumerStatefulWidget {
  const DataView({super.key});

  @override
  ConsumerState<DataView> createState() => _DataViewState();
}

class _DataViewState extends ConsumerState<DataView> {
  late final OutboundIpProbe _probe;

  @override
  void initState() {
    super.initState();
    _probe = ref.read(outboundIpProbeProvider.notifier)..watch(routedOutbound);
  }

  @override
  void dispose() {
    _probe.unwatch(routedOutbound);
    super.dispose();
  }

  Widget _buildOutboundIp(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final entry = ref.watch(
      outboundIpProbeProvider.select((state) => state.entryOf(routedOutbound)),
    );
    final hideIp = ref.watch(
      appSettingProvider.select((state) => state.hideIp),
    );
    final info = entry.value;
    final Widget trailing;
    if (info != null) {
      trailing = Text(hideIp ? ipMask : info.ip, style: palette.rowValue);
    } else if (entry.phase == ProbePhase.failed) {
      trailing = Text('—', style: palette.rowValue);
    } else {
      trailing = SizedBox.square(
        dimension: 12,
        child: CircularProgressIndicator(strokeWidth: 1.5, color: palette.icon),
      );
    }
    return GroupedSection(
      children: [
        GroupedRow(
          leading: const GroupedIcon(AppGlyphs.networkCheck),
          title: appLocalizations.networkDetection,
          trailing: trailing,
          chevron: info != null,
          onTap: switch ((info, entry.phase)) {
            (final info?, _) => () => BaseNavigator.push(
              context,
              IpQualityPage(ip: info.ip),
            ),
            (_, ProbePhase.failed) => () => _probe.retry(routedOutbound),
            _ => null,
          },
        ),
      ],
    );
  }

  Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      title: appLocalizations.confirm,
      message: TextSpan(text: appLocalizations.deleteAllNodesTip),
      destructive: true,
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
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    final hasProfiles = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    final openLogs = ref.watch(
      appSettingProvider.select((state) => state.openLogs),
    );
    final overwriteExisting = ref.watch(
      appSettingProvider.select((state) => state.overwriteExistingNodes),
    );
    final autoRename = ref.watch(
      appSettingProvider.select((state) => state.autoRenameNodes),
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
          _buildOutboundIp(context),
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
            header: appLocalizations.serverNodes,
            children: [
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.copy),
                title: appLocalizations.overwriteExisting,
                value: overwriteExisting
                    ? appLocalizations.on
                    : appLocalizations.off,
                chevron: true,
                onTap: () => BaseNavigator.push(
                  context,
                  GroupedTogglePage(
                    title: appLocalizations.overwriteExisting,
                    description: appLocalizations.overwriteExistingDesc,
                    read: (ref) => ref.watch(
                      appSettingProvider.select(
                        (state) => state.overwriteExistingNodes,
                      ),
                    ),
                    write: (ref, value) => ref
                        .read(appSettingProvider.notifier)
                        .update(
                          (state) =>
                              state.copyWith(overwriteExistingNodes: value),
                        ),
                  ),
                ),
              ),
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.compose),
                title: appLocalizations.autoRenameNodes,
                value: autoRename ? appLocalizations.on : appLocalizations.off,
                chevron: true,
                onTap: () => BaseNavigator.push(
                  context,
                  GroupedTogglePage(
                    title: appLocalizations.autoRenameNodes,
                    description: appLocalizations.autoRenameNodesDesc,
                    read: (ref) => ref.watch(
                      appSettingProvider.select(
                        (state) => state.autoRenameNodes,
                      ),
                    ),
                    write: (ref, value) => ref
                        .read(appSettingProvider.notifier)
                        .update(
                          (state) => state.copyWith(autoRenameNodes: value),
                        ),
                  ),
                ),
              ),
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
                leading: const GroupedIcon(AppGlyphs.delete),
                title: appLocalizations.deleteAllNodes,
                chevron: true,
                onTap: hasProfiles
                    ? () => unawaited(_deleteAll(context, ref))
                    : null,
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
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
        ],
      ),
    );
  }
}
