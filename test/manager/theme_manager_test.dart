import 'package:fl_clash/manager/theme_manager.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

class _Probe extends StatelessWidget {
  const _Probe();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: GroupedPalette.of(context).accent);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    globalState.container = container;
    container.listen(themeSettingProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  Future<void> pumpUnder(WidgetTester tester, Brightness brightness) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: ThemeManager(
            child: Theme(
              data: ThemeData(brightness: brightness),
              child: const _Probe(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Color? accentShown(WidgetTester tester) =>
      tester.widget<ColoredBox>(find.byType(ColoredBox).last).color;

  testWidgets('without adjustments the pages keep the built-in colors', (
    tester,
  ) async {
    await pumpUnder(tester, Brightness.dark);

    expect(accentShown(tester), GroupedPalette.dark.accent);
  });

  testWidgets('an adjusted color reaches the pages of that look only', (
    tester,
  ) async {
    container
        .read(themeSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            paletteColors: const {'dark.AccentColor': 0xFF336699},
          ),
        );

    await pumpUnder(tester, Brightness.dark);
    expect(accentShown(tester), const Color(0xFF336699));

    await pumpUnder(tester, Brightness.light);
    expect(accentShown(tester), GroupedPalette.light.accent);
  });

  testWidgets('a color changed while the app runs is picked up at once', (
    tester,
  ) async {
    await pumpUnder(tester, Brightness.dark);

    container
        .read(themeSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            paletteColors: const {'dark.AccentColor': 0xFF112233},
          ),
        );
    await tester.pump();

    expect(accentShown(tester), const Color(0xFF112233));
  });
}
