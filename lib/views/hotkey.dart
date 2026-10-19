import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

Glyph _glyphOf(HotAction action) {
  return switch (action) {
    HotAction.view => AppGlyphs.eye,
    HotAction.start => AppGlyphs.playPause(0),
    HotAction.exit => AppGlyphs.close,
    HotAction.mode => AppGlyphs.split,
    HotAction.ruleMode => AppGlyphs.rules,
    HotAction.globalMode => AppGlyphs.language,
    HotAction.directMode => AppGlyphs.target,
    HotAction.proxy => AppGlyphs.shuffle,
    HotAction.tun => AppGlyphs.vpn,
    HotAction.copyEnv => AppGlyphs.code,
    HotAction.delayTest => AppGlyphs.bolt,
    HotAction.updateProfiles => AppGlyphs.sync,
    HotAction.speedView => AppGlyphs.speed,
  };
}

List<(String, List<HotAction>)> _sections(AppLocalizations appLocalizations) {
  return [
    (
      appLocalizations.general,
      const [
        HotAction.view,
        HotAction.start,
        HotAction.speedView,
        HotAction.exit,
      ],
    ),
    (
      appLocalizations.outboundMode,
      const [
        HotAction.mode,
        HotAction.ruleMode,
        HotAction.globalMode,
        HotAction.directMode,
      ],
    ),
    (
      appLocalizations.network,
      const [HotAction.proxy, HotAction.tun, HotAction.copyEnv],
    ),
    (
      appLocalizations.proxies,
      const [HotAction.delayTest, HotAction.updateProfiles],
    ),
  ];
}

bool _sameCombination(HotKeyAction a, HotKeyAction b) {
  return a.key != null &&
      a.key == b.key &&
      keyboardModifierListEquality.equals(a.modifiers, b.modifiers);
}

HotKeyAction? _conflictOf(List<HotKeyAction> actions, HotKeyAction binding) {
  for (final item in actions) {
    if (item.action != binding.action && _sameCombination(item, binding)) {
      return item;
    }
  }
  return null;
}

/// Stores [binding] for its action, or clears the action when it has no key.
/// Another action holding the same combination loses it.
List<HotKeyAction> _withBinding(
  List<HotKeyAction> actions,
  HotKeyAction binding,
) {
  final isBound = binding.key != null;
  var isPlaced = false;
  final result = <HotKeyAction>[];
  for (final item in actions) {
    if (item.action == binding.action) {
      isPlaced = true;
      if (isBound) {
        result.add(binding);
      }
    } else if (!(isBound && _sameCombination(item, binding))) {
      result.add(item);
    }
  }
  if (isBound && !isPlaced) {
    result.add(binding);
  }
  return result;
}

void _saveBinding(WidgetRef ref, HotKeyAction binding) {
  final notifier = ref.read(hotKeyActionsProvider.notifier);
  notifier.value = _withBinding(notifier.value, binding);
}

class HotKeyView extends ConsumerStatefulWidget {
  const HotKeyView({super.key});

  @override
  ConsumerState<HotKeyView> createState() => _HotKeyViewState();
}

class _HotKeyViewState extends ConsumerState<HotKeyView> {
  late final HotKeyRecording _recording;
  HotAction? _recordingAction;
  Set<KeyboardModifier> _modifiers = const {};
  bool _needsModifier = false;

