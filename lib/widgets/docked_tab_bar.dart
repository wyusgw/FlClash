import 'package:fl_clash/icons/icons.dart';
import 'package:material_ui/material_ui.dart';

import 'grouped_list.dart';
import 'navigation_dock.dart';

const double _tabBarHeight = 49;
const double _tabIconSize = 22;
const double _tabLabelSize = 9.5;

/// The bar along the foot of a narrow window or a phone: flat on the bar
/// color under a hairline, one icon over a small label for each page, the
/// page in view in the accent color.
class DockedTabBar extends StatelessWidget {
  const DockedTabBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<NavigationDockDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return ColoredBox(
      color: palette.bar,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 1, child: ColoredBox(color: palette.separator)),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom,
            ),
            child: SizedBox(
              height: _tabBarHeight,
              child: Row(
                children: [
                  for (final (index, destination) in destinations.indexed)
                    Expanded(
                      child: _DockedTab(
                        destination: destination,
                        selected: index == selectedIndex,
                        onTap: () => onSelected(index),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DockedTab extends StatelessWidget {
  const _DockedTab({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavigationDockDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final color = selected ? palette.accent : palette.secondary;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 2,
          children: [
            GlyphIcon(destination.glyph, size: _tabIconSize, color: color),
            Text(
              destination.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: _tabLabelSize,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
