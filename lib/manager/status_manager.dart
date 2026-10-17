import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/ios_controls.dart';
import 'package:fl_clash/widgets/navigation_dock.dart';
import 'package:fl_clash/widgets/theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _actionMinDuration = Duration(seconds: 6);
const _maxBufferedMessages = 8;
const _maxVisibleMessages = 1;
const _messageEnterDuration = Duration(milliseconds: 450);
const _messageExitDuration = Duration(milliseconds: 300);
const _messageSwipeOutDuration = Duration(milliseconds: 200);
const _messageSwipeBackDuration = Duration(milliseconds: 300);
const _messageEnterScale = 0.94;
const _swipeDismissFraction = 0.35;
const _swipeDismissVelocity = 700.0;
const _messageMinWidth = 116.0;
const _messageMaxWidth = 184.0;
const _messageGlyphSize = 30.0;
const _messageColor = Color(0xE62C2C2E);
const _messageContentColor = Color(0xFFFFFFFF);

class StatusManager extends ConsumerStatefulWidget {
  final Widget child;

  const StatusManager({super.key, required this.child});

  @override
  ConsumerState<StatusManager> createState() => StatusManagerState();
}

class StatusManagerState extends ConsumerState<StatusManager> {
  final _entriesNotifier = ValueNotifier<List<_MessageEntry>>([]);
  final _bufferMessages = Queue<CommonMessage>();
  final _activeTimers = <String, Timer>{};
  String? _draggingId;

  @override
  void dispose() {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    _bufferMessages.clear();
    _entriesNotifier.dispose();
    super.dispose();
  }

  List<_MessageEntry> get _entries => _entriesNotifier.value;

  Iterable<_MessageEntry> get _visibleEntries =>
      _entries.where((entry) => entry.visible);

  void message(
    String text, {
    MessageLevel level = MessageLevel.info,
    MessageActionState? actionState,
  }) {
    if (text.isEmpty) {
      return;
    }
    final commonMessage = CommonMessage(
      id: uuidV4,
      text: text,
      level: level,
      duration: _resolveDuration(level, actionState),
      actionState: actionState,
    );
    commonPrint.log('message: $text');
    if (_mergeMessage(commonMessage)) {
      return;
    }
    _bufferMessages.add(commonMessage);
    _trimBuffer();
    _processQueue();
  }

  Duration _resolveDuration(
    MessageLevel level,
    MessageActionState? actionState,
  ) {
    final duration = level.duration;
    if (actionState == null || duration >= _actionMinDuration) {
      return duration;
    }
    return _actionMinDuration;
  }

  bool _isSameMessage(CommonMessage a, CommonMessage b) =>
      a.text == b.text && a.level == b.level;

  bool _mergeMessage(CommonMessage message) {
    final entries = _entries;
    final index = entries.indexWhere(
      (entry) => entry.visible && _isSameMessage(entry.message, message),
    );
    if (index != -1) {
      final merged = message.copyWith(id: entries[index].message.id);
      _entriesNotifier.value = List<_MessageEntry>.from(entries)
        ..[index] = entries[index].copyWith(message: merged);
      _startTimer(merged);
      return true;
    }
    return _bufferMessages.any((buffered) => _isSameMessage(buffered, message));
  }

  void _trimBuffer() {
    while (_bufferMessages.length > _maxBufferedMessages) {
      final dropped =
          _bufferMessages.firstWhereOrNull(
            (message) => message.level != MessageLevel.error,
          ) ??
          _bufferMessages.first;
      _bufferMessages.remove(dropped);
    }
  }

  void _processQueue() {
    if (_draggingId != null) {
      return;
    }
    while (_bufferMessages.isNotEmpty) {
      final visible = _visibleEntries.toList();
      if (visible.length < _maxVisibleMessages) {
        _showMessage(_bufferMessages.removeFirst());
        continue;
      }
      final error = _bufferMessages.firstWhereOrNull(
        (message) => message.level == MessageLevel.error,
      );
      if (error == null) {
        return;
      }
      final preempted = visible.lastWhereOrNull(
        (entry) => entry.message.level != MessageLevel.error,
      );
      if (preempted == null) {
        return;
      }
      _hideMessage(preempted.id);
      _bufferMessages.remove(error);
      _showMessage(error);
    }
  }

