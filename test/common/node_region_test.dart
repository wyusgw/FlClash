import 'package:fl_clash/common/node_region.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nodeRegionCode', () {
    test('reads a flag emoji in the name', () {
      expect(nodeRegionCode('\u{1F1EF}\u{1F1F5} Tokyo 01'), 'JP');
      expect(nodeRegionCode('node \u{1F1FA}\u{1F1F8}'), 'US');
    });

    test('reads a country named in Chinese or English', () {
      expect(nodeRegionCode('日本 test1'), 'JP');
      expect(nodeRegionCode('香港 IEPL 02'), 'HK');
      expect(nodeRegionCode('Singapore-03'), 'SG');
      expect(nodeRegionCode('Hong Kong 1'), 'HK');
    });

    test('reads a bare country code but not letters inside a word', () {
      expect(nodeRegionCode('HK-01'), 'HK');
      expect(nodeRegionCode('UK 5'), 'GB');
      expect(nodeRegionCode('Premium'), isNull);
      expect(nodeRegionCode('HKG'), isNull);
    });

    test('names no country for a plain label', () {
      expect(nodeRegionCode('剩余流量：8.08 GB'), isNull);
      expect(nodeRegionCode('剩余流量：8.08+GB'), isNull);
      expect(nodeRegionCode(''), isNull);
    });
  });

  group('nodeDisplayName', () {
    test('drops the flag emoji and the space after it', () {
      expect(nodeDisplayName('\u{1F1EF}\u{1F1F5} Tokyo 01'), 'Tokyo 01');
      expect(nodeDisplayName('HK \u{1F1ED}\u{1F1F0} 02'), 'HK 02');
    });

    test('leaves other names and other emoji alone', () {
      expect(nodeDisplayName('Tokyo 01'), 'Tokyo 01');
      expect(nodeDisplayName('\u{1F680} Fast'), '\u{1F680} Fast');
    });

    test('keeps a name that is nothing but a flag', () {
      expect(nodeDisplayName('\u{1F1EF}\u{1F1F5}'), '\u{1F1EF}\u{1F1F5}');
    });
  });
}
