import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:material_ui/material_ui.dart';

import 'grouped_list.dart';

const _warningColor = Color(0xFFFF9F0A);

/// What a tone is drawn in: orange for a warning, red for an error and the
/// greys of the text colours for the rest.
Color recordToneColor(GroupedPalette palette, RecordTone tone) =>
    switch (tone) {
      RecordTone.warning => _warningColor,
      RecordTone.error => groupedDanger,
      RecordTone.neutral => palette.secondary,
      RecordTone.muted => palette.tertiary,
    };

class RecordTextStyles {
  final TextStyle? primary;
  final TextStyle? secondary;
  final TextStyle? muted;

  const RecordTextStyles._({this.primary, this.secondary, this.muted});

  factory RecordTextStyles.of(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final secondary = TextStyle(
      fontSize: 13,
      height: 1.3,
      color: palette.secondary,
    );
    return RecordTextStyles._(
      primary: TextStyle(fontSize: 15, height: 1.3, color: palette.label),
      secondary: secondary,
      muted: secondary.copyWith(color: palette.tertiary),
    );
  }
}

class RecordListItem extends StatelessWidget {
  final Widget header;
  final Widget body;
  final RecordTone tone;
  final VoidCallback? onTap;

  const RecordListItem({
    super.key,
    required this.header,
    required this.body,
    this.tone = RecordTone.neutral,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final flagged = tone == RecordTone.warning || tone == RecordTone.error;
    return Material(
      color: flagged
          ? recordToneColor(palette, tone).withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: palette.hover,
        highlightColor: palette.hover,
        splashColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              Padding(padding: const EdgeInsets.only(top: 6), child: body),
            ],
          ),
        ),
      ),
    );
  }
}

class RecordHeader extends StatelessWidget {
  final List<Widget> children;
  final Widget? trailing;

  const RecordHeader({super.key, required this.children, this.trailing});

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    return DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: 13,
        color: GroupedPalette.of(context).secondary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: children,
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class RecordLabel extends StatelessWidget {
  final String label;
  final RecordTone tone;
  final VoidCallback? onPressed;

  const RecordLabel({
    super.key,
    required this.label,
    this.tone = RecordTone.neutral,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final color = recordToneColor(palette, tone);
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
    return Material(
      color: color.withValues(alpha: 0.15),
      shape: AppShape.full,
      clipBehavior: Clip.antiAlias,
      child: onPressed == null
          ? content
          : InkWell(onTap: onPressed, child: content),
    );
  }
}

class RecordTimestamp extends StatelessWidget {
  final String dateTime;

  const RecordTimestamp(this.dateTime, {super.key});

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final split = dateTime.lastIndexOf(' ');
    return Text.rich(
      TextSpan(
        children: [
          if (split > 0)
            TextSpan(
              text: dateTime.substring(0, split + 1),
              style: TextStyle(color: palette.tertiary),
            ),
          TextSpan(text: split > 0 ? dateTime.substring(split + 1) : dateTime),
        ],
      ),
      maxLines: 1,
    );
  }
}

class RecordArrow extends StatelessWidget {
  const RecordArrow({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '→',
      style: RecordTextStyles.of(context).muted?.toJetBrainsMono,
    );
  }
}
