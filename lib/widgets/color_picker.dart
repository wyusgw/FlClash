import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:fl_clash/widgets/grouped_input.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:fl_clash/widgets/palette_link.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Asks for a color: a panel for its saturation and brightness, a bar for its
/// hue and one for its opacity, and the hex value to read or type. Resolves to
/// the ARGB value of the pick, or null where the reader cancels.
Future<int?> showColorPicker(
  BuildContext context, {
  required int color,
  required String title,
}) {
  return dialogs.showCommonDialog<int>(
    context: context,
    child: ColorPickerDialog(color: color, title: title),
  );
}

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({
    super.key,
    required this.color,
    required this.title,
  });

  final int color;
  final String title;

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  static const _width = 280.0;

  late HSVColor _hsv = HSVColor.fromColor(Color(widget.color));
  late final _hex = TextEditingController(text: colorHex(widget.color));
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _hex.addListener(_typed);
  }

  @override
  void dispose() {
    _hex.dispose();
    _focus.dispose();
    super.dispose();
  }

  int get _argb => _hsv.toColor().toARGB32();

  /// A value typed in the field moves the pick once it is a color; the field
  /// itself is left as typed.
  void _typed() {
    final color = parseColorHex(_hex.text);
    if (color == null || color == _argb) {
      return;
    }
    setState(() => _hsv = _keepHue(HSVColor.fromColor(Color(color))));
  }

  /// A grey has no hue of its own; the one in hand stays so that dragging on
  /// from it does not jump to red.
  HSVColor _keepHue(HSVColor next) {
    if (next.saturation == 0 || next.value == 0) {
      return next.withHue(_hsv.hue);
    }
    return next;
  }

  /// A change made with the panel or the bars, written into the field.
  void _pick(HSVColor next) {
    setState(() => _hsv = next);
    final text = colorHex(_argb);
    _hex.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final style = palette.rowTitle.toJetBrainsMono.copyWith(height: 1.4);
    final strut = StrutStyle.fromTextStyle(style, forceStrutHeight: true);
    final hue = HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor();
    final opaque = _hsv.withAlpha(1).toColor();
    return Dialog(
      backgroundColor: palette.bar,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: AppShape.xxl,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _width),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: palette.subhead,
              ),
              const SizedBox(height: 14),
              _SaturationPanel(
                hue: hue,
                hsv: _hsv,
                onChanged: _pick,
                outline: palette.tertiary,
              ),
              const SizedBox(height: 14),
              _BarSlider(
                key: const ValueKey('color.hue'),
                value: _hsv.hue / 360,
                colors: [
                  for (var i = 0; i <= 6; i++)
                    HSVColor.fromAHSV(1, i * 60, 1, 1).toColor(),
                ],
                outline: palette.tertiary,
                onChanged: (value) => _pick(_hsv.withHue(value * 360)),
              ),
              const SizedBox(height: 10),
              _BarSlider(
                key: const ValueKey('color.alpha'),
                value: _hsv.alpha,
                colors: [opaque.withValues(alpha: 0), opaque],
                checkered: true,
                outline: palette.tertiary,
                onChanged: (value) => _pick(_hsv.withAlpha(value)),
              ),
              const SizedBox(height: 14),
              Row(
                spacing: 10,
                children: [
                  DecoratedBox(
                    decoration: ShapeDecoration(
                      color: _hsv.toColor(),
                      shape: CircleBorder(
                        side: BorderSide(color: palette.tertiary),
                      ),
                    ),
                    child: const SizedBox.square(dimension: 28),
                  ),
                  Text('#', style: style, strutStyle: strut),
                  Expanded(
                    child: GroupedEditableText(
                      controller: _hex,
                      focusNode: _focus,
                      autofocus: false,
                      style: style,
                      strutStyle: strut,
                      cursorColor: palette.accent,
                      selectionColor: palette.accent.withValues(alpha: 0.3),
                      textCapitalization: TextCapitalization.characters,
                      keyboardType: TextInputType.visiblePassword,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp('[0-9a-fA-F]'),
                        ),
                        LengthLimitingTextInputFormatter(8),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: DialogButton(
                      label: appLocalizations.cancel,
                      color: palette.hover,
                      foreground: palette.label,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Expanded(
                    child: DialogButton(
                      label: appLocalizations.confirm,
                      color: palette.accent,
                      foreground: const Color(0xFFFFFFFF),
                      onPressed: () => Navigator.of(context).pop(_argb),
                    ),
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

/// The two ends of a drag, both turned into a position between 0 and 1.
Offset _unit(Offset local, Size size) => Offset(
  (local.dx / size.width).clamp(0.0, 1.0),
  (local.dy / size.height).clamp(0.0, 1.0),
);

/// Saturation along the way across and brightness up the way down, over the
/// pure color of the hue.
class _SaturationPanel extends StatelessWidget {
  const _SaturationPanel({
    required this.hue,
    required this.hsv,
    required this.onChanged,
    required this.outline,
  });

  final Color hue;
  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;
  final Color outline;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          void update(Offset local) {
            final unit = _unit(local, size);
            onChanged(hsv.withSaturation(unit.dx).withValue(1 - unit.dy));
          }

          return GestureDetector(
            key: const ValueKey('color.panel'),
            behavior: HitTestBehavior.opaque,
            onPanDown: (details) => update(details.localPosition),
            onPanUpdate: (details) => update(details.localPosition),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: AppShape.all(
                        8,
                      ).copyWith(side: BorderSide(color: outline)),
                      gradient: LinearGradient(
                        colors: [const Color(0xFFFFFFFF), hue],
                      ),
                    ),
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        shape: AppShape.all(8),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0xFF000000)],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: hsv.saturation * size.width - 9,
                  top: (1 - hsv.value) * size.height - 9,
                  child: const _Thumb(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A bar over a gradient with a thumb on it, for a value from 0 to 1.
class _BarSlider extends StatelessWidget {
  const _BarSlider({
    super.key,
    required this.value,
    required this.colors,
    required this.outline,
    required this.onChanged,
    this.checkered = false,
  });

  final double value;
  final List<Color> colors;
  final Color outline;
  final ValueChanged<double> onChanged;

  /// Whether a chequer shows through the colors, for a bar of opacity.
  final bool checkered;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          void update(Offset local) =>
              onChanged(_unit(local, Size(width, 1)).dx);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (details) => update(details.localPosition),
            onPanUpdate: (details) => update(details.localPosition),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ClipRSuperellipse(
                    borderRadius: AppRadius.all(9),
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        shape: AppShape.all(
                          9,
                        ).copyWith(side: BorderSide(color: outline)),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (checkered) const _Chequer(),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: colors),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: value * width - 9,
                  top: 0,
                  child: const _Thumb(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: CircleBorder(
            side: BorderSide(color: Color(0xFFFFFFFF), width: 2.5),
          ),
          shadows: [BoxShadow(color: Color(0x66000000), blurRadius: 3)],
        ),
        child: SizedBox.square(dimension: 18),
      ),
    );
  }
}

/// The grey squares that show how much of a color lets through.
class _Chequer extends StatelessWidget {
  const _Chequer();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _ChequerPainter());
}

class _ChequerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cell = 6.0;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFFFFF),
    );
    final grey = Paint()..color = const Color(0xFFCCCCCC);
    for (var y = 0; y * cell < size.height; y++) {
      for (var x = y % 2; x * cell < size.width; x += 2) {
        canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), grey);
      }
    }
  }

  @override
  bool shouldRepaint(_ChequerPainter oldDelegate) => false;
}
