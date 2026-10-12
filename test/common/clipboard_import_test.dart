import 'package:fl_clash/common/clipboard_import.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _vless =
    'vless://11111111-2222-3333-4444-555555555555@example.com:443'
    '?security=tls&type=tcp#Tokyo';
const _trojan = 'trojan://secret@example.org:443#Osaka';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('parseClipboardImport', () {
    test('a subscription address is taken as one', () {
      final found = parseClipboardImport(
        '  https://example.com/sub?token=1 \n',
      );

      expect(found, isA<ClipboardSubscription>());
      expect(
        (found as ClipboardSubscription).url,
        'https://example.com/sub?token=1',
      );
      expect(found.text, 'https://example.com/sub?token=1');
    });

    test('a share link is taken as one node', () {
      final found = parseClipboardImport(_vless);

      expect(found, isA<ClipboardNodes>());
      final nodes = (found! as ClipboardNodes).outbounds;
      expect(nodes, hasLength(1));
      expect(nodes.single['protocol'], 'vless');
    });

    test('several share links, one to a line, are several nodes', () {
      final found = parseClipboardImport('$_vless\n\n$_trojan\n');

      expect((found! as ClipboardNodes).outbounds, hasLength(2));
    });

    test('nothing is taken from a line that is not a node', () {
      expect(parseClipboardImport('$_vless\nhello there'), isNull);
    });

    test('plain text, other addresses and empty text are left alone', () {
      expect(parseClipboardImport(null), isNull);
      expect(parseClipboardImport('   \n'), isNull);
      expect(parseClipboardImport('just some words'), isNull);
      expect(parseClipboardImport('ftp://example.com/file'), isNull);
      expect(parseClipboardImport('https://example.com has a space'), isNull);
      expect(parseClipboardImport('unknown://example.com'), isNull);
    });
  });

  group('readClipboardImport', () {
    Future<void> clipboardHolds(String? text) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.getData') {
              return text == null ? null : <String, Object?>{'text': text};
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
    }

    test('reads the text on the clipboard', () async {
      await clipboardHolds('https://example.com/sub');

      final found = await readClipboardImport();

      expect((found! as ClipboardSubscription).url, 'https://example.com/sub');
    });

    test('an empty clipboard holds nothing to import', () async {
      await clipboardHolds(null);

      expect(await readClipboardImport(), isNull);
    });
  });
}
