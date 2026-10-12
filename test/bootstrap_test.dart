import 'package:dynamic_color/dynamic_color.dart';
import 'package:fl_clash/bootstrap.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_color_utilities/palettes/tonal_palette.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void answer(Object? Function(MethodCall call) handler) {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      DynamicColorPlugin.channel,
      (call) async => handler(call),
    );
    addTearDown(
      () =>
          messenger.setMockMethodCallHandler(DynamicColorPlugin.channel, null),
    );
  }

  List<int> palette() => [
    for (final tone in TonalPalette.commonTones) 0xFF000000 + tone,
  ];

  group('Bootstrap.initDynamicColor', () {
    test(
      'seeds light and dark from tones 40 and 80 of the system palette',
      () async {
        answer(
          (call) => switch (call.method) {
            DynamicColorPlugin.methodName => palette(),
            DynamicColorPlugin.accentColorMethodName => 0xFF123456,
            _ => null,
          },
        );

        final seeds = await bootstrap.initDynamicColor();

        expect(seeds.lightSeed, const Color(0xFF000000 + 40));
        expect(seeds.darkSeed, const Color(0xFF000000 + 80));
        expect(seeds.accentColor, const Color(0xFF123456));
      },
    );

    test('a palette shorter than the common tones gives no seeds', () async {
      answer(
        (call) => call.method == DynamicColorPlugin.methodName
            ? palette().sublist(1)
            : null,
      );

      final seeds = await bootstrap.initDynamicColor();

      expect(seeds.lightSeed, isNull);
      expect(seeds.darkSeed, isNull);
      expect(seeds.accentColor, const Color(defaultPrimaryColor));
    });

    test(
      'a platform that fails both calls falls back to the defaults',
      () async {
        answer((call) => throw PlatformException(code: 'unavailable'));

        final seeds = await bootstrap.initDynamicColor();

        expect(seeds.lightSeed, isNull);
        expect(seeds.darkSeed, isNull);
        expect(seeds.accentColor, const Color(defaultPrimaryColor));
      },
    );
  });
}
