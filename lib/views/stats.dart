import 'dart:async';
import 'dart:math' as math;

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
const _curveHeight = 110.0;

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
      destructive: true,
    );
    if (res != true) return;
    ref.read(commonActionProvider.notifier).resetStatistics();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final runTime = ref.watch(runTimeProvider);
    final stats = ref.watch(statsSnapshotProvider);
    final samples = ref.watch(trafficsProvider.select((state) => state.list));
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
            header: appLocalizations.speedStatistics,
            child: _SpeedCurve(samples: samples),
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

/// The speed over the last samples as two smooth curves, down and up, under
/// the rates now and the peak.
class _SpeedCurve extends StatelessWidget {
  const _SpeedCurve({required this.samples});

  final List<Traffic> samples;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final latest = samples.safeLast(const Traffic());
    final peak = samples.fold<num>(
      0,
      (peak, sample) => math.max(peak, math.max(sample.up, sample.down)),
    );
    Widget legend(Glyph glyph, Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        GlyphIcon(glyph, size: 14, color: color),
        Text(label, style: palette.rowTitle),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            legend(AppGlyphs.arrowDown, _downColor, _rate(latest.down)),
            legend(AppGlyphs.arrowUp, _upColor, _rate(latest.up)),
          ],
        ),
        SizedBox(
          height: _curveHeight,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  key: const ValueKey('speed-curve'),
                  painter: _CurvePainter(
                    samples: samples,
                    peak: peak,
                    grid: palette.separator,
                  ),
                ),
              ),
              // The scale: what the top line stands for.
              Text(_rate(math.max(peak, 1024)), style: palette.sectionLabel),
            ],
          ),
        ),
      ],
    );
  }
}

String _rate(num bytesPerSecond) => '${bytesPerSecond.traffic.show}/s';

class _CurvePainter extends CustomPainter {
  const _CurvePainter({
    required this.samples,
    required this.peak,
    required this.grid,
  });

  final List<Traffic> samples;
  final num peak;
  final Color grid;

  /// The curve rises no higher than the peak, and no lower a ceiling than 1KB,
  /// so a quiet link does not draw noise as mountains.
  num get _ceiling => math.max(peak, 1024);

  Path _line(Size size, num Function(Traffic) pick) {
    final path = Path();
    // The newest sample sits at the right edge and older ones to its left,
    // so a short history fills from the right rather than stretching.
    final step = size.width / (trafficSampleLength - 1);
    final first = trafficSampleLength - samples.length;
    Offset at(int i) => Offset(
      (first + i) * step,
      size.height - size.height * (pick(samples[i]) / _ceiling).clamp(0, 1),
    );
    path.moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < samples.length; i++) {
      final from = at(i - 1);
      final to = at(i);
      final middle = (from.dx + to.dx) / 2;
      path.cubicTo(middle, from.dy, middle, to.dy, to.dx, to.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rule = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rule);
    }
    if (samples.length < 2) return;
    for (final (pick, color) in <(num Function(Traffic), Color)>[
      ((sample) => sample.up, _upColor),
      ((sample) => sample.down, _downColor),
    ]) {
      final line = _line(size, pick);
      final firstX =
          (trafficSampleLength - samples.length) *
          size.width /
          (trafficSampleLength - 1);
      final area = Path.from(line)
        ..lineTo(size.width, size.height)
        ..lineTo(firstX, size.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
          ).createShader(Offset.zero & size),
      );
      canvas.drawPath(
        line,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_CurvePainter old) =>
      old.samples != samples || old.peak != peak || old.grid != grid;
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
      destructive: true,
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
