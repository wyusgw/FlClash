import 'package:fl_clash/common/input_entries.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseListInput', () {
    test('splits on newlines and both comma widths', () {
      final parsed = parseListInput('a, b，c\r\nd\n\n e ');

      expect(parsed.entries, ['a', 'b', 'c', 'd', 'e']);
      expect(parsed.isValid, isTrue);
      expect(parsed.skippedExisting, 0);
    });

    test('keeps spaces inside an item', () {
      final parsed = parseListInput('https://dns.google/dns-query#Proxy A');

      expect(parsed.entries, ['https://dns.google/dns-query#Proxy A']);
    });

    test('strips YAML sequence markers and quotes', () {
      final parsed = parseListInput("- 'geosite:cn'\n- \"+.lan\",\n- plain");

      expect(parsed.entries, ['geosite:cn', '+.lan', 'plain']);
    });

    test('strips list markers and quotes and splits on commas', () {
      final parsed = parseListInput("- 'a.com'\n- \"b.com\",\nc.com, d.com");

      expect(parsed.entries, ['a.com', 'b.com', 'c.com', 'd.com']);
    });

    test('merges duplicates and skips existing values', () {
      final parsed = parseListInput('a, b, a, c', existing: {'b', 'c'});

      expect(parsed.entries, ['a']);
      expect(parsed.skippedExisting, 2);
    });

    test('reports over-long items with their line', () {
      final parsed = parseListInput('ok\nfar-too-long\nfine', maxLength: 4);

      expect(parsed.entries, ['ok', 'fine']);
      expect(parsed.issues, [
        const InputIssue(
          line: 2,
          raw: 'far-too-long',
          kind: InputIssueKind.valueTooLong,
        ),
      ]);
      expect(parsed.isValid, isFalse);
    });
  });
}