  void _showMessage(CommonMessage message) {
    _entriesNotifier.value = List<_MessageEntry>.from(_entries)
      ..insert(0, _MessageEntry(message: message, visible: true));
    _startTimer(message);
  }

  void _startTimer(CommonMessage message) {
    _activeTimers.remove(message.id)?.cancel();
    if (_draggingId != null) {
      return;
    }
    _activeTimers[message.id] = Timer(message.duration, () {
      _hideMessage(message.id);
      _processQueue();
    });
  }

  void _hideMessage(String id, {bool swiped = false}) {
    _activeTimers.remove(id)?.cancel();
    final entries = _entries;
    final index = entries.indexWhere((entry) => entry.id == id);
    if (index == -1 || !entries[index].visible) {
      return;
    }
    _entriesNotifier.value = List<_MessageEntry>.from(entries)
      ..[index] = entries[index].copyWith(visible: false, swiped: swiped);
  }

  void _cancelMessage(String id, {bool swiped = false}) {
    if (_draggingId == id) {
      _draggingId = null;
    }
    _bufferMessages.removeWhere((message) => message.id == id);
    _hideMessage(id, swiped: swiped);
    _resumeTimers();
    _processQueue();
  }

  void _setDragging(String id, bool dragging) {
    if (dragging) {
      if (_draggingId == id) {
        return;
      }
      _draggingId = id;
      for (final timer in _activeTimers.values) {
        timer.cancel();
      }
      _activeTimers.clear();
      return;
    }
    if (_draggingId != id) {
      return;
    }
    _draggingId = null;
    _resumeTimers();
    _processQueue();
  }

  void _resumeTimers() {
    for (final entry in _visibleEntries.toList()) {
      if (_activeTimers.containsKey(entry.id)) {
        continue;
      }
      _startTimer(entry.message);
    }
  }

  void _removeMessage(String id) {
    if (!mounted) {
      return;
    }
    final entries = _entries;
    if (!entries.any((entry) => entry.id == id)) {
      return;
    }
    _entriesNotifier.value = entries
        .where((entry) => entry.id != id)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: ValueListenableBuilder(
            valueListenable: _entriesNotifier,
            builder: (_, entries, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  for (final entry in entries)
                    _MessageTransition(
                      key: Key(entry.id),
                      visible: entry.visible,
                      swiped: entry.swiped,
                      onHidden: () => _removeMessage(entry.id),
                      child: _MessageCard(
                        message: entry.message,
                        onDismiss: _cancelMessage,
                        onDragging: _setDragging,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MessageEntry {
  const _MessageEntry({
    required this.message,
    required this.visible,
    this.swiped = false,
  });

  final CommonMessage message;
  final bool visible;
  final bool swiped;

  String get id => message.id;

  _MessageEntry copyWith({
    CommonMessage? message,
    bool? visible,
    bool? swiped,
  }) {
    return _MessageEntry(
      message: message ?? this.message,
      visible: visible ?? this.visible,
      swiped: swiped ?? this.swiped,
    );
  }
}

class _MessageTransition extends StatefulWidget {
  const _MessageTransition({
    super.key,
    required this.visible,
    required this.swiped,
    required this.onHidden,
    required this.child,
  });

  final bool visible;
  final bool swiped;
  final VoidCallback onHidden;
  final Widget child;

  @override
  State<_MessageTransition> createState() => _MessageTransitionState();
}

class _MessageTransitionState extends State<_MessageTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _opacity;
  late final CurvedAnimation _settle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _messageEnterDuration,
      reverseDuration: _messageExitDuration,
      vsync: this,
    )..addStatusListener(_handleAnimationStatus);
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5, curve: Curves.easeOut),
      reverseCurve: const Interval(0.5, 1, curve: Curves.easeIn),
    );
    _settle = CurvedAnimation(
      parent: _controller,
      curve: Easing.emphasizedDecelerate,
      reverseCurve: const Interval(0.4, 1, curve: Curves.easeInCubic),
    );
    if (widget.visible) {
      _controller.forward();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !widget.visible) {
        widget.onHidden();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _MessageTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) {
      return;
    }
    if (widget.visible) {
      _controller.forward();
      return;
    }
    _controller.reverse();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !widget.visible) {
      widget.onHidden();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _opacity.dispose();
    _settle.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final settle = widget.swiped ? 1.0 : _settle.value;
        return Transform.scale(
          scale: _messageEnterScale + (1 - _messageEnterScale) * settle,
          child: child,
        );
      },
      child: FadeTransition(
        opacity: _opacity,
        child: IgnorePointer(ignoring: !widget.visible, child: widget.child),
      ),
    );
  }
}

