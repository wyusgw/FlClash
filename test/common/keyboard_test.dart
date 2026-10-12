import 'package:fl_clash/common/keyboard.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _mac = ShortcutLabels(isMacOS: true, isWindows: false);
const _windows = ShortcutLabels(isMacOS: false, isWindows: true);
const _linux = ShortcutLabels(isMacOS: false, isWindows: false);

const _everyModifier = {
  KeyboardModifier.meta,
  KeyboardModifier.shift,
  KeyboardModifier.alt,
  KeyboardModifier.control,
};

void main() {
  group('ShortcutLabels', () {
    final keyS = PhysicalKeyboardKey.keyS.usbHidUsage;

    test('macOS writes symbols in menu order without separators', () {
      expect(_mac.text(_everyModifier, keyS), '⌃⌥⇧⌘S');
      expect(_mac.parts(_everyModifier, keyS), ['⌃', '⌥', '⇧', '⌘', 'S']);
    });

    test('Windows and Linux spell modifiers out and join them with +', () {
      expect(_windows.text(_everyModifier, keyS), 'Ctrl+Alt+Shift+Win+S');
      expect(_linux.text(_everyModifier, keyS), 'Ctrl+Alt+Shift+Super+S');
    });

    test('names keys by their position rather than their debug name', () {
      final cases = {
        PhysicalKeyboardKey.keyA: 'A',
        PhysicalKeyboardKey.keyZ: 'Z',
        PhysicalKeyboardKey.digit1: '1',
        PhysicalKeyboardKey.digit9: '9',
        PhysicalKeyboardKey.digit0: '0',
        PhysicalKeyboardKey.f1: 'F1',
        PhysicalKeyboardKey.f12: 'F12',
        PhysicalKeyboardKey.f13: 'F13',
        PhysicalKeyboardKey.f24: 'F24',
        PhysicalKeyboardKey.numpad1: 'Num 1',
        PhysicalKeyboardKey.numpad0: 'Num 0',
        PhysicalKeyboardKey.arrowUp: '↑',
        PhysicalKeyboardKey.quote: "'",
        PhysicalKeyboardKey.space: 'Space',
      };
      for (final MapEntry(:key, :value) in cases.entries) {
        expect(_windows.key(key.usbHidUsage), value, reason: key.debugName);
      }
    });

    test('macOS uses the menu glyphs for editing keys', () {
      expect(_mac.key(PhysicalKeyboardKey.enter.usbHidUsage), '↩');
      expect(_mac.key(PhysicalKeyboardKey.escape.usbHidUsage), '⎋');
      expect(_mac.key(PhysicalKeyboardKey.backspace.usbHidUsage), '⌫');
      expect(_windows.key(PhysicalKeyboardKey.enter.usbHidUsage), 'Enter');
      expect(_windows.key(PhysicalKeyboardKey.escape.usbHidUsage), 'Esc');
    });
  });

  group('isValidHotKey', () {
    final keyS = PhysicalKeyboardKey.keyS.usbHidUsage;

    test('needs a key and at least one primary modifier', () {
      expect(isValidHotKey({KeyboardModifier.control}, keyS), isTrue);
      expect(isValidHotKey({KeyboardModifier.meta}, keyS), isTrue);
      expect(isValidHotKey({KeyboardModifier.control}, null), isFalse);
      expect(isValidHotKey(const {}, keyS), isFalse);
    });

    test('lock-style modifiers alone are not enough', () {
      expect(isValidHotKey({KeyboardModifier.capsLock}, keyS), isFalse);
      expect(isValidHotKey({KeyboardModifier.fn}, keyS), isFalse);
    });
  });

  test('isModifierKey recognizes both sides of every modifier', () {
    expect(isModifierKey(PhysicalKeyboardKey.controlRight), isTrue);
    expect(isModifierKey(PhysicalKeyboardKey.metaLeft), isTrue);
    expect(isModifierKey(PhysicalKeyboardKey.keyA), isFalse);
  });

  test('menuKeyEquivalent names the keys AppKit can match', () {
    expect(menuKeyEquivalent(PhysicalKeyboardKey.keyP.usbHidUsage), 'p');
    expect(menuKeyEquivalent(PhysicalKeyboardKey.digit0.usbHidUsage), '0');
    expect(menuKeyEquivalent(PhysicalKeyboardKey.digit7.usbHidUsage), '7');
    expect(menuKeyEquivalent(PhysicalKeyboardKey.comma.usbHidUsage), ',');
    expect(menuKeyEquivalent(PhysicalKeyboardKey.enter.usbHidUsage), '\r');
    expect(
      menuKeyEquivalent(PhysicalKeyboardKey.arrowUp.usbHidUsage),
      '\uF700',
    );
    expect(menuKeyEquivalent(PhysicalKeyboardKey.f1.usbHidUsage), '\uF704');
    expect(menuKeyEquivalent(PhysicalKeyboardKey.f12.usbHidUsage), '\uF70F');
    expect(menuKeyEquivalent(PhysicalKeyboardKey.numpad1.usbHidUsage), isNull);
    expect(menuKeyEquivalent(PhysicalKeyboardKey.f13.usbHidUsage), isNull);
  });
}
