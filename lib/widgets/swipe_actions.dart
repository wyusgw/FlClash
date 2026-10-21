import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

import 'grouped_list.dart';
import 'haptics.dart';

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
    this.fullSwipe = false,
    this.slideOut = false,
  });

  final String label;
  final Color color;
  final FutureOr<void> Function() onPressed;

  /// Whether dragging the row all the way across runs this action.
  final bool fullSwipe;

  /// Whether a full swipe carries the row off the screen before running this
  /// action. The row comes back if it is still there once the action ends.
  final bool slideOut;
}

const _buttonWidth = 74.0;
const _gap = 8.0;
const _fullSwipeFraction = 0.55;
const _fullSwipeVelocity = 2000.0;
const _pastExtentResistance = 0.6;
const _closeDuration = Duration(milliseconds: 340);

/// How much of a button's width has to come into view for it to be whole;
/// until then it fades and grows in, and on the way shut it does the same
/// backwards, one button after another from the one nearest the row.
const _buttonRevealShare = 0.9;
const _buttonRestScale = 0.82;

double _extent(List<SwipeAction> actions) =>
    actions.isEmpty ? 0 : actions.length * (_buttonWidth + _gap) + _gap;

/// A row that slides aside to reveal buttons: dragged right it shows
/// [leading] at its start, dragged left [trailing] at its end. A tap on a
/// button runs it and closes the row; a tap on the row while it is open, or
/// opening another row, only closes it. Dragging on across the row, to an
/// action marked [SwipeAction.fullSwipe], ticks once it is armed and runs it
/// on release.
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

  SwipeAction? _full(List<SwipeAction> actions) =>
      actions.where((action) => action.fullSwipe).firstOrNull;

  double get _width => context.size?.width ?? 0;

  double _reach(List<SwipeAction> actions, double extent) =>
      _full(actions) == null ? extent : _width;

  double _threshold(double extent) =>
      (_width * _fullSwipeFraction).clamp(extent * 1.3, double.infinity);

  bool _armed(double offset) {
    if (offset > 0 && _full(widget.leading) != null) {
      return offset >= _threshold(_leadingExtent);
    }
    if (offset < 0 && _full(widget.trailing) != null) {
      return -offset >= _threshold(_trailingExtent);
    }
    return false;
  }

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
      duration: target == 0
          ? _closeDuration
          : const Duration(milliseconds: 220),
      curve: target == 0 ? Curves.easeInOutCubic : Curves.easeOutCubic,
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
    final wasArmed = _armed(_offset.value);
    final delta = details.primaryDelta!;
    final extent = delta > 0 ? _leadingExtent : _trailingExtent;
    final pastExtent =
        _offset.value.abs() >= extent && _offset.value * delta > 0;
    final step = pastExtent ? delta * _pastExtentResistance : delta;
    _offset.value = (_offset.value + step).clamp(
      -_reach(widget.trailing, _trailingExtent),
      _reach(widget.leading, _leadingExtent),
    );
    if (_armed(_offset.value) != wasArmed) {
      selectionHaptic(context);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final value = _offset.value;
    final action = _full(value > 0 ? widget.leading : widget.trailing);
    final flung =
        velocity.abs() >= _fullSwipeVelocity &&
        velocity.sign == value.sign &&
        value.abs() > (value > 0 ? _leadingExtent : _trailingExtent);
    if (action != null && (_armed(value) || flung)) {
      unawaited(_runFullSwipe(action, value.sign));
    } else if (value > 0) {
      final open =
          velocity > 300 || (velocity > -300 && value > _leadingExtent / 2);
      _animateTo(open ? _leadingExtent : 0);
    } else if (value < 0) {
      final open =
          velocity < -300 || (velocity < 300 && -value > _trailingExtent / 2);
      _animateTo(open ? -_trailingExtent : 0);
    }
  }

  Future<void> _runFullSwipe(SwipeAction action, double direction) async {
    if (!action.slideOut) {
      _close();
      await action.onPressed();
      return;
    }
    await _offset.animateTo(
      direction * _width,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
    await action.onPressed();
    if (mounted) _close();
  }

  Widget _buttons(
    List<SwipeAction> actions,
    Alignment alignment,
    double reveal,
  ) {
    final stretch = reveal > _extent(actions) ? _full(actions) : null;
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _gap / 2, vertical: 6),
        child: SizedBox(
          width: stretch == null ? null : reveal - _gap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, action) in actions.indexed)
                _faded(
                  // A button stretched across a full swipe is whole already.
                  progress: stretch != null
                      ? 1
                      : _progressOf(
                          // Counted from the edge the buttons sit against.
                          alignment == Alignment.centerRight
                              ? actions.length - 1 - index
                              : index,
                          reveal,
                        ),
                  child: _button(
                    action,
                    stretch: action == stretch,
                    alignRow:
                        action == stretch && alignment == Alignment.centerRight,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// How far the button [slot] places from the screen's edge has come into
  /// view, from 0 to 1, once [reveal] of the row has been drawn aside.
  double _progressOf(int slot, double reveal) {
    final start = _gap + slot * (_buttonWidth + _gap);
    return Curves.easeOut.transform(
      ((reveal - start) / (_buttonWidth * _buttonRevealShare)).clamp(0.0, 1.0),
    );
  }

  Widget _faded({required double progress, required Widget child}) {
    if (progress >= 1) {
      return child;
    }
    return Opacity(
      opacity: progress,
      child: Transform.scale(
        scale: _buttonRestScale + (1 - _buttonRestScale) * progress,
        child: child,
      ),
    );
  }

  Widget _button(
    SwipeAction action, {
    required bool stretch,
    bool alignRow = false,
  }) {
    final button = Padding(
      padding: const EdgeInsets.symmetric(horizontal: _gap / 2),
      child: SizedBox(
        width: stretch ? null : _buttonWidth,
        child: Material(
          color: action.color,
          shape: AppShape.full,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              _close();
              unawaited(Future.sync(action.onPressed));
            },
            child: Align(
              alignment: alignRow ? Alignment.centerLeft : Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: alignRow ? 20 : 0),
                child: Text(
                  action.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GroupedPalette.of(context).subhead.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return stretch ? Expanded(child: button) : button;
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
                          ? _buttons(
                              widget.leading,
                              Alignment.centerLeft,
                              offset,
                            )
                          : _buttons(
                              widget.trailing,
                              Alignment.centerRight,
                              -offset,
                            ),
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
