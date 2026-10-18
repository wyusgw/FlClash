import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_clash/common/flag_icon.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('draws a round flag to a png and keeps it', (tester) async {
    final root = Directory.systemTemp.createTempSync('flag_icon_test');
    addTearDown(() => root.deleteSync(recursive: true));
    PathProviderPlatform.instance = _FakePathProvider(root.path);

    final path = await tester.runAsync(() => flagIconPath('JP'));

    expect(path, isNotNull);
    final bytes = File(path!).readAsBytesSync();
    final image = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(bytes);
      return (await codec.getNextFrame()).image;
    });
    expect(image!.width, 64);
    expect(image.height, 64);
    final data = (await tester.runAsync(
      () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
    ))!;
    int alphaAt(int x, int y) => data.getUint8((y * 64 + x) * 4 + 3);
    expect(alphaAt(32, 32), 255);
    expect(alphaAt(0, 0), 0);
    expect(alphaAt(63, 63), 0);
    expect(Uint8List.view(data.buffer).length, 64 * 64 * 4);
  });

  testWidgets('a code the flag set lacks has no icon', (tester) async {
    final root = Directory.systemTemp.createTempSync('flag_icon_test');
    addTearDown(() => root.deleteSync(recursive: true));
    PathProviderPlatform.instance = _FakePathProvider(root.path);

    expect(await tester.runAsync(() => flagIconPath('ZZ')), isNull);
  });
}
