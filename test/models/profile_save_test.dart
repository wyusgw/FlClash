import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  final String root;

  _FakePathProvider(this.root);

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
    tempDir = Directory.systemTemp.createTempSync('profile_save_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
  });

  tearDownAll(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  const link = 'trojan://pass@tj.example.com:443?security=tls#node-a';

  group('Profile.saveFile', () {
    // EditProfileView relies on this throwing rather than silently
    // succeeding, so a caller-level try/catch can surface the failure.
    test(
      'rejects a config the Core refuses without touching the file',
      () async {
        final profile = Profile.normal(label: 'p');
        final bytes = Uint8List.fromList(utf8.encode(link));

        await expectLater(
          profile.saveFile(bytes, validate: (_) async => 'invalid config'),
          throwsA(
            isA<MessageException>().having(
              (e) => e.message,
              'message',
              'invalid config',
            ),
          ),
        );

        final savedFile = await profile.file;
        expect(await savedFile.length(), 0);
      },
    );

    test('rejects a subscription without a usable node', () async {
      final profile = Profile.normal(label: 'p');
      var validated = false;

      await expectLater(
        profile.saveFile(
          Uint8List.fromList(utf8.encode('proxies:\n  - name: a')),
          validate: (_) async {
            validated = true;
            return '';
          },
        ),
        throwsA(
          isA<MessageException>().having(
            (error) => error.message,
            'message',
            AppLocalizations.current.noUsableNodes,
          ),
        ),
      );

      expect(validated, isFalse);
    });

    test('stores the nodes as an Xray config of outbounds', () async {
      final profile = Profile.normal(label: 'p');
      String? validatedContent;

      final saved = await profile.saveFile(
        Uint8List.fromList(utf8.encode(link)),
        validate: (path) async {
          validatedContent = await File(path).readAsString();
          return '';
        },
      );

      expect(saved.lastUpdateDate, isNotNull);
      final savedFile = await profile.file;
      final stored = json.decode(await savedFile.readAsString()) as Map;
      expect((stored['outbounds'] as List).single['tag'], 'node-a');
      expect(validatedContent, await savedFile.readAsString());
    });

    test('a stored profile reads back as the same nodes', () async {
      final profile = Profile.normal(label: 'p');
      await profile.saveFile(
        Uint8List.fromList(utf8.encode(link)),
        validate: (_) async => '',
      );

      final savedFile = await profile.file;

      expect(
        parseSubscription(await savedFile.readAsString()).single['tag'],
        'node-a',
      );
    });
  });
}
