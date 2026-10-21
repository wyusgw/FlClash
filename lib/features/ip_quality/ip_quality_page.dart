import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/ip_quality.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/ip_quality.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'labels.dart';

const ipMask = '*****';

/// [ip] as one row can hold it: an IPv6 address keeps only its leading
/// groups, an IPv4 address is returned whole.
String shortIp(String ip) {
  if (!ip.contains(':')) {
    return ip;
  }
  final groups = ip.split(':').takeWhile((group) => group.isNotEmpty).toList();
  if (groups.length <= 3) {
    return ip;
  }
  return '${groups.take(3).join(':')}:…';
}

/// What the third-party lookups say about [ip]: its type and quality, the
/// network it belongs to and which source answered.
class IpQualityPage extends ConsumerWidget {
  const IpQualityPage({super.key, required this.ip, this.desktop});

  final String ip;

  /// Whether to lay out for a pointer, which refreshes from the bar; a touch
  /// screen pulls down instead. The platform's own answer when null.
  @visibleForTesting
  final bool? desktop;

  bool get _desktop => desktop ?? system.isDesktop;

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    context.showNotifier(context.appLocalizations.copySuccess);
  }

  GroupedRow _row(
    BuildContext context,
    String title, {
    String? value,
    Widget? trailing,
    String? copyText,
  }) {
    return GroupedRow(
      title: title,
      value: value,
      trailing: trailing,
      onTap: copyText == null ? null : () => _copy(context, copyText),
    );
  }

  Widget _pullToRefresh(
    GroupedPalette palette,
    Future<void> Function() onRefresh,
    Widget child,
  ) {
    if (_desktop) return child;
    return RefreshIndicator(
      color: palette.accent,
      backgroundColor: palette.fill,
      onRefresh: onRefresh,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final result = ref.watch(ipQualityProvider(ip));
    final hideIp = ref.watch(
      appSettingProvider.select((state) => state.hideIp),
    );
    final quality = result.isLoading ? null : result.value;
    final error = result.error;
    final failed = quality == null && !result.isLoading;
    Future<void> refresh() async {
      ref.invalidate(ipQualityProvider(ip));
      try {
        await ref.read(ipQualityProvider(ip).future);
      } catch (_) {
        // The page shows the failure itself.
      }
    }

    return GroupedPage(
      title: localizations.networkDetection,
      onBack: () => Navigator.of(context).maybePop(),
      trailing: _desktop
          ? GroupedBarAction(
              glyph: AppGlyphs.refresh,
              tooltip: localizations.ipQualityRetry,
              onPressed: result.isLoading ? null : refresh,
            )
          : null,
      body: _pullToRefresh(
        palette,
        refresh,
        GroupedBody(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            GroupedSection(
              header: localizations.basicInfo,
              children: [
                _row(
                  context,
                  localizations.ipAddress,
                  value: hideIp ? ipMask : ip,
                  copyText: ip,
                ),
                if (failed)
                  _row(
                    context,
                    localizations.ipType,
                    trailing: Text(
                      localizations.ipQualityFailed,
                      style: palette.rowValue.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                  )
                else
                  ..._qualityRows(context, quality),
              ],
            ),
            if (!failed) ...[
              const SizedBox(height: groupedSectionGap),
              GroupedSection(
                header: localizations.network,
                children: _networkRows(context, quality),
              ),
            ],
            if (failed && error is IpQualityLookupException) ...[
              const SizedBox(height: groupedSectionGap),
              GroupedSection(
                header: localizations.ipQualitySources,
                children: [
                  for (final failure in error.failures)
                    _row(
                      context,
                      failure.source.label,
                      value: failure.status.label(context),
                    ),
                ],
              ),
            ],
            const SizedBox(height: groupedSectionGap),
            GroupedSection(
              header: localizations.other,
              children: [
                GroupedRow(
                  title: localizations.hideIp,
                  trailing: GroupedSwitch(
                    value: hideIp,
                    onChanged: (value) => ref
                        .read(appSettingProvider.notifier)
                        .update((state) => state.copyWith(hideIp: value)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A lookup still running lays out every row it will fill, so the page
  /// keeps its height when the values arrive.
  List<Widget> _qualityRows(BuildContext context, IpQuality? quality) {
    final localizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    if (quality == null) {
      return [
        _row(
          context,
          localizations.ipQualityLevel,
          trailing: const SkeletonText(width: 40),
        ),
        _row(
          context,
          localizations.ipPurity,
          trailing: const SkeletonText(width: 40),
        ),
        _row(
          context,
          localizations.ipType,
          trailing: const SkeletonText(width: 64),
        ),
        _row(
          context,
          localizations.ipFlags,
          trailing: const SkeletonText(width: 40),
        ),
      ];
    }
    final flags = [
      if (quality.isTor) localizations.ipFlagTor,
      if (quality.isAbuser) localizations.ipFlagAbuser,
      if (quality.isVpn) localizations.ipFlagVpn,
      if (quality.isProxy) localizations.ipFlagProxy,
    ];
    return [
      _row(
        context,
        localizations.ipQualityLevel,
        trailing: Text(
          quality.level.label(context),
          style: palette.rowValue.copyWith(color: quality.level.color(context)),
        ),
      ),
      _row(
        context,
        localizations.ipPurity,
        trailing: Text(
          '${quality.purity}%',
          style: palette.rowValue.copyWith(color: quality.level.color(context)),
        ),
      ),
      _row(context, localizations.ipType, value: quality.type.label(context)),
      _row(
        context,
        localizations.ipFlags,
        value: flags.isEmpty ? localizations.none : flags.join(' · '),
      ),
    ];
  }

  List<Widget> _networkRows(BuildContext context, IpQuality? quality) {
    final localizations = context.appLocalizations;
    Widget? skeleton(double width) =>
        quality == null ? SkeletonText(width: width) : null;
    String? textOf(String? text) => quality == null ? null : text ?? '—';
    final organization = quality?.organization;
    final asn = switch (quality?.asn) {
      final asn? => 'AS$asn',
      null => null,
    };
    return [
      _row(
        context,
        localizations.ipOrganization,
        value: textOf(organization),
        trailing: skeleton(120),
        copyText: organization,
      ),
      _row(
        context,
        localizations.ipAsn,
        value: textOf(asn),
        trailing: skeleton(56),
        copyText: asn,
      ),
    ];
  }
}
