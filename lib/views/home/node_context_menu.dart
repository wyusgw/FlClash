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
const _previewGap = 12.0;
const _screenMargin = 12.0;
const _liftScale = 1.04;

/// The long-press menu of a touch screen, after iOS's context menu: a blurred
/// backdrop, the pressed row lifted off it, and a card of lines beside the row,
/// each led by an icon, the [groups] parted by a thick band, and a red line for
/// what destroys. It answers with the value of the line that was tapped.
///
/// Given the [preview] of the row and where it sits ([previewRect], in the
/// screen's coordinates) the row is drawn in place and the card opens above or
/// below it; without them the card is titled with [title] and opens around
/// [anchor].
Future<T?> showNodeContextMenu<T>({
  required BuildContext context,
  required String title,
  required List<List<NodeMenuEntry<T>>> groups,
  required Offset anchor,
  Widget? preview,
  Rect? previewRect,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: const Color(0x00000000),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, animation, _) => _NodeContextMenu<T>(
      title: title,
      groups: groups,
      anchor: anchor,
      preview: preview,
      previewRect: previewRect,
      animation: animation,
    ),
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
          child,
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
    required this.animation,
    this.preview,
    this.previewRect,
  });

  final String title;
  final List<List<NodeMenuEntry<T>>> groups;
  final Offset anchor;
  final Widget? preview;
  final Rect? previewRect;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final padding = MediaQuery.paddingOf(context);
    final preview = this.preview;
    final rect = previewRect;
    final eased = animation.drive(CurveTween(curve: Curves.easeOutCubic));
    if (preview == null || rect == null) {
      return FadeTransition(
        opacity: eased,
        child: ScaleTransition(
          scale: Tween(begin: 0.9, end: 1.0).animate(eased),
          child: CustomSingleChildLayout(
            delegate: _MenuLayout(anchor: anchor, padding: padding),
            child: _card(context, palette, titled: true),
          ),
        ),
      );
    }
    final screen = MediaQuery.sizeOf(context);
    final fromRight = anchor.dx > screen.width / 2;
    final opensDown = rect.center.dy < screen.height / 2;
    return CustomMultiChildLayout(
      delegate: _PreviewLayout(
        rect: rect,
        padding: padding,
        fromRight: fromRight,
      ),
      children: [
        LayoutId(
          id: _PreviewSlot.preview,
          child: AnimatedBuilder(
            animation: eased,
            builder: (context, child) => Transform.scale(
              scale: 1 + (_liftScale - 1) * eased.value,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  shape: AppShape.all(14),
                  shadows: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.32 * eased.value),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
            child: Material(
              color: palette.fill,
              shape: AppShape.all(14),
              clipBehavior: Clip.antiAlias,
              child: IgnorePointer(child: preview),
            ),
          ),
        ),
        LayoutId(
          id: _PreviewSlot.menu,
          child: FadeTransition(
            opacity: eased,
            child: ScaleTransition(
              scale: Tween(begin: 0.8, end: 1.0).animate(eased),
              alignment: Alignment(fromRight ? 1 : -1, opensDown ? -1 : 1),
              child: _card(context, palette, titled: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _card(
    BuildContext context,
    GroupedPalette palette, {
    required bool titled,
  }) {
    return SizedBox(
      width: _cardWidth,
      child: Material(
        color: palette.bar.withValues(alpha: 0.92),
        shape: AppShape.all(34),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (titled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: palette.subhead.copyWith(color: palette.secondary),
                    ),
                  ),
                ),
              for (final (index, group) in groups.indexed) ...[
                if (titled || index > 0)
                  Container(height: _groupGap, color: palette.hover),
                for (final entry in group) _entry(context, palette, entry),
              ],
              if (titled) const SizedBox(height: 6),
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
                  style: palette.rowTitle.copyWith(color: color),
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

enum _PreviewSlot { preview, menu }

/// Draws the preview where the row was and the card above or below it, on the
/// side the finger was on, wherever there is room for it.
class _PreviewLayout extends MultiChildLayoutDelegate {
  _PreviewLayout({
    required this.rect,
    required this.padding,
    required this.fromRight,
  });

  final Rect rect;
  final EdgeInsets padding;
  final bool fromRight;

  @override
  void performLayout(Size size) {
    final previewSize = layoutChild(
      _PreviewSlot.preview,
      BoxConstraints.tightFor(width: rect.width),
    );
    positionChild(_PreviewSlot.preview, rect.topLeft);
    final previewBottom = rect.top + previewSize.height;

    final below = size.height - padding.bottom - _screenMargin - previewBottom;
    final above = rect.top - padding.top - _screenMargin;
    final room = (below > above ? below : above) - _previewGap;
    final menuSize = layoutChild(
      _PreviewSlot.menu,
      BoxConstraints(maxWidth: _cardWidth, maxHeight: room),
    );
    final opensDown = menuSize.height <= below - _previewGap;
    final top = opensDown
        ? previewBottom + _previewGap
        : rect.top - _previewGap - menuSize.height;
    final left = (fromRight ? rect.right - menuSize.width : rect.left).clamp(
      _screenMargin,
      size.width - menuSize.width - _screenMargin,
    );
    positionChild(_PreviewSlot.menu, Offset(left, top));
  }

  @override
  bool shouldRelayout(_PreviewLayout oldDelegate) =>
      oldDelegate.rect != rect ||
      oldDelegate.padding != padding ||
      oldDelegate.fromRight != fromRight;
}
