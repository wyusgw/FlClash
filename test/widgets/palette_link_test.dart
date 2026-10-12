import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:fl_clash/widgets/palette_link.dart';
import 'dart:ui' show Brightness;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('colorHex', () {
    test('an opaque color is six digits', () {
      expect(colorHex(0xFF1F1F1F), '1F1F1F');
      expect(colorHex(0xFF000000), '000000');
    });

    test('a translucent color keeps its alpha first', () {
      expect(colorHex(0x00000000), '00000000');
      expect(colorHex(0x80FFFFFF), '80FFFFFF');
    });
  });

  group('parseColorHex', () {
    test('reads six digits as opaque and eight as given', () {
      expect(parseColorHex('2473BD'), 0xFF2473BD);
      expect(parseColorHex('#2473bd'), 0xFF2473BD);
      expect(parseColorHex(' 80FFFFFF '), 0x80FFFFFF);
    });

    test('refuses anything else', () {
      for (final text in [
        '',
        '#',
        'GGGGGG',
        '12345',
        '1234567',
        '#12345678 9',
      ]) {
        expect(parseColorHex(text), isNull, reason: text);
      }
    });

    test('is the inverse of colorHex', () {
      for (final color in [0xFF123456, 0x00ABCDEF, 0x7F000001, 0xFFFFFFFF]) {
        expect(parseColorHex(colorHex(color)), color);
      }
    });
  });

  group('stored colors', () {
    test('keys name the brightness and the token', () {
      expect(
        paletteKey(Brightness.dark, GroupedColorToken.canvas),
        'dark.CanvasColor',
      );
      expect(
        paletteKey(Brightness.light, GroupedColorToken.bar),
        'light.NavigationBarColor',
      );
    });

    test('one brightness is picked out by token id', () {
      final stored = {
        'dark.CanvasColor': 0xFF111111,
        'light.CanvasColor': 0xFFEEEEEE,
        'dark.AccentColor': 0xFF0A84FF,
      };

      expect(paletteOverridesFor(stored, Brightness.dark), {
        'CanvasColor': 0xFF111111,
        'AccentColor': 0xFF0A84FF,
      });
      expect(paletteOverridesFor(stored, Brightness.light), {
        'CanvasColor': 0xFFEEEEEE,
      });
    });

    test('overrides replace only the colors they name', () {
      final palette = GroupedPalette.dark.withOverrides({
        GroupedColorToken.canvas.id: 0xFF123456,
      });

      expect(palette.canvas, const Color(0xFF123456));
      expect(palette.bar, GroupedPalette.dark.bar);
      expect(palette == GroupedPalette.dark, isFalse);
      expect(GroupedPalette.dark.withOverrides(const {}), GroupedPalette.dark);
    });
  });

  group('color links', () {
    test('a link carries every color of both looks', () {
      final uri = buildColorLink(
        'flclash',
        dark: GroupedPalette.dark,
        light: GroupedPalette.light,
      );

      expect(uri.scheme, 'flclash');
      expect(uri.host, 'color');
      expect(uri.queryParameters['v'], '1.0');
      expect(uri.queryParameters['dark.CanvasColor'], '000000');
      expect(uri.queryParameters['light.CanvasColor'], 'F2F2F7');
      expect(
        uri.queryParameters.length,
        1 + 2 * GroupedColorToken.values.length,
      );
    });

    test('parsing a built link gives the colors back', () {
      final dark = GroupedPalette.dark.withOverrides({
        GroupedColorToken.accent.id: 0xFF336699,
      });
      final uri = buildColorLink(
        'flclash',
        dark: dark,
        light: GroupedPalette.light,
      );

      final colors = parseColorLink(uri)!;

      expect(colors['dark.AccentColor'], 0xFF336699);
      expect(colors['light.CanvasColor'], 0xFFF2F2F7);
      expect(colors, hasLength(2 * GroupedColorToken.values.length));
    });

    test('a link of another host or major version is not read', () {
      expect(
        parseColorLink(Uri.parse('flclash://install-config?v=1.0')),
        isNull,
      );
      expect(
        parseColorLink(
          Uri.parse('flclash://color?v=2.0&dark.CanvasColor=000000'),
        ),
        isNull,
      );
      expect(
        parseColorLink(Uri.parse('flclash://color?dark.CanvasColor=000000')),
        isNull,
      );
    });

    test('a later minor version is still read', () {
      final colors = parseColorLink(
        Uri.parse('flclash://color?v=1.3&dark.CanvasColor=000000'),
      );

      expect(colors, {'dark.CanvasColor': 0xFF000000});
    });

    test('colors that are unknown or unreadable are dropped', () {
      final colors = parseColorLink(
        Uri.parse(
          'flclash://color?v=1.0&dark.CanvasColor=nope'
          '&dark.AccentColor=0A84FF&dark.Unknown=FFFFFF&sepia.CanvasColor=000000',
        ),
      );

      expect(colors, {'dark.AccentColor': 0xFF0A84FF});
      expect(
        parseColorLink(
          Uri.parse('flclash://color?v=1.0&dark.CanvasColor=nope'),
        ),
        isNull,
      );
    });
  });
}
