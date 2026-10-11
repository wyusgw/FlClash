import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const _upColor = Color(0xFFE5604D);
const _downColor = Color(0xFF55B26B);
const _barHeight = 120.0;
const _barWidth = 44.0;

String _clock(Duration duration) {
  final hours = duration.inHours;
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(hours)}:${two(duration.inMinutes % 60)}:${two(duration.inSeconds % 60)}';
}

String _volume(Traffic traffic) => (traffic.up + traffic.down).traffic.show;

/// What the Core is doing and has carried: when it started, how long it has
/// run, the traffic through it split into what went through a proxy and what
/// did not, and the runs kept from before.
class StatsView extends ConsumerWidget {
  const StatsView({super.key});

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.confirm,
      message: TextSpan(text: appLocalizations.resetTip),
      confirmText: appLocalizations.reset,
    );
    if (res != true) return;
    ref.read(commonActionProvider.notifier).resetStatistics();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final runTime = ref.watch(runTimeProvider);
    final stats = ref.watch(statsSnapshotProvider);
    final archive = ref.watch(
      appSettingProvider.select((state) => state.archiveStats),
    );
    final started = runTime == null
        ? null
        : DateTime.now().subtract(Duration(milliseconds: runTime));
    return GroupedPage(
      title: appLocalizations.statistics,
      onBack: () => Navigator.of(context).maybePop(),
      trailing: GroupedBarAction(
        glyph: AppGlyphs.reset,
        tooltip: appLocalizations.resetStatistics,
        onPressed: () => unawaited(_reset(context, ref)),
      ),
      body: GroupedBody(
        children: [
          GroupedSection(
            header: appLocalizations.core,
            children: [
              GroupedRow(
                title: appLocalizations.startTime,
                value: started?.showFull ?? '—',
              ),
              GroupedRow(
                title: appLocalizations.connectedTime,
                value: runTime == null
                    ? '—'
                    : _clock(Duration(milliseconds: runTime)),
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedBlock(
            header: appLocalizations.traffic,
            child: Row(
              children: [
                Expanded(
                  child: _TrafficColumn(
                    label: appLocalizations.trafficAll,
                    traffic: stats.all,
                  ),
                ),
                Expanded(
                  child: _TrafficColumn(
                    label: appLocalizations.trafficProxy,
                    traffic: stats.proxy,
                  ),
                ),
                Expanded(
                  child: _TrafficColumn(
                    label: appLocalizations.direct,
                    traffic: stats.direct,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedBlock(
            header: appLocalizations.distribution,
            child: _TrafficBars(
              bars: [
                (appLocalizations.direct, stats.direct),
                (appLocalizations.trafficProxy, stats.proxy),
              ],
            ),
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            footer: appLocalizations.archiveDesc,
            children: [
              GroupedRow(
                title: appLocalizations.archiveStats,
                trailing: GroupedSwitch(
                  value: archive,
                  onChanged: (value) => ref
                      .read(appSettingProvider.notifier)
                      .update((state) => state.copyWith(archiveStats: value)),
                ),
                onTap: () => ref
                    .read(appSettingProvider.notifier)
                    .update((state) => state.copyWith(archiveStats: !archive)),
              ),
              GroupedRow(
                title: appLocalizations.archive,
                chevron: true,
                onTap: () => BaseNavigator.push(context, const ArchiveView()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrafficColumn extends StatelessWidget {
  const _TrafficColumn({required this.label, required this.traffic});

  final String label;
  final Traffic traffic;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    Widget line(Glyph glyph, Color color, num bytes) => Row(
      spacing: 4,
      children: [
        GlyphIcon(glyph, size: 14, color: color),
        Text(bytes.traffic.show, style: palette.rowTitle),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(label, style: palette.sectionLabel),
        line(AppGlyphs.arrowUp, _upColor, traffic.up),
        line(AppGlyphs.arrowDown, _downColor, traffic.down),
      ],
    );
  }
}

/// One bar per kind of traffic, filled in proportion to the largest.
class _TrafficBars extends StatelessWidget {
  const _TrafficBars({required this.bars});

  final List<(String, Traffic)> bars;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final largest = bars
        .map((bar) => bar.$2.up + bar.$2.down)
        .fold<num>(0, (a, b) => a > b ? a : b);
    return Row(
      children: [
        for (final (label, traffic) in bars)
          Expanded(
            child: Column(
              spacing: 6,
              children: [
                Text(_volume(traffic), style: palette.sectionLabel),
                SizedBox(
                  width: _barWidth,
                  height: _barHeight,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: palette.separator,
                      shape: AppShape.sm,
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: largest <= 0
                            ? 0
                            : ((traffic.up + traffic.down) / largest)
                                  .clamp(0.0, 1.0)
                                  .toDouble(),
                        widthFactor: 1,
                        child: const DecoratedBox(
                          decoration: ShapeDecoration(
                            color: _downColor,
                            shape: AppShape.sm,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(label, style: palette.sectionLabel),
              ],
            ),
          ),
      ],
    );
  }
}

/// The runs of the Core kept when archiving was on, newest first.
class ArchiveView extends ConsumerStatefulWidget {
  const ArchiveView({super.key});

  @override
  ConsumerState<ArchiveView> createState() => _ArchiveViewState();
}

class _ArchiveViewState extends ConsumerState<ArchiveView> {
  @override
  void initState() {
    super.initState();
    unawaited(ref.read(commonActionProvider.notifier).loadStatsArchive());
  }

  Future<void> _clear() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.confirm,
      message: TextSpan(text: appLocalizations.resetTip),
      confirmText: appLocalizations.clearArchive,
    );
    if (res != true || !mounted) return;
    await ref
        .read(commonActionProvider.notifier)
        .removeStatsRecords(ref.read(statsRecordsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final records = ref.watch(statsRecordsProvider);
    return GroupedPage(
      title: appLocalizations.archive,
      onBack: () => Navigator.of(context).maybePop(),
      body: GroupedBody(
        children: [
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  appLocalizations.archiveEmpty,
                  style: palette.rowValue,
                ),
              ),
            )
          else ...[
            GroupedSection(
              children: [
                for (final record in records)
                  GroupedRow(
                    key: ValueKey(record.start),
                    title: record.start.showFull,
                    subtitle:
                        '${_clock(record.duration)}  ·  '
                        '${appLocalizations.trafficProxy} '
                        '${_volume(record.stats.proxy)}',
                    value: _volume(record.stats.all),
                    trailing: Tooltip(
                      message: appLocalizations.delete,
                      child: InkResponse(
                        radius: 14,
                        onTap: () => unawaited(
                          ref
                              .read(commonActionProvider.notifier)
                              .removeStatsRecords([record]),
                        ),
                        child: GlyphIcon(
                          AppGlyphs.delete,
                          size: 16,
                          color: palette.secondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: groupedSectionGap),
            GroupedSection(
              children: [
                GroupedButtonRow(
                  label: appLocalizations.clearArchive,
                  color: const Color(0xFFE5604D),
                  onTap: _clear,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
