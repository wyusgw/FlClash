import 'dart:math' as math;

import 'package:fl_clash/common/shape.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:material_ui/material_ui.dart';

import 'grouped_list.dart';

/// The spinner of iOS: twelve spokes that fade behind a turning head.
class IosSpinner extends StatefulWidget {
  const IosSpinner({super.key, this.size = 19, this.color});

  final double size;

  /// The spokes' colour; the secondary text colour where it is null.
  final Color? color;

  @override
  State<IosSpinner> createState() => _IosSpinnerState();
}

class _IosSpinnerState extends State<IosSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? GroupedPalette.of(context).secondary;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _SpinnerPainter(animation: _controller, color: color),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({required this.animation, required this.color})
    : super(repaint: animation);

  static const _spokes = 12;

  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius / 4.5;
    final head = (animation.value * _spokes).floor();
    canvas.translate(size.width / 2, size.height / 2);
    for (var i = 0; i < _spokes; i++) {
      final age = (head - i) % _spokes;
      paint.color = color.withValues(alpha: 1 - age / _spokes * 0.85);
      final angle = 2 * math.pi * i / _spokes;
      final direction = Offset(math.sin(angle), -math.cos(angle));
      canvas.drawLine(
        direction * (radius * 0.55),
        direction * (radius * 0.95),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) => oldDelegate.color != color;
}

/// A pill button in the manner of iOS: the accent colour with white text, or
/// with [tonal] the grey of a secondary answer with the accent colour's text.
class IosButton extends StatelessWidget {
  const IosButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.glyph,
    this.tonal = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Glyph? glyph;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final foreground = tonal ? palette.accent : const Color(0xFFFFFFFF);
    return Material(
      color: tonal ? palette.hover : palette.accent,
      shape: AppShape.full,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              if (glyph != null)
                GlyphIcon(glyph!, fill: 1, size: 18, color: foreground),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The thin progress line of iOS for work with no known end: a short stretch
/// of the accent colour running along a grey track.
class IosProgressBar extends StatefulWidget {
  const IosProgressBar({super.key, this.height = 3});

  final double height;

  @override
  State<IosProgressBar> createState() => _IosProgressBarState();
}

class _IosProgressBarState extends State<IosProgressBar>
    with SingleTickerProviderStateMixin {
  static const _segment = 0.3;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return SizedBox(
      height: widget.height,
      child: ColoredBox(
        color: palette.separator,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => FractionallySizedBox(
            alignment: Alignment(
              -1 + 2 * Curves.easeInOut.transform(_controller.value),
              0,
            ),
            widthFactor: _segment,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: palette.accent,
                shape: AppShape.full,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A round icon button of iOS: bare, or with [filled] on the grey disc of a
/// toolbar button that is on or stands alone, like a close mark.
class IosIconButton extends StatelessWidget {
  const IosIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.filled = false,
    this.size = 32,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: Material(
          color: filled ? palette.hover : Colors.transparent,
          shape: AppShape.circle,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            highlightColor: palette.hover,
            splashColor: Colors.transparent,
            child: SizedBox.square(
              dimension: size,
              child: Center(
                child: IconTheme.merge(
                  data: IconThemeData(color: palette.accent, fill: 1),
                  child: icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
