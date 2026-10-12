import 'package:fl_clash/providers/config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// A light tick for a selection that moves, unless the user turned haptic
/// feedback off. Read from the scope above [context] so a widget needs no `ref`; with
/// no scope the tick is given.
void selectionHaptic(BuildContext context) {
  final scope = context
      .findAncestorWidgetOfExactType<UncontrolledProviderScope>();
  if (scope?.container.read(appSettingProvider).hapticFeedback ?? true) {
    HapticFeedback.selectionClick();
  }
}
