import 'dart:async';

import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/common/print.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// The menu over selected or empty text: on a desktop the system's own, popped
/// natively where the pointer is; on a phone the system's where it has one;
/// elsewhere the toolbar of the platform. Every field of the app takes this as
/// its `contextMenuBuilder`.
Widget systemTextContextMenu(
  BuildContext context,
  EditableTextState editableTextState,
) {
  final desktop = switch (Theme.of(context).platform) {
    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.linux => true,
    _ => false,
  };
  if (desktop && windowPort != null) {
    return _NativeTextMenu(editableTextState: editableTextState);
  }
  if (SystemContextMenu.isSupportedByField(editableTextState)) {
    return SystemContextMenu.editableText(editableTextState: editableTextState);
  }
  return AdaptiveTextSelectionToolbar.editableText(
    editableTextState: editableTextState,
  );
}

/// Asks the window for the system menu once, then takes itself away; what is
/// chosen runs as the toolbar's own button would.
class _NativeTextMenu extends StatefulWidget {
  const _NativeTextMenu({required this.editableTextState});

  final EditableTextState editableTextState;

  @override
  State<_NativeTextMenu> createState() => _NativeTextMenuState();
}

class _NativeTextMenuState extends State<_NativeTextMenu> {
  /// Set when the window could not pop its menu, so the toolbar stands in.
  bool _drawn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_pop()));
  }

  /// What the field can do now, each with whether it can at the moment, and
  /// what doing it runs. Paste is asked of the clipboard here: the field's own
  /// answer waits on a check that finishes a moment after the toolbar opens,
  /// which a menu popped at once would miss.
  Future<List<_Entry>> _entries(EditableTextState state) async {
    final value = state.textEditingValue;
    final selected = !value.selection.isCollapsed;
    final widget = state.widget;
    final canPaste = !widget.readOnly && await Clipboard.hasStrings();
    final canSelectAll =
        widget.enableInteractiveSelection &&
        value.text.isNotEmpty &&
        !(value.selection.start == 0 &&
            value.selection.end == value.text.length);
    return [
      _Entry(
        'cut',
        ContextMenuButtonType.cut,
        selected && state.cutEnabled,
        () => state.cutSelection(SelectionChangedCause.toolbar),
      ),
      _Entry(
        'copy',
        ContextMenuButtonType.copy,
        selected && state.copyEnabled,
        () => state.copySelection(SelectionChangedCause.toolbar),
      ),
      _Entry(
        'paste',
        ContextMenuButtonType.paste,
        canPaste,
        () => state.pasteText(SelectionChangedCause.toolbar),
      ),
      _Entry(
        'select-all',
        ContextMenuButtonType.selectAll,
        canSelectAll,
        () => state.selectAll(SelectionChangedCause.toolbar),
      ),
    ];
  }

  Future<void> _pop() async {
    if (!mounted) {
      return;
    }
    final state = widget.editableTextState;
    final entries = await _entries(state);
    if (!mounted) {
      return;
    }
    if (!entries.any((entry) => entry.enabled)) {
      state.hideToolbar();
      return;
    }
    final items = [
      for (final entry in entries)
        (
          id: entry.id,
          label: AdaptiveTextSelectionToolbar.getButtonLabel(
            context,
            ContextMenuButtonItem(type: entry.type, onPressed: entry.run),
          ),
          enabled: entry.enabled,
        ),
    ];
    final value = state.textEditingValue;
    final speech = value.selection.isCollapsed
        ? value.text
        : value.selection.textInside(value.text);
    final anchor = state.contextMenuAnchors.primaryAnchor;
    int? chosen;
    try {
      chosen = await windowPort?.showTextMenu(
        position: anchor,
        items: items,
        speech: speech,
      );
    } on PlatformException catch (error) {
      commonPrint.log('text menu failed: ${error.message}');
      setState(() => _drawn = true);
      return;
    } on MissingPluginException {
      commonPrint.log('text menu is missing from this build of the window');
      setState(() => _drawn = true);
      return;
    }
    state.hideToolbar();
    if (chosen != null && chosen >= 0 && chosen < entries.length) {
      final entry = entries[chosen];
      if (entry.enabled) {
        entry.run();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_drawn) {
      return AdaptiveTextSelectionToolbar.editableText(
        editableTextState: widget.editableTextState,
      );
    }
    return const SizedBox.shrink();
  }
}

class _Entry {
  const _Entry(this.id, this.type, this.enabled, this.run);

  final String id;
  final ContextMenuButtonType type;
  final bool enabled;
  final VoidCallback run;
}