  @override
  void initState() {
    super.initState();
    _recording = ref.read(hotKeyRecordingProvider.notifier);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    if (_recordingAction != null) {
      final recording = _recording;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        recording.value = false;
      });
    }
    super.dispose();
  }

  void _start(HotAction action) {
    setState(() {
      _recordingAction = action;
      _modifiers = const {};
      _needsModifier = false;
    });
    _recording.value = true;
  }

  void _stop() {
    setState(() {
      _recordingAction = null;
      _modifiers = const {};
      _needsModifier = false;
    });
    _recording.value = false;
  }

  void _commit(HotKeyAction binding) {
    final displaced = _conflictOf(ref.read(hotKeyActionsProvider), binding);
    _saveBinding(ref, binding);
    _stop();
    if (displaced != null) {
      dialogs.showNotifier(
        context.appLocalizations.hotkeyMovedFrom(displaced.action.label),
      );
    }
  }

  Future<void> _reset() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.confirm,
      message: TextSpan(text: appLocalizations.resetTip),
      confirmText: appLocalizations.reset,
      destructive: true,
    );
    if (res != true || !mounted) return;
    if (_recordingAction != null) _stop();
    ref.read(hotKeyActionsProvider.notifier).value = defaultHotKeyActions;
    dialogs.showNotifier(
      appLocalizations.resetSuccess,
      level: MessageLevel.success,
    );
  }

  Set<KeyboardModifier> _heldModifiers({PhysicalKeyboardKey? except}) {
    final pressed = HardwareKeyboard.instance.physicalKeysPressed;
    return {
      for (final modifier in KeyboardModifier.values)
        if (modifier.physicalKeys.any(pressed.contains) &&
            !modifier.physicalKeys.contains(except))
          modifier,
    };
  }

  bool _handleKeyEvent(KeyEvent event) {
    final action = _recordingAction;
    if (action == null) {
      return false;
    }
    final physicalKey = event.physicalKey;
    if (isModifierKey(physicalKey)) {
      setState(() {
        _modifiers = _heldModifiers();
        _needsModifier = false;
      });
      return true;
    }
    if (event is KeyUpEvent) {
      return true;
    }
    final modifiers = _heldModifiers(except: physicalKey);
    if (physicalKey == PhysicalKeyboardKey.escape && modifiers.isEmpty) {
      _stop();
      return true;
    }
    final key = physicalKey.usbHidUsage;
    if (!isValidHotKey(modifiers, key)) {
      setState(() {
        _modifiers = modifiers;
        _needsModifier = true;
      });
      return true;
    }
    _commit(HotKeyAction(action: action, key: key, modifiers: modifiers));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final labels = ShortcutLabels.host();
    return GroupedPage(
      title: appLocalizations.hotkeyManagement,
      onBack: () => Navigator.of(context).maybePop(),
      body: GroupedBody(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              groupedRowPadding + 1,
              0,
              groupedRowPadding,
              10,
            ),
            child: Text(
              appLocalizations.hotkeyDesc,
              style: palette.sectionLabel,
            ),
          ),
          for (final (title, actions) in _sections(appLocalizations))
            Padding(
              padding: const EdgeInsets.only(bottom: groupedSectionGap),
              child: GroupedSection(
                header: title,
                children: [
                  for (final action in actions)
                    _HotKeyItem(
                      action: action,
                      labels: labels,
                      recording: _recordingAction == action
                          ? (
                              modifiers: _modifiers,
                              needsModifier: _needsModifier,
                            )
                          : null,
                      onTap: () =>
                          _recordingAction == action ? _stop() : _start(action),
                      onClear: () =>
                          _saveBinding(ref, HotKeyAction(action: action)),
                    ),
                ],
              ),
            ),
          GroupedSection(
            children: [
              GroupedButtonRow(
                label: appLocalizations.resetHotkeys,
                color: groupedDanger,
                onTap: () => unawaited(_reset()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

typedef _RecordingPreview = ({
  Set<KeyboardModifier> modifiers,
  bool needsModifier,
});

class _HotKeyItem extends ConsumerWidget implements GroupedInset {
  const _HotKeyItem({
    required this.action,
    required this.labels,
    required this.recording,
    required this.onTap,
    required this.onClear,
  });

  final HotAction action;
  final ShortcutLabels labels;
  final _RecordingPreview? recording;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  double get separatorInset =>
      groupedRowPadding + groupedLeadingSize + groupedLeadingGap;

  Widget _recordingTrailing(BuildContext context, _RecordingPreview preview) {
    final palette = GroupedPalette.of(context);
    if (preview.modifiers.isEmpty) {
      return Text(
        context.appLocalizations.pressKeyboard,
        style: palette.rowValue.copyWith(color: palette.accent),
      );
    }
    return _KeyCaps(
      parts: labels.modifierParts(preview.modifiers),
      trailingPlaceholder: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final hotKeyAction = ref.watch(getHotKeyActionProvider(action));
    final failure = ref.watch(
      hotKeyFailuresProvider.select((state) => state[action]),
    );
    final key = hotKeyAction.key;
    final preview = recording;
    final Widget? subtitle;
    if (preview != null && preview.needsModifier) {
      subtitle = Text(
        appLocalizations.hotkeyNeedsModifier(
          labels
              .modifierParts(primaryHotKeyModifiers)
              .join(labels.isMacOS ? ' ' : ', '),
        ),
        style: palette.rowSubtitle.copyWith(color: context.colorScheme.error),
      );
    } else if (failure != null) {
      subtitle = Tooltip(
        message: failure,
        child: Text(
          appLocalizations.hotkeyUnavailable,
          style: palette.rowSubtitle.copyWith(color: context.colorScheme.error),
        ),
      );
    } else {
      subtitle = null;
    }
    return GroupedRow(
      leading: GroupedIcon(_glyphOf(action)),
      title: action.label,
      subtitleWidget: subtitle,
      trailing: preview != null
          ? _recordingTrailing(context, preview)
          : key == null
          ? Text(appLocalizations.hotkeyNotSet, style: palette.rowValue)
          : Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                _KeyCaps(
                  parts: labels.parts(hotKeyAction.modifiers, key),
                  isError: failure != null,
                ),
                Tooltip(
                  message: appLocalizations.remove,
                  child: InkResponse(
                    radius: 14,
                    onTap: onClear,
                    child: GlyphIcon(
                      AppGlyphs.close,
                      size: 16,
                      color: palette.secondary,
                    ),
                  ),
                ),
              ],
            ),
      onTap: onTap,
    );
  }
}

class _KeyCaps extends StatelessWidget {
  const _KeyCaps({
    required this.parts,
    this.isError = false,
    this.trailingPlaceholder = false,
  });

  final List<String> parts;
  final bool isError;
  final bool trailingPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: [
        for (final part in parts) _KeyCap(label: part, isError: isError),
        if (trailingPlaceholder) const _KeyCap(label: '…', isPlaceholder: true),
      ],
    );
  }
}

class _KeyCap extends StatelessWidget {
  const _KeyCap({
    required this.label,
    this.isError = false,
    this.isPlaceholder = false,
  });

  final String label;
  final bool isError;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final palette = GroupedPalette.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: ShapeDecoration(
        color: isPlaceholder ? Colors.transparent : palette.hover,
        shape: AppShape.sm.copyWith(
          side: isError
              ? BorderSide(color: colorScheme.error)
              : BorderSide.none,
        ),
      ),
      child: Align(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isError ? colorScheme.error : palette.label,
          ),
        ),
      ),
    );
  }
}
