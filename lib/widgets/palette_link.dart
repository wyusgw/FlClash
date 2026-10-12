import 'package:material_ui/material_ui.dart';

import 'grouped_list.dart';

/// The version a color link states and the only one this reads.
const _colorLinkVersion = '1.0';

const _colorLinkHost = 'color';

/// How the adjusted colors are stored: `dark.CanvasColor` and the like.
String paletteKey(Brightness brightness, GroupedColorToken token) =>
    '${brightness.name}.${token.id}';

/// The stored colors of one brightness, keyed by [GroupedColorToken.id].
Map<String, int> paletteOverridesFor(
  Map<String, int> stored,
  Brightness brightness,
) {
  final prefix = '${brightness.name}.';
  return {
    for (final entry in stored.entries)
      if (entry.key.startsWith(prefix))
        entry.key.substring(prefix.length): entry.value,
  };
}

/// `RRGGBB`, or `AARRGGBB` where the color is not opaque.
String colorHex(int argb) {
  final value = argb & 0xFFFFFFFF;
  final digits = value.toRadixString(16).toUpperCase().padLeft(8, '0');
  return value >> 24 == 0xFF ? digits.substring(2) : digits;
}

/// A color from `RRGGBB` or `AARRGGBB`, with or without a leading `#`.
int? parseColorHex(String text) {
  final digits = text.trim().replaceFirst('#', '');
  if (!RegExp(r'^[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$').hasMatch(digits)) {
    return null;
  }
  final value = int.parse(digits, radix: 16);
  return digits.length == 6 ? 0xFF000000 | value : value;
}

/// The colors in force, as an address that hands them to another install.
Uri buildColorLink(
  String scheme, {
  required GroupedPalette dark,
  required GroupedPalette light,
}) {
  final query = <String, String>{'v': _colorLinkVersion};
  for (final (brightness, palette) in [
    (Brightness.dark, dark),
    (Brightness.light, light),
  ]) {
    for (final token in GroupedColorToken.values) {
      query[paletteKey(brightness, token)] = colorHex(
        palette.colorOf(token).toARGB32(),
      );
    }
  }
  return Uri(scheme: scheme, host: _colorLinkHost, queryParameters: query);
}

/// The colors a color link carries, in storage keys, or null when it is no
/// color link of this version or carries none this knows.
Map<String, int>? parseColorLink(Uri uri) {
  if (uri.host != _colorLinkHost) {
    return null;
  }
  final version = uri.queryParameters['v'] ?? '';
  if (version.split('.').first != _colorLinkVersion.split('.').first) {
    return null;
  }
  final colors = <String, int>{};
  for (final brightness in Brightness.values) {
    for (final token in GroupedColorToken.values) {
      final key = paletteKey(brightness, token);
      final raw = uri.queryParameters[key];
      final color = raw == null ? null : parseColorHex(raw);
      if (color != null) {
        colors[key] = color;
      }
    }
  }
  return colors.isEmpty ? null : colors;
}
