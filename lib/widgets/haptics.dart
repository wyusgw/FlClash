import 'package:fl_clash/providers/config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Whether the user leaves haptic feedback on. Read from the scope above
/// [context] so a widget needs no `ref`; with no scope it is on.
bool _hapticsOn(BuildContext context) {
  final scope = context
      .findAncestorWidgetOfExactType<UncontrolledProviderScope>();
  return scope?.container.read(appSettingProvider).hapticFeedback ?? true;
}

/// A light tick for a selection that moves.
void selectionHaptic(BuildContext context) {
  if (_hapticsOn(context)) {
    HapticFeedback.selectionClick();
  }
}

/// A firmer knock for turning the proxy on or off.
void toggleHaptic(BuildContext context) {
  if (_hapticsOn(context)) {
    HapticFeedback.mediumImpact();
  }
}
