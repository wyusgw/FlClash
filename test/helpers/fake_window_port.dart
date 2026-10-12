import 'dart:ui' show Brightness, Color, Offset;

import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/models/models.dart';

typedef TextMenuRequest = ({
  Offset position,
  List<TextMenuItem> items,
  String? speech,
});

/// A window that does nothing but answer for the text menu: [choose] picks an
/// entry from the items, and every request is kept in [requests].
class FakeWindowPort implements WindowPort {
  FakeWindowPort({this.choose, this.error});

  /// A window whose user picks the entry with [id], when it is there.
  FakeWindowPort.choosing(String id, {this.error})
    : choose = ((items) {
        final index = items.indexWhere((item) => item.id == id);
        return index == -1 ? null : index;
      });

  final int? Function(List<TextMenuItem> items)? choose;

  /// Thrown by every request, as a window that cannot pop its menu would.
  final Exception? error;
  final requests = <TextMenuRequest>[];

  @override
  Future<int?> showTextMenu({
    required Offset position,
    required List<TextMenuItem> items,
    String? speech,
  }) async {
    requests.add((position: position, items: items, speech: speech));
    final failure = error;
    if (failure != null) {
      throw failure;
    }
    return choose?.call(items);
  }

  @override
  Future<WindowProps?> captureNormalGeometry(WindowProps current) async =>
      current;

  @override
  Future<bool> setBlur({
    required bool enabled,
    required Brightness brightness,
    required Color tint,
  }) async => false;

  @override
  Future<void> show() async {}

  @override
  Future<void> hide() async {}

  @override
  Future<void> toggle() async {}

  @override
  Future<void> close() async {}

  @override
  void forceExit() {}
}
