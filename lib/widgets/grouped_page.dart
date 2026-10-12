import 'dart:math' show max;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'grouped_list.dart';
import 'inherited.dart';
import 'popup.dart';

const _barContentHeight = 40.0;
const _desktopTitleStrip = 22.0;
const _barButton = 34.0;

class GroupedBarAction {
  const GroupedBarAction({
    this.glyph,
    this.label,
    required this.tooltip,
    required this.onPressed,
  }) : assert(glyph != null || label != null),
       menuItems = null;

  const GroupedBarAction.menu({
    required Glyph this.glyph,
    required this.tooltip,
    required List<CommonPopupMenuItem> this.menuItems,
  }) : label = null,
       onPressed = null;

  final Glyph? glyph;

  /// A word in place of the icon, as on a page's save action.
  final String? label;
  final String tooltip;
  final VoidCallback? onPressed;

  /// Entries the button opens as a menu instead of calling [onPressed].
  final List<CommonPopupMenuItem>? menuItems;
}

/// A page of the grouped look: a flat bar with a centred title and one action
/// at each end, over a canvas of grouped sections.
class GroupedPage extends StatelessWidget {
  const GroupedPage({
    super.key,
    required this.title,
    required this.body,
    this.leading,
    this.leadingActions = const [],
    this.trailing,
    this.trailingActions = const [],
    this.titleWidget,
    this.onBack,
  });

  final String title;

  /// Content in the bar's centre in place of the [title] text, such as a field
  /// that renames the page's subject.
  final Widget? titleWidget;
  final Widget body;
  final GroupedBarAction? leading;

  /// Words with icons side by side at the start, in place of [leading].
  final List<GroupedBarAction> leadingActions;
  final GroupedBarAction? trailing;

  /// Buttons side by side at the end, in place of [trailing].
  final List<GroupedBarAction> trailingActions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final topInset = system.isDesktop
        ? _desktopTitleStrip
        : MediaQuery.paddingOf(context).top;
    final back = onBack == null
        ? null
        : GroupedBarAction(
            glyph: AppGlyphs.chevronBack,
            tooltip: context.appLocalizations.back,
            onPressed: onBack,
          );
    return Material(
      color: palette.canvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: palette.bar,
            child: Padding(
              padding: EdgeInsets.only(top: topInset),
              child: SizedBox(
                height: _barContentHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            _barButton * max(1, trailingActions.length) + 16,
                      ),
                      child:
                          titleWidget ??
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: palette.rowTitle,
                          ),
                    ),
                    PositionedDirectional(
                      start: leadingActions.isEmpty ? 11 : 12,
                      child: leadingActions.isEmpty
                          ? _BarButton(action: back ?? leading)
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 6,
                              children: [
                                for (final action in leadingActions)
                                  _BarButton(action: action),
                              ],
                            ),
                    ),
                    PositionedDirectional(
                      end: 6,
                      child: trailingActions.isEmpty
                          ? _BarButton(action: trailing)
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 2,
                              children: [
                                for (final action in trailingActions)
                                  _BarButton(action: action),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({required this.action});

  final GroupedBarAction? action;

  Widget _content(BuildContext context, GroupedBarAction action) {
    final palette = GroupedPalette.of(context);
    final glyph = action.glyph;
    final label = action.label;
    final enabled = action.onPressed != null;
    if (label == null) {
      return SizedBox.square(
        dimension: _barButton,
        child: Center(child: GlyphIcon(glyph!, size: 22, color: palette.label)),
      );
    }
    final color = glyph == null
        ? (enabled ? palette.accent : palette.tertiary)
        : (enabled ? palette.label : palette.tertiary);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 3,
        children: [
          if (glyph != null) GlyphIcon(glyph, size: 15, color: color),
          Text(label, style: palette.rowTitle.copyWith(color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    if (action == null) {
      return const SizedBox.shrink();
    }
    final menuItems = action.menuItems;
    if (menuItems != null) {
      return CommonPopupBox(
        popupBuilder: (_) => CommonPopupMenu(items: menuItems),
        targetBuilder: (open) => Tooltip(
          message: action.tooltip,
          child: InkResponse(
            onTap: open,
            radius: _barButton / 2,
            child: _content(context, action),
          ),
        ),
      );
    }
    return Tooltip(
      message: action.tooltip,
      child: InkResponse(
        onTap: action.onPressed,
        radius: _barButton / 2,
        child: _content(context, action),
      ),
    );
  }
}

/// The scrolling body of a grouped page: [children] on the canvas, clear of
/// the bar above and of whatever covers the bottom.
class GroupedBody extends StatelessWidget {
  const GroupedBody({super.key, required this.children, this.controller});

  final List<Widget> children;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(
        groupedPageInset,
        13,
        groupedPageInset,
        20 + BottomInsetScope.of(context),
      ),
      children: children,
    );
  }
}

/// A page of choices with the one in use checked.
class GroupedChoicePage<T> extends StatelessWidget {
  const GroupedChoicePage({
    super.key,
    required this.title,
    required this.choices,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final Map<T, String> choices;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return GroupedPage(
      title: title,
      onBack: () => Navigator.of(context).maybePop(),
      body: GroupedBody(
        children: [
          GroupedSection(
            children: [
              for (final entry in choices.entries)
                GroupedRow(
                  key: ValueKey(entry.key),
                  title: entry.value,
                  trailing: entry.key == selected
                      ? GlyphIcon(
                          AppGlyphs.check,
                          size: 18,
                          color: palette.icon,
                        )
                      : null,
                  onTap: () => onSelected(entry.key),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A page of On and Off with the one in use checked and an explanation under
/// them, for an option whose row on the page before shows only its state.
class GroupedTogglePage extends ConsumerWidget {
  const GroupedTogglePage({
    super.key,
    required this.title,
    required this.description,
    required this.read,
    required this.write,
  });

  final String title;
  final String description;

  /// The current value, read from [ref] so the page follows it.
  final bool Function(WidgetRef ref) read;
  final void Function(WidgetRef ref, bool value) write;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final value = read(ref);
    Widget row(String label, bool choice) {
      return GroupedRow(
        title: label,
        trailing: value == choice
            ? GlyphIcon(AppGlyphs.check, size: 18, color: palette.icon)
            : null,
        onTap: () => write(ref, choice),
      );
    }

    return GroupedPage(
      title: title,
      onBack: () => Navigator.of(context).maybePop(),
      body: GroupedBody(
        children: [
          GroupedSection(
            footer: description,
            children: [
              row(appLocalizations.on, true),
              row(appLocalizations.off, false),
            ],
          ),
        ],
      ),
    );
  }
}
