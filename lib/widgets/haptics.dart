import 'dart:async';

import 'package:fl_clash/plugins/app.dart';
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

void _platformHaptic({required bool heavy}) {
  unawaited(
    heavy ? HapticFeedback.heavyImpact() : HapticFeedback.selectionClick(),
  );
}

/// Android buzzes its vibrator, since the system's touch feedback switch
/// mutes Flutter's own haptics; where that is not possible, or fails, the
/// platform's haptic stands in.
void _buzz({required bool heavy}) {
  final android = app;
  if (android == null) {
    _platformHaptic(heavy: heavy);
    return;
  }
  unawaited(
    android.vibrate(heavy: heavy).catchError((Object _) => false).then((
      buzzed,
    ) {
      if (!buzzed) _platformHaptic(heavy: heavy);
    }),
  );
}

/// A light tick for a selection that moves.
void selectionHaptic(BuildContext context) {
  if (_hapticsOn(context)) {
    _buzz(heavy: false);
  }
}

/// A firmer knock for turning the proxy on or off.
void toggleHaptic(BuildContext context) {
  if (_hapticsOn(context)) {
    _buzz(heavy: true);
  }
}
