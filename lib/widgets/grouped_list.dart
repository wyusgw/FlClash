import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

const groupedRowHeight = 37.0;
const groupedRowPadding = 12.0;
const groupedLeadingSize = 19.0;
const groupedLeadingGap = 11.0;
const groupedBarHeight = 62.0;
const groupedPageInset = 14.0;
const groupedSectionGap = 27.0;

/// A grouped card's own corner: it sits between `sm` and `md` on a 37 tall row.
final _cardShape = AppShape.all(10);

/// The black-and-blue palette of the grouped pages, measured from the design
/// reference rather than derived from the Material seed, so the pages keep
/// their look under any theme color.
@immutable
class GroupedPalette {
  const GroupedPalette._({
    required this.canvas,
    required this.bar,
    required this.sidebar,
    required this.sidebarBar,
    required this.fill,
    required this.separator,
    required this.hover,
    required this.label,
    required this.secondary,
    required this.tertiary,
    required this.accent,
    required this.icon,
    required this.switchOff,
  });

  static const dark = GroupedPalette._(
    canvas: Color(0xFF000000),
    bar: Color(0xFF1D1D1D),
    sidebar: Color(0xFF212020),
    sidebarBar: Color(0xFF272626),
    fill: Color(0xFF1A1A1A),
    separator: Color(0xFF2F2F2F),
    hover: Color(0xFF3A3A3A),
    label: Color(0xFFFFFFFF),
    secondary: Color(0xFF98989D),
    tertiary: Color(0xFF5E5E62),
    accent: Color(0xFF0A84FF),
    icon: Color(0xFF2C72C8),
    switchOff: Color(0xFF39393D),
  );

  static const light = GroupedPalette._(
    canvas: Color(0xFFF2F2F7),
    bar: Color(0xFFF7F7F7),
    sidebar: Color(0xFFE6E6E8),
    sidebarBar: Color(0xFFDEDEE0),
    fill: Color(0xFFFFFFFF),
    separator: Color(0xFFDCDCE0),
    hover: Color(0xFFE5E5EA),
    label: Color(0xFF000000),
    secondary: Color(0xFF6C6C70),
    tertiary: Color(0xFFC4C4C7),
    accent: Color(0xFF007AFF),
    icon: Color(0xFF3A82D8),
    switchOff: Color(0xFFE9E9EB),
  );

  static GroupedPalette of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  final Color canvas;
  final Color bar;
  final Color sidebar;
  final Color sidebarBar;
  final Color fill;
  final Color separator;
  final Color hover;
  final Color label;
  final Color secondary;
  final Color tertiary;
  final Color accent;
  final Color icon;
  final Color switchOff;

  TextStyle get rowTitle =>
      TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: label);

  TextStyle get rowSubtitle => TextStyle(
    fontSize: 8.5,
    fontWeight: FontWeight.w500,
    color: secondary,
    height: 1.15,
  );

  TextStyle get rowValue =>
      TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondary);

  TextStyle get sectionLabel =>
      TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: secondary);
}

/// A rounded card of rows with hairlines between them; the hairline starts
/// where the row's text does.
class GroupedSection extends StatelessWidget {
  const GroupedSection({
    super.key,
    required this.children,
    this.header,
    this.footer,
  });

  final List<Widget> children;
  final String? header;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              groupedRowPadding + 1,
              0,
              groupedRowPadding,
              6,
            ),
            child: Text(header!, style: palette.sectionLabel),
          ),
        Material(
          color: palette.fill,
          shape: _cardShape,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (index, child) in children.indexed) ...[
                if (index > 0)
                  _Hairline(
                    inset: switch (children[index]) {
                      final GroupedItem item => item.separatorInset,
                      _ => 0,
                    },
                    color: palette.separator,
                  ),
                child,
              ],
            ],
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              groupedRowPadding + 1,
              6,
              groupedRowPadding,
              0,
            ),
            child: Text(footer!, style: palette.sectionLabel),
          ),
      ],
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({required this.inset, required this.color});

  final double inset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: inset),
      child: SizedBox(
        height: 1,
        child: ColoredBox(color: color, child: const SizedBox.expand()),
      ),
    );
  }
}

