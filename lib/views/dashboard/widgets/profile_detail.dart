import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/preview.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

Future<void> syncProfile(WidgetRef ref, Profile profile) async {
  await globalState.loadingRun(() async {
    await ref
        .read(profilesActionProvider.notifier)
        .updateProfile(profile, showLoading: true);
  }, tag: LoadingTag.profiles);
}

void showProfileDetailSheet(BuildContext context) {
  showSheet<void>(context: context, builder: (_) => const ProfileDetailSheet());
}

class ProfileDetailSheet extends ConsumerWidget {
  const ProfileDetailSheet({super.key});

  void _handlePreview(BuildContext context, Profile profile) {
    unawaited(
      BaseNavigator.push<String>(context, PreviewProfileView(profile: profile)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) {
      return const SizedBox.shrink();
    }
    final nodeCount = ref.watch(
      groupsProvider.select(
        (groups) => groups.fold<Set<String>>({}, (names, group) {
          return names..addAll(group.all.map((proxy) => proxy.name));
        }).length,
      ),
    );
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final appLocalizations = context.appLocalizations;
    final subscriptionInfo = profile.subscriptionInfo;
    return CommonScaffold(
      title: profile.realLabel,
      iconActions: [
        if (profile.type == ProfileType.url)
          IconButtonData(
            glyph: AppGlyphs.sync,
            tooltip: appLocalizations.sync,
            isLoading: isUpdating,
            onPressed: () => syncProfile(ref, profile),
          ),
        IconButtonData(
          glyph: AppGlyphs.eye,
          tooltip: appLocalizations.preview,
          onPressed: () => _handlePreview(context, profile),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(top: context.contentTopPadding, bottom: 20),
        children: [
          _StatTile(label: appLocalizations.proxyNode, value: '$nodeCount'),
          if (subscriptionInfo != null && subscriptionInfo.total > 0)
            generateSectionV3(
              title: appLocalizations.subscriptionInfo,
              items: [
                ListItem(
                  title: SubscriptionInfoView(
                    subscriptionInfo: subscriptionInfo,
                  ),
                ),
              ],
            ),
          generateSectionV3(
            title: appLocalizations.profile,
            items: [
              _InfoRow(
                label: appLocalizations.lastUpdated,
                value: LastUpdateTimeText(
                  lastUpdateDate: profile.lastUpdateDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: ShapeDecoration(
          color: colorScheme.surfaceContainer,
          shape: AppShape.all(AppCorner.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text(
              value,
              maxLines: 1,
              style: context.textTheme.headlineSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return ListItem(
      title: Text(label),
      trailing: DefaultTextStyle.merge(
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        child: value,
      ),
    );
  }
}
