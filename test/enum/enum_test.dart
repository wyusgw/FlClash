import 'dart:io';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupportPlatform', () {
    test('names the platform the tests run on', () {
      final expected = switch (Platform.operatingSystem) {
        'windows' => SupportPlatform.Windows,
        'macos' => SupportPlatform.MacOS,
        'linux' => SupportPlatform.Linux,
        'android' => SupportPlatform.Android,
        _ => null,
      };
      if (expected == null) {
        expect(() => SupportPlatform.currentPlatform, throwsUnsupportedError);
      } else {
        expect(SupportPlatform.currentPlatform, expected);
      }
    });
  });

  group('GroupType', () {
    test('parses clash group type aliases case-insensitively', () {
      expect(GroupType.parse('url-test'), GroupType.URLTest);
      expect(GroupType.parse('URLTEST'), GroupType.URLTest);
      expect(GroupType.parse('selector'), GroupType.Selector);
      expect(GroupType.parse('loadbalance'), GroupType.LoadBalance);
    });

    test('throws for unsupported group type', () {
      expect(() => GroupType.parse('unknown'), throwsUnimplementedError);
    });

    test('parses a relay group but does not offer it', () {
      expect(GroupType.parse('relay'), GroupType.Relay);
      expect(GroupType.selectableValues, isNot(contains(GroupType.Relay)));
      expect(GroupType.selectableValues, contains(GroupType.Selector));
    });
  });

  group('MessageLevelExt', () {
    test('draws each level with its own glyph', () {
      expect(MessageLevel.info.glyph, AppGlyphs.info);
      expect(MessageLevel.success.glyph, AppGlyphs.check);
      expect(MessageLevel.warning.glyph, AppGlyphs.warning);
      expect(MessageLevel.error.glyph, AppGlyphs.close);
    });

    test('keeps a more serious level on screen longer', () {
      expect(MessageLevel.info.duration, const Duration(seconds: 3));
      expect(MessageLevel.success.duration, const Duration(seconds: 3));
      expect(MessageLevel.warning.duration, const Duration(seconds: 5));
      expect(MessageLevel.error.duration, const Duration(seconds: 6));
    });
  });

  group('GroupTypeExtension', () {
    test('maps display names back to enum values', () {
      expect(GroupTypeExtension.getGroupType('Selector'), GroupType.Selector);
      expect(GroupTypeExtension.getGroupType('URLTest'), GroupType.URLTest);
      expect(GroupTypeExtension.getGroupType('missing'), isNull);
    });

    test('marks only computed selection types', () {
      expect(GroupType.URLTest.isComputedSelected, isTrue);
      expect(GroupType.Fallback.isComputedSelected, isTrue);
      expect(GroupType.Selector.isComputedSelected, isFalse);
    });
  });

  group('KeyboardModifier', () {
    test('keeps platform key variants for paired modifiers', () {
      expect(KeyboardModifier.alt.physicalKeys, [
        PhysicalKeyboardKey.altLeft,
        PhysicalKeyboardKey.altRight,
      ]);
      expect(KeyboardModifier.meta.physicalKeys, [
        PhysicalKeyboardKey.metaLeft,
        PhysicalKeyboardKey.metaRight,
      ]);
    });
  });

  group('ItemPosition', () {
    test('calculates simple list positions', () {
      expect(ItemPosition.get(0, 1), ItemPosition.startAndEnd);
      expect(ItemPosition.get(0, 3), ItemPosition.start);
      expect(ItemPosition.get(1, 3), ItemPosition.middle);
      expect(ItemPosition.get(2, 3), ItemPosition.end);
    });

    test('calculates visual positions after deleted items are skipped', () {
      final items = ['a', 'b', 'c', 'd'];
      final deletedItems = {'a', 'c'};

      expect(
        ItemPosition.calculateVisualPosition(1, items, deletedItems),
        ItemPosition.start,
      );
      expect(
        ItemPosition.calculateVisualPosition(3, items, deletedItems),
        ItemPosition.end,
      );
    });

    test('deleted current item has no visual position', () {
      expect(
        ItemPosition.calculateVisualPosition(1, ['a', 'b'], {'b'}),
        ItemPosition.middle,
      );
    });
  });
}
