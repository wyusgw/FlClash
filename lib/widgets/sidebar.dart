import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:material_ui/material_ui.dart';

import 'grouped_list.dart';

const _gripWidth = 8.0;
const _itemHeight = 26.5;
const _itemGap = 1.0;
const _sideInset = 6.0;
const _topInset = 1.0;
const _iconSize = 20.0;
const _iconInset = 5.0;
const _labelGap = 6.0;
final _itemShape = AppShape.all(6);

class SidebarDestination {
  const SidebarDestination({required this.glyph, required this.label});

  final Glyph glyph;
  final String label;
}

/// The window's left pane: every destination as an icon and a label, the
/// selected one on a solid accent. [windowControls] is the area native window
/// buttons cover at the top start corner, which the list stays clear of. The
/// edge next to the content drags the pane between [minSidebarWidth] and
/// [maxSidebarWidth]; [onResize] hears the width once the drag ends, and a
/// double tap on the edge asks for [defaultSidebarWidth] again.
class NavigationSidebar extends StatefulWidget {
  const NavigationSidebar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.windowControls = Size.zero,
    this.width = defaultSidebarWidth,
    this.onResize,
  });

  final List<SidebarDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Size windowControls;
  final double width;
  final ValueChanged<double>? onResize;

  @override
  State<NavigationSidebar> createState() => _NavigationSidebarState();
}

class _NavigationSidebarState extends State<NavigationSidebar> {
  double? _dragWidth;

  double _clamp(double value) => value.clamp(minSidebarWidth, maxSidebarWidth);

  void _drag(DragUpdateDetails details, bool isLtr) {
    final delta = isLtr ? details.delta.dx : -details.delta.dx;
    setState(() => _dragWidth = _clamp((_dragWidth ?? widget.width) + delta));
  }

  void _endDrag() {
    final width = _dragWidth;
    setState(() => _dragWidth = null);
    if (width != null) {
      widget.onResize?.call(width);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final safePadding = MediaQuery.paddingOf(context);
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    final resizable = widget.onResize != null;
    return SizedBox(
      width: _clamp(_dragWidth ?? widget.width),
      child: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: palette.sidebar,
              child: Padding(
                padding: EdgeInsets.only(
                  top:
                      math.max(widget.windowControls.height, safePadding.top) +
                      _topInset,
                  left: _sideInset,
                  right: _sideInset,
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final (index, destination)
                        in widget.destinations.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: _itemGap),
                        child: _SidebarItem(
                          key: ValueKey(destination.label),
                          destination: destination,
                          selected: index == widget.selectedIndex,
                          onTap: () => widget.onSelected(index),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (resizable)
            PositionedDirectional(
              top: 0,
              bottom: 0,
              end: 0,
              width: _gripWidth,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  key: const ValueKey('sidebar-grip'),
                  behavior: HitTestBehavior.translucent,
                  dragStartBehavior: DragStartBehavior.down,
                  onHorizontalDragUpdate: (details) => _drag(details, isLtr),
                  onHorizontalDragEnd: (_) => _endDrag(),
                  onHorizontalDragCancel: _endDrag,
                  onDoubleTap: () => widget.onResize?.call(defaultSidebarWidth),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    super.key,
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final SidebarDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final onAccent = selected ? const Color(0xFFFFFFFF) : null;
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      child: Material(
        color: selected ? palette.accent : Colors.transparent,
        shape: _itemShape,
        child: InkWell(
          onTap: onTap,
          customBorder: _itemShape,
          mouseCursor: SystemMouseCursors.basic,
          splashFactory: NoSplash.splashFactory,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: SizedBox(
            height: _itemHeight,
            child: Row(
              children: [
                const SizedBox(width: _iconInset),
                GlyphIcon(
                  destination.glyph,
                  size: _iconSize,
                  color: onAccent ?? palette.accent,
                ),
                const SizedBox(width: _labelGap),
                Expanded(
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: palette.rowTitle.copyWith(
                      fontSize: 13,
                      color: palette.label,
                    ),
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