class _MessageCard extends StatefulWidget {
  const _MessageCard({
    required this.message,
    required this.onDismiss,
    required this.onDragging,
  });

  final CommonMessage message;
  final void Function(String id, {bool swiped}) onDismiss;
  final void Function(String id, bool dragging) onDragging;

  @override
  State<_MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<_MessageCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drag;
  double _width = 0;
  bool _leaving = false;

  String get _id => widget.message.id;

  @override
  void initState() {
    super.initState();
    _drag = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    _drag.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    if (_leaving) {
      return;
    }
    _width = context.size?.width ?? 0;
    _drag.stop();
    widget.onDragging(_id, true);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_leaving) {
      return;
    }
    _drag.value += details.primaryDelta ?? 0;
  }

  Future<void> _release(double velocity) async {
    if (_leaving) {
      return;
    }
    final offset = _drag.value;
    final flung =
        velocity.abs() >= _swipeDismissVelocity && velocity.sign == offset.sign;
    if (_width > 0 &&
        (flung || offset.abs() >= _width * _swipeDismissFraction)) {
      _leaving = true;
      await _drag.animateTo(
        offset.sign * math.max(_width, offset.abs()),
        duration: _messageSwipeOutDuration,
        curve: Curves.easeOut,
      );
      if (mounted) {
        widget.onDismiss(_id, swiped: true);
      }
      return;
    }
    widget.onDragging(_id, false);
    _drag.animateTo(
      0,
      duration: _messageSwipeBackDuration,
      curve: Easing.emphasizedDecelerate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    return AnimatedBuilder(
      animation: _drag,
      builder: (_, child) {
        final offset = _drag.value;
        final progress = _width > 0 ? offset.abs() / _width : 0.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Opacity(opacity: 1 - progress.clamp(0.0, 1.0), child: child),
        );
      },
      child: GestureDetector(
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: (details) {
          _release(details.primaryVelocity ?? 0);
        },
        onHorizontalDragCancel: () {
          _release(0);
        },
        child: Material(
          color: _messageColor,
          surfaceTintColor: Colors.transparent,
          shape: AppShape.md,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: _messageMinWidth,
              maxWidth: _messageMaxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: _MessageContent(
                message: message,
                onDismiss: widget.onDismiss,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  const _MessageContent({required this.message, required this.onDismiss});

  final CommonMessage message;
  final void Function(String id, {bool swiped}) onDismiss;

  @override
  Widget build(BuildContext context) {
    final actionState = message.actionState;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlyphIcon(
          message.level.glyph,
          size: _messageGlyphSize,
          color: _messageContentColor,
        ),
        const SizedBox(height: 5),
        Text(
          message.text,
          maxLines: 8,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelMedium?.copyWith(
            color: _messageContentColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (actionState != null) ...[
          const SizedBox(height: 14),
          ElasticButton(
            child: IosButton(
              tonal: true,
              onPressed: () {
                onDismiss(message.id);
                actionState.action();
              },
              label: actionState.actionText,
            ),
          ),
        ],
      ],
    );
  }
}
