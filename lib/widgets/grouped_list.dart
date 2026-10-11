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

/// The rounded surface of a grouped section.
class GroupedCard extends StatelessWidget {
  const GroupedCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GroupedPalette.of(context).fill,
      shape: _cardShape,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
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
        GroupedCard(
          child: Column(
            children: [
              for (final (index, child) in children.indexed) ...[
                if (index > 0)
                  GroupedHairline(
                    inset: switch (children[index]) {
                      final GroupedInset item => item.separatorInset,
                      _ => 0,
                    },
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

/// The line between two rows, starting [inset] in.
class GroupedHairline extends StatelessWidget {
  const GroupedHairline({super.key, required this.inset});

  final double inset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: inset),
      child: SizedBox(
        height: 1,
        child: ColoredBox(
          color: GroupedPalette.of(context).separator,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

/// What says where the hairline above a row of a [GroupedSection] starts.
abstract interface class GroupedInset {
  double get separatorInset;
}

/// For a widget that builds a plain [GroupedRow], without a leading icon.
mixin GroupedPlainInset implements GroupedInset {
  @override
  double get separatorInset => groupedRowPadding + 1;
}

/// A row of a [GroupedSection].
abstract class GroupedItem extends StatelessWidget implements GroupedInset {
  const GroupedItem({super.key});

  @override
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
    this.subtitleWidget,
    this.leadingWidth = groupedLeadingSize,
  });

  final String title;
  final Widget? titleWidget;
  final String? subtitle;

  /// A subtitle that is more than a line of text; it takes [subtitle]'s place.
  final Widget? subtitleWidget;
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
        hoverColor: Colors.transparent,
        highlightColor: palette.hover,
        splashColor: Colors.transparent,
        child: SizedBox(
          height: groupedRowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: groupedRowPadding),
            child: LayoutBuilder(
              builder: (context, box) => Row(
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
                        if (subtitleWidget != null)
                          DefaultTextStyle.merge(
                            style: palette.rowSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            child: subtitleWidget!,
                          )
                        else if (subtitle != null)
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
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: box.maxWidth * 0.55,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          value!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: palette.rowValue,
                        ),
                      ),
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
        hoverColor: Colors.transparent,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The ring at the start of a row that can be ticked, filled once it is.
class GroupedSelectMark extends StatelessWidget {
  const GroupedSelectMark({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return SizedBox.square(
      dimension: groupedLeadingSize,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: selected ? palette.icon : Colors.transparent,
          shape: CircleBorder(
            side: selected
                ? BorderSide.none
                : BorderSide(color: palette.tertiary, width: 1.5),
          ),
        ),
        child: selected
            ? const GlyphIcon(
                AppGlyphs.check,
                size: 13,
                color: Color(0xFFFFFFFF),
              )
            : null,
      ),
    );
  }
}

/// A search field of the grouped look: a glyph, the input, and a way to clear.
class GroupedSearchField extends StatelessWidget {
  const GroupedSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.clearTooltip,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final String clearTooltip;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return GroupedCard(
      child: SizedBox(
        height: groupedRowHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: groupedRowPadding),
          child: Row(
            children: [
              GlyphIcon(AppGlyphs.search, size: 17, color: palette.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
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
              ListenableBuilder(
                listenable: controller,
                builder: (_, _) {
                  if (controller.text.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Tooltip(
                    message: clearTooltip,
                    child: InkResponse(
                      radius: 14,
                      onTap: () {
                        controller.clear();
                        onChanged?.call('');
                      },
                      child: GlyphIcon(
                        AppGlyphs.close,
                        size: 16,
                        color: palette.secondary,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A section whose body is free-form content rather than rows: its [header],
/// with [actions] at the end, over a card holding [child].
class GroupedBlock extends StatelessWidget {
  const GroupedBlock({
    super.key,
    required this.header,
    required this.child,
    this.actions = const [],
    this.footer,
    this.padding = const EdgeInsets.all(groupedRowPadding),
  });

  final String header;
  final List<Widget> actions;
  final String? footer;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            groupedRowPadding + 1,
            0,
            groupedRowPadding,
            6,
          ),
          child: Row(
            spacing: 12,
            children: [
              Expanded(child: Text(header, style: palette.sectionLabel)),
              ...actions,
            ],
          ),
        ),
        GroupedCard(
          child: Padding(padding: padding, child: child),
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

/// A word in the accent colour, for an action at the end of a block's header.
class GroupedTextAction extends StatelessWidget {
  const GroupedTextAction({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return InkResponse(
      onTap: onPressed,
      radius: 18,
      child: Text(
        label,
        style: palette.sectionLabel.copyWith(
          color: onPressed == null ? palette.tertiary : palette.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// An icon at the end of a block's header.
class GroupedIconAction extends StatelessWidget {
  const GroupedIconAction({
    super.key,
    required this.glyph,
    required this.tooltip,
    required this.onPressed,
  });

  final Glyph glyph;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 16,
        child: GlyphIcon(glyph, size: 16, color: palette.accent),
      ),
    );
  }
}
