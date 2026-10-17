import 'dart:ui';

import 'package:fl_clash/common/shape.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

/// One line of a [showNodeContextMenu] card.
class NodeMenuEntry<T> {
  const NodeMenuEntry({
    required this.value,
    required this.label,
    required this.glyph,
    this.danger = false,
  });

  final T value;
  final String label;
  final Glyph glyph;
  final bool danger;
}

const _cardWidth = 290.0;
const _entryHeight = 52.0;
const _groupGap = 8.0;

/// The long-press menu of a touch screen, after iOS's context menu: a blurred
/// card with the [title] over its lines, each led by an icon, the [groups]
/// parted by a thick band, and a red line for what destroys. It opens around
/// [anchor] and answers with the value of the line that was tapped.
Future<T?> showNodeContextMenu<T>({
  required BuildContext context,
  required String title,
  required List<List<NodeMenuEntry<T>>> groups,
  required Offset anchor,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: const Color(0x00000000),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) =>
        _NodeContextMenu<T>(title: title, groups: groups, anchor: anchor),
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeIn,
      );
      return Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 14 * curved.value,
                sigmaY: 14 * curved.value,
              ),
              child: ColoredBox(
                color: Color.fromRGBO(0, 0, 0, 0.28 * curved.value),
              ),
            ),
          ),
          FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 0.9, end: 1.0).animate(curved),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ],
      );
    },
  );
}

class _NodeContextMenu<T> extends StatelessWidget {
  const _NodeContextMenu({
    required this.title,
    required this.groups,
    required this.anchor,
  });

  final String title;
  final List<List<NodeMenuEntry<T>>> groups;
  final Offset anchor;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final padding = MediaQuery.paddingOf(context);
    return CustomSingleChildLayout(
      delegate: _MenuLayout(anchor: anchor, padding: padding),
      child: SizedBox(
        width: _cardWidth,
        child: Material(
          color: palette.bar.withValues(alpha: 0.92),
          shape: AppShape.all(34),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: palette.rowSubtitle.copyWith(fontSize: 15),
                  ),
                ),
              ),
              for (final group in groups) ...[
                Container(height: _groupGap, color: palette.hover),
                for (final entry in group) _entry(context, palette, entry),
              ],
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _entry(
    BuildContext context,
    GroupedPalette palette,
    NodeMenuEntry<T> entry,
  ) {
    final color = entry.danger ? groupedDanger : palette.label;
    return InkWell(
      onTap: () => Navigator.of(context).pop(entry.value),
      highlightColor: palette.hover,
      splashColor: Colors.transparent,
      child: SizedBox(
        height: _entryHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 26,
                child: Center(
                  child: GlyphIcon(entry.glyph, size: 24, color: color),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  entry.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: palette.rowTitle.copyWith(fontSize: 19, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuLayout extends SingleChildLayoutDelegate {
  const _MenuLayout({required this.anchor, required this.padding});

  final Offset anchor;
  final EdgeInsets padding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(
      Size(constraints.maxWidth, constraints.maxHeight - padding.vertical - 24),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final top = (anchor.dy - childSize.height / 3).clamp(
      padding.top + 12,
      size.height - padding.bottom - childSize.height - 12,
    );
    return Offset((size.width - childSize.width) / 2, top);
  }

  @override
  bool shouldRelayout(_MenuLayout oldDelegate) =>
      oldDelegate.anchor != anchor || oldDelegate.padding != padding;
}
