import 'package:fl_clash/common/common.dart';
import 'package:flutter/gestures.dart' show kSecondaryButton;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'grouped_list.dart';
import 'text_menu.dart';

/// Text typed in place, with no box around it: a caret, the selection by
/// press and drag, and the system's menu for Cut, Copy and Paste. A bare
/// [EditableText] has none of the gestures, which a field draws from its own
/// wrapper.
class GroupedEditableText extends StatefulWidget {
  const GroupedEditableText({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.style,
    required this.cursorColor,
    required this.selectionColor,
    this.autofocus = true,
    this.textAlign = TextAlign.start,
    this.strutStyle,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.onEditingComplete,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle style;
  final Color cursorColor;
  final Color selectionColor;
  final bool autofocus;
  final TextAlign textAlign;
  final StrutStyle? strutStyle;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;

  @override
  State<GroupedEditableText> createState() => _GroupedEditableTextState();
}

class _GroupedEditableTextState extends State<GroupedEditableText>
    implements TextSelectionGestureDetectorBuilderDelegate {
  @override
  final editableTextKey = GlobalKey<EditableTextState>();

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => true;

  late final _gestures = TextSelectionGestureDetectorBuilder(delegate: this);
  bool _secondaryPress = false;
  bool _menuBuilt = false;

  // A right click in an empty field moves nothing, so the field raises no
  // selection change and no toolbar of its own; the menu is asked for here.
  void _handlePointerUp() {
    if (!_secondaryPress) {
      return;
    }
    _secondaryPress = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_menuBuilt) {
        editableTextKey.currentState?.toggleToolbar(false);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  Widget _buildMenu(BuildContext context, EditableTextState state) {
    _menuBuilt = true;
    return systemTextContextMenu(context, state);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _secondaryPress = event.buttons & kSecondaryButton != 0;
        _menuBuilt = false;
      },
      onPointerUp: (_) => _handlePointerUp(),
      child: _gestures.buildGestureDetector(
        behavior: HitTestBehavior.translucent,
        child: EditableText(
          key: editableTextKey,
          controller: widget.controller,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          style: widget.style,
          strutStyle: widget.strutStyle,
          textAlign: widget.textAlign,
          cursorColor: widget.cursorColor,
          backgroundCursorColor: widget.cursorColor,
          selectionColor: widget.selectionColor,
          selectionControls: groupedSelectionControls(context),
          contextMenuBuilder: _buildMenu,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          textInputAction: TextInputAction.done,
          maxLines: 1,
          inputFormatters: widget.inputFormatters,
          onEditingComplete: widget.onEditingComplete,
          onSubmitted: widget.onSubmitted,
        ),
      ),
    );
  }
}

/// The handles a selection shows: a pointer's on a desktop, a finger's
/// elsewhere. The menu itself is [groupedTextContextMenu].
TextSelectionControls groupedSelectionControls(BuildContext context) {
  return switch (Theme.of(context).platform) {
    TargetPlatform.macOS ||
    TargetPlatform.linux ||
    TargetPlatform.windows => desktopTextSelectionHandleControls,
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.fuchsia => materialTextSelectionHandleControls,
  };
}

/// A row whose value is typed in the row itself: a tap turns the value into a
/// caret in place, the row lights up, and Enter or leaving the row keeps it.
/// A value [validator] refuses stays open and says why under the title.
class GroupedInputRow extends StatefulWidget implements GroupedInset {
  const GroupedInputRow({
    super.key,
    required this.title,
    required this.value,
    required this.onSubmitted,
    this.leading,
    this.subtitle,
    this.hint,
    this.suffix,
    this.resetValue,
    this.validator,
    this.inputFormatters,
    this.keyboardType,
    this.startEditing = false,
    this.onCancel,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String value;

  /// Gets the text once it has passed [validator] and differs from [value].
  final ValueChanged<String> onSubmitted;
  final Widget? leading;
  final String? subtitle;

  /// Shown in place of an empty value.
  final String? hint;
  final String? suffix;

  /// What a Reset beside the field puts back, offered while it differs.
  final String? resetValue;
  final String? Function(String value)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  /// Opens already being typed in, for a row that was just made.
  final bool startEditing;

  /// Called when editing ends without a value being taken.
  final VoidCallback? onCancel;

  /// What a tap does in place of starting to type.
  final VoidCallback? onTap;

  /// A control after the value, shown while the row is not being typed in.
  final Widget? trailing;

  @override
  double get separatorInset => leading == null
      ? groupedRowPadding + 1
      : groupedRowPadding + groupedLeadingSize + groupedLeadingGap;

  @override
  State<GroupedInputRow> createState() => _GroupedInputRowState();
}

class _GroupedInputRowState extends State<GroupedInputRow> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _editing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_editing) {
        setState(() {});
      }
    });
    // A tap on another row hands the focus over within a frame, so a lost
    // focus only ends editing if nothing took it back by the end of it.
    _focus.addListener(() {
      if (_focus.hasFocus) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _editing && !_focus.hasFocus) {
          _finish(commitIfValid: true);
        }
      });
    });
    if (widget.startEditing) {
      _begin();
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _begin() {
    _controller.value = TextEditingValue(
      text: widget.value,
      selection: TextSelection.collapsed(offset: widget.value.length),
    );
    _editing = true;
    _error = null;
  }

  /// Ends editing. The text is taken when it is valid and new; on Enter a
  /// refusal keeps the row open instead.
  void _finish({required bool commitIfValid, bool keepOpenOnError = false}) {
    final text = _controller.text.trim();
    final error = widget.validator?.call(text);
    if (commitIfValid && error != null && keepOpenOnError) {
      setState(() => _error = error);
      return;
    }
    final accept = commitIfValid && error == null && text != widget.value;
    final cancelled = !accept;
    setState(() {
      _editing = false;
      _error = null;
    });
    if (accept) {
      widget.onSubmitted(text);
    }
    if (cancelled) {
      widget.onCancel?.call();
    }
  }

  void _reset() {
    final value = widget.resetValue;
    if (value == null) {
      return;
    }
    _controller.text = value;
    _finish(commitIfValid: true, keepOpenOnError: true);
  }

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    if (!_editing) {
      final empty = widget.value.isEmpty;
      return GroupedRow(
        leading: widget.leading,
        title: widget.title,
        subtitle: widget.subtitle,
        value: empty ? widget.hint : widget.value,
        trailing: widget.trailing,
        onTap:
            widget.onTap ??
            () {
              setState(_begin);
              _focus.requestFocus();
            },
      );
    }
    final showReset =
        widget.resetValue != null && _controller.text != widget.resetValue;
    final style = palette.rowValue.copyWith(color: palette.label);
    return ColoredBox(
      color: palette.hover,
      child: GroupedRow(
        leading: widget.leading,
        title: widget.title,
        subtitleWidget: _error == null
            ? (widget.subtitle == null ? null : Text(widget.subtitle!))
            : Text(
                _error!,
                style: palette.rowSubtitle.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 40, maxWidth: 260),
              child: IntrinsicWidth(
                child: CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.escape): () =>
                        _finish(commitIfValid: false),
                  },
                  child: GroupedEditableText(
                    controller: _controller,
                    focusNode: _focus,
                    style: style,
                    textAlign: TextAlign.end,
                    cursorColor: palette.accent,
                    selectionColor: palette.accent.withValues(alpha: 0.3),
                    keyboardType: widget.keyboardType,
                    inputFormatters: widget.inputFormatters,
                    // Keeps Enter from dropping the focus, which would end
                    // the edit before a refused value can be explained.
                    onEditingComplete: () {},
                    onSubmitted: (_) =>
                        _finish(commitIfValid: true, keepOpenOnError: true),
                  ),
                ),
              ),
            ),
            if (widget.suffix != null)
              Text(widget.suffix!, style: palette.rowValue),
            if (showReset)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _reset,
                child: Text(
                  context.appLocalizations.reset,
                  style: palette.rowValue.copyWith(color: palette.accent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