/// A row of a [GroupedSection]; it says where the hairline above it starts.
abstract class GroupedItem extends StatelessWidget {
  const GroupedItem({super.key});

  double get separatorInset;
}

class GroupedRow extends GroupedItem {
  const GroupedRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.value,
    this.chevron = false,
    this.onTap,
    this.titleWidget,
    this.leadingWidth = groupedLeadingSize,
  });

  final String title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final String? value;
  final bool chevron;
  final VoidCallback? onTap;

  /// The room the leading widget takes; wider than an icon where it carries a
  /// selection mark as well.
  final double leadingWidth;

  @override
  double get separatorInset => leading == null
      ? groupedRowPadding + 1
      : groupedRowPadding + leadingWidth + groupedLeadingGap;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        hoverColor: palette.hover,
        highlightColor: palette.hover,
        splashColor: Colors.transparent,
        child: SizedBox(
          height: groupedRowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: groupedRowPadding),
            child: Row(
              children: [
                if (leading != null) ...[
                  SizedBox(
                    width: leadingWidth,
                    height: groupedLeadingSize,
                    child: Center(child: leading),
                  ),
                  const SizedBox(width: groupedLeadingGap),
                ],
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleWidget ??
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: palette.rowTitle,
                          ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: palette.rowSubtitle,
                        ),
                    ],
                  ),
                ),
                if (value != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(value!, style: palette.rowValue),
                  ),
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: trailing,
                  ),
                if (chevron)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: GlyphIcon(
                      AppGlyphs.chevronForward,
                      size: 15,
                      color: palette.tertiary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A row that is one centred action, drawn in [color] where it destroys.
class GroupedButtonRow extends GroupedItem {
  const GroupedButtonRow({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  double get separatorInset => 0;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        hoverColor: palette.hover,
        highlightColor: palette.hover,
        splashColor: Colors.transparent,
        child: SizedBox(
          height: groupedRowHeight,
          child: Center(
            child: Text(
              label,
              style: palette.rowTitle.copyWith(
                color: onTap == null
                    ? palette.tertiary
                    : (color ?? palette.accent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A row that is a text field: its label, and the input filling the rest.
class GroupedFieldRow extends GroupedItem {
  const GroupedFieldRow({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.suffix,
    this.obscure = false,
    this.trailing,
  });

  final String label;
  final String hint;
  final String? suffix;
  final bool obscure;

  /// A control after the input, such as the eye that reveals a secret.
  final Widget? trailing;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  double get separatorInset => groupedRowPadding + 1;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return SizedBox(
      height: groupedRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: groupedRowPadding),
        child: Row(
          children: [
            Text(label, style: palette.rowTitle),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                obscureText: obscure,
                cursorColor: palette.accent,
                style: palette.rowTitle.copyWith(fontWeight: FontWeight.w500),
                decoration: InputDecoration.collapsed(
                  hintText: hint,
                  hintStyle: palette.rowTitle.copyWith(
                    fontWeight: FontWeight.w500,
                    color: palette.tertiary,
                  ),
                ),
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 8),
              Text(suffix!, style: palette.rowValue),
            ],
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

/// The tinted line icon at the start of a row.
class GroupedIcon extends StatelessWidget {
  const GroupedIcon(this.glyph, {super.key, this.color});

  final Glyph glyph;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GlyphIcon(
      glyph,
      size: groupedLeadingSize + 1,
      color: color ?? GroupedPalette.of(context).icon,
    );
  }
}

class GroupedSwitch extends StatelessWidget {
  const GroupedSwitch({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  static const _width = 40.0;
  static const _height = 23.0;
  static const _thumb = 19.0;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return Semantics(
      toggled: value,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: _width,
          height: _height,
          padding: const EdgeInsets.all((_height - _thumb) / 2),
          decoration: ShapeDecoration(
            color: value ? palette.icon : palette.switchOff,
            shape: AppShape.full,
          ),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: const SizedBox.square(
            dimension: _thumb,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
