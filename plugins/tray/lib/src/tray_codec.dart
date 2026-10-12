import 'dart:convert';

import 'tray_menu.dart';
import 'tray_spec.dart';

final class EncodedTray {
  const EncodedTray({
    required this.icon,
    required this.toolTip,
    required this.menu,
    required this.itemsById,
    required this.signature,
  });

  final Map<String, Object?> icon;
  final String toolTip;
  final List<Object?> menu;
  final Map<int, TrayMenuItem> itemsById;
  final String signature;
}

abstract final class TrayCodec {
  static const int firstItemId = 1024;

  static EncodedTray encode(TraySpec spec) {
    final itemsById = <int, TrayMenuItem>{};
    final menu = _encodeItems(spec.menu, itemsById, _IdAllocator());
    final icon = <String, Object?>{
      'asset': spec.icon.asset,
      'isTemplate': spec.icon.isTemplate,
      'size': spec.icon.size,
      'position': spec.icon.position.name,
    };
    return EncodedTray(
      icon: icon,
      toolTip: spec.toolTip,
      menu: menu,
      itemsById: itemsById,
      signature: jsonEncode(<String, Object?>{
        'icon': icon,
        'toolTip': spec.toolTip,
        'menu': menu,
      }),
    );
  }

  static List<Object?> _encodeItems(
    List<TrayMenuItem> items,
    Map<int, TrayMenuItem> sink,
    _IdAllocator allocator,
  ) {
    return items.map((item) {
      final id = allocator.next();
      sink[id] = item;
      return switch (item) {
        TrayMenuSeparator() => <String, Object?>{'id': id, 'type': 'separator'},
        TrayMenuAction(
          :final label,
          :final detail,
          :final busy,
          :final shortcut,
          :final enabled,
        ) =>
          <String, Object?>{
            'id': id,
            'type': 'action',
            'label': label,
            if (detail != null && detail.isNotEmpty) 'detail': detail,
            if (busy) 'busy': true,
            if (shortcut != null) 'shortcut': _encodeShortcut(shortcut),
            'enabled': enabled,
          },
        TrayMenuCheckbox(
          :final label,
          :final detail,
          :final detailTone,
          :final busy,
          :final shortcut,
          :final enabled,
          :final checked,
        ) =>
          <String, Object?>{
            'id': id,
            'type': 'checkbox',
            'label': label,
            if (detail != null && detail.isNotEmpty) 'detail': detail,
            if (detail != null && detail.isNotEmpty && detailTone != null)
              'detailTone': detailTone.name,
            if (busy) 'busy': true,
            if (shortcut != null) 'shortcut': _encodeShortcut(shortcut),
            'enabled': enabled,
            'checked': checked,
          },
        TrayMenuSubmenu(
          :final label,
          :final detail,
          :final detailTone,
          :final busy,
          :final enabled,
          :final items,
        ) =>
          <String, Object?>{
            'id': id,
            'type': 'submenu',
            'label': label,
            if (detail != null && detail.isNotEmpty) 'detail': detail,
            if (detail != null && detail.isNotEmpty && detailTone != null)
              'detailTone': detailTone.name,
            if (busy) 'busy': true,
            'enabled': enabled,
            'items': _encodeItems(items, sink, allocator),
          },
      };
    }).toList();
  }
}

Map<String, Object?> _encodeShortcut(TrayShortcut shortcut) {
  return {
    'key': shortcut.key,
    'modifiers': [
      for (final modifier in TrayShortcutModifier.values)
        if (shortcut.modifiers.contains(modifier)) modifier.name,
    ],
  };
}

final class _IdAllocator {
  int _next = TrayCodec.firstItemId;

  int next() {
    final id = _next;
    _next = _next + 1;
    return id;
  }
}
