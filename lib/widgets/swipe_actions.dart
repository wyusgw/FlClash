import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

import 'grouped_list.dart';

/// The green of a swipe action that runs something harmless, such as a test.
const swipeActionGo = Color(0xFF34C759);

/// The gray of a swipe action that only hands something out.
const swipeActionNeutral = Color(0xFF8E8E93);

/// One button a [SwipeActions] row reveals.
class SwipeAction {
  const SwipeAction({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;
}

const _buttonWidth = 74.0;
const _gap = 8.0;

double _extent(List<SwipeAction> actions) =>
    actions.isEmpty ? 0 : actions.length * (_buttonWidth + _gap) + _gap;

/// A row that slides aside to reveal buttons: dragged right it shows
/// [leading] at its start, dragged left [trailing] at its end. A tap on a
/// button runs it and closes the row; a tap on the row while it is open, or
/// opening another row, only closes it.
class SwipeActions extends StatefulWidget {
  const SwipeActions({
    super.key,
    this.leading = const [],
    this.trailing = const [],
    this.enabled = true,
    required this.child,
  });

  final List<SwipeAction> leading;
  final List<SwipeAction> trailing;
  final bool enabled;
  final Widget child;

  @override
  State<SwipeActions> createState() => _SwipeActionsState();
}

class _SwipeActionsState extends State<SwipeActions>
    with SingleTickerProviderStateMixin {
  /// The one row left open, closed when another starts to move.
  static _SwipeActionsState? _open;

  late final AnimationController _offset = AnimationController.unbounded(
    vsync: this,
  );

  double get _leadingExtent => _extent(widget.leading);
  double get _trailingExtent => _extent(widget.trailing);

  @override
  void didUpdateWidget(covariant SwipeActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _offset.value != 0) {
      _close();
    }
  }

  @override
  void dispose() {
    if (_open == this) _open = null;
    _offset.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _offset.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
    if (target == 0) {
      if (_open == this) _open = null;
    } else {
      _open = this;
    }
  }

  void _close() => _animateTo(0);

  void _handleDragStart(DragStartDetails details) {
    final other = _open;
    if (other != null && other != this && other.mounted) {
      other._close();
    }
    _offset.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _offset.value = (_offset.value + details.primaryDelta!).clamp(
      -_trailingExtent,
      _leadingExtent,
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final value = _offset.value;
    if (value > 0) {
      final open =
          velocity > 300 || (velocity > -300 && value > _leadingExtent / 2);
      _animateTo(open ? _leadingExtent : 0);
    } else if (value < 0) {
      final open =
          velocity < -300 || (velocity < 300 && -value > _trailingExtent / 2);
      _animateTo(open ? -_trailingExtent : 0);
    }
  }

  Widget _buttons(List<SwipeAction> actions, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _gap / 2, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final action in actions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _gap / 2),
                child: SizedBox(
                  width: _buttonWidth,
                  child: Material(
                    color: action.color,
                    shape: AppShape.full,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        _close();
                        action.onPressed();
                      },
                      child: Center(
                        child: Text(
                          action.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled ||
        (widget.leading.isEmpty && widget.trailing.isEmpty)) {
      return widget.child;
    }
    final palette = GroupedPalette.of(context);
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: AnimatedBuilder(
        animation: _offset,
        builder: (context, child) {
          final offset = _offset.value;
          return ClipRect(
            child: Stack(
              children: [
                if (offset != 0)
                  Positioned.fill(
                    child: ColoredBox(
                      color: palette.canvas,
                      child: offset > 0
                          ? _buttons(widget.leading, Alignment.centerLeft)
                          : _buttons(widget.trailing, Alignment.centerRight),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(offset, 0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: offset == 0 ? null : _close,
                    child: IgnorePointer(ignoring: offset != 0, child: child),
                  ),
                ),
              ],
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
