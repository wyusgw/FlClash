import 'dart:ui' show Brightness, Color, Offset;

import 'package:fl_clash/common/provider_reader.dart';
import 'package:fl_clash/models/models.dart';

typedef TextMenuItem = ({String id, String label, bool enabled});

abstract interface class WindowPort {
  Future<WindowProps?> captureNormalGeometry(WindowProps current);

  /// Returns whether a backdrop is now drawn behind the content.
  Future<bool> setBlur({
    required bool enabled,
    required Brightness brightness,
    required Color tint,
  });

  Future<void> show();

  Future<void> hide();

  Future<void> toggle();

  Future<void> close();

  void forceExit();

  /// Pops the system's text menu at [position] in the window and answers with
  /// the index chosen, or null when it was dismissed. An item's id is `cut`,
  /// `copy`, `paste` or `select-all`; [speech] is what its Speech entry reads.
  Future<int?> showTextMenu({
    required Offset position,
    required List<TextMenuItem> items,
    String? speech,
  });
}

abstract interface class TrayPort {
  Future<void> shutdown();

  Future<void> update({
    required TrayState trayState,
    required Traffic traffic,
    required ProviderReader read,
  });
}

abstract interface class NavigationPort {
  List<NavigationItem> getItems();
}

WindowPort? windowPort;
TrayPort? trayPort;
NavigationPort? navigationPort;
