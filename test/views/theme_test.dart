import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/theme.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1400, 2400);
  });

  tearDown(() => container.dispose());

  Future<void> pumpThemeView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ThemeView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  ThemeProps readTheme() => container.read(themeSettingProvider);

  group('appearance', () {
    Future<void> chooseMode(WidgetTester tester, String label) async {
      await tester.tap(find.widgetWithText(GroupedRow, 'Appearance'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(GroupedRow, label).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
    }

    testWidgets('defaults to the dark theme and says so on its row', (
      tester,
    ) async {
      await pumpThemeView(tester);

      expect(readTheme().themeMode, ThemeMode.dark);
      expect(
        find.descendant(
          of: find.widgetWithText(GroupedRow, 'Appearance'),
          matching: find.text('Dark'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('keeps only appearance, colors and text size', (tester) async {
      await pumpThemeView(tester);
      final l10n = AppLocalizations.current;

      for (final kept in [
        l10n.appearance,
        l10n.colors,
        l10n.resetColors,
        l10n.copyColorLink,
      ]) {
        expect(find.text(kept), findsWidgets, reason: kept);
      }
      await tester.scrollUntilVisible(find.text(l10n.textScale), 200);
      expect(find.text(l10n.textScale), findsOneWidget);
      for (final removed in [
        l10n.themeColor,
        l10n.pureBlack,
        l10n.pureBlackMode,
        l10n.navigationBarStyle,
        l10n.tabAnimation,
        l10n.sidebarBlur,
      ]) {
        expect(find.text(removed), findsNothing, reason: removed);
      }
    });

    testWidgets('switches to light, auto and back to dark', (tester) async {
      await pumpThemeView(tester);

      await chooseMode(tester, 'Light');
      expect(readTheme().themeMode, ThemeMode.light);

      await chooseMode(tester, 'Auto');
      expect(readTheme().themeMode, ThemeMode.system);

      await chooseMode(tester, 'Dark');
      expect(readTheme().themeMode, ThemeMode.dark);
    });
  });

  group('colors', () {
    Finder row(String text) => find.widgetWithText(GroupedRow, text);

    Future<void> openColors(WidgetTester tester) async {
      await tester.tap(row('Colors').last);
      await tester.pumpAndSettle();
    }

    Future<void> setHex(WidgetTester tester, String token, String hex) async {
      await tester.tap(row(token));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), hex);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    InkResponse save(WidgetTester tester) =>
        tester.widget<InkResponse>(find.widgetWithText(InkResponse, 'Save'));

    testWidgets('the section offers the colors, a reset and a link', (
      tester,
    ) async {
      await pumpThemeView(tester);

      expect(find.text('Colors'), findsNWidgets(2));
      expect(row('Reset colors'), findsOneWidget);
      expect(row('Copy link'), findsOneWidget);
    });

    testWidgets('the page lists each color with its hex value and name', (
      tester,
    ) async {
      await pumpThemeView(tester);
      await openColors(tester);

      for (final token in GroupedColorToken.values) {
        expect(find.text(token.id), findsOneWidget, reason: token.id);
      }
      expect(find.text('#000000'), findsWidgets);
      expect(find.text('#F7F7F7'), findsOneWidget);
      expect(find.text('#007AFF'), findsOneWidget);
    });

    testWidgets('a color edited and saved is stored for the look in use only', (
      tester,
    ) async {
      await pumpThemeView(tester);
      await openColors(tester);
      expect(save(tester).onTap, isNull);

      await setHex(tester, 'AccentColor', 'ff0000');

      expect(find.text('#FF0000'), findsOneWidget);
      expect(save(tester).onTap, isNotNull);
      expect(readTheme().paletteColors, isEmpty, reason: 'not before Save');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(readTheme().paletteColors, {'light.AccentColor': 0xFFFF0000});
    });

    testWidgets('setting a color back to its default drops the override', (
      tester,
    ) async {
      container
          .read(themeSettingProvider.notifier)
          .update(
            (state) => state.copyWith(
              paletteColors: const {'light.AccentColor': 0xFFFF0000},
            ),
          );
      await pumpThemeView(tester);
      await openColors(tester);
      expect(find.text('#FF0000'), findsOneWidget);

      await setHex(tester, 'AccentColor', '007AFF');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(readTheme().paletteColors, isEmpty);
    });

    testWidgets('a tap turns the value into a field in the row itself', (
      tester,
    ) async {
      await pumpThemeView(tester);
      await openColors(tester);

      final before = tester.getSize(row('AccentColor'));
      final textBefore = tester.getTopLeft(find.text('#007AFF'));
      await tester.tap(row('AccentColor'));
      await tester.pumpAndSettle();

      expect(find.byType(InputDialog), findsNothing);
      expect(find.byType(TextField), findsNothing, reason: 'no input box');
      expect(tester.getSize(row('AccentColor')), before);
      expect(
        tester.getTopLeft(find.byType(EditableText)).dy,
        moreOrLessEquals(textBefore.dy, epsilon: 2),
        reason: 'the text stays where it was while it is edited',
      );
      expect(find.byType(EditableText), findsOneWidget);
      expect(
        find.descendant(
          of: row('AccentColor'),
          matching: find.byType(EditableText),
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '007AFF',
      );
    });

    group('the swatch', () {
      Finder swatch(String token) => find.byKey(ValueKey('swatch.$token'));

      testWidgets('opens a palette to pick from, or a value to type', (
        tester,
      ) async {
        await pumpThemeView(tester);
        await openColors(tester);

        await tester.tap(swatch('AccentColor'));
        await tester.pumpAndSettle();

        expect(find.byType(ColorPickerDialog), findsOneWidget);
        expect(find.byKey(const ValueKey('color.panel')), findsOneWidget);
        expect(find.byKey(const ValueKey('color.hue')), findsOneWidget);
        expect(find.byKey(const ValueKey('color.alpha')), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(ColorPickerDialog),
            matching: find.byType(EditableText),
          ),
          findsOneWidget,
        );
      });

      testWidgets('a typed value is kept on Confirm', (tester) async {
        await pumpThemeView(tester);
        await openColors(tester);

        await tester.tap(swatch('AccentColor'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(EditableText), 'ff0000');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        expect(find.byType(ColorPickerDialog), findsNothing);
        expect(find.text('#FF0000'), findsOneWidget);
        expect(save(tester).onTap, isNotNull);
      });

      testWidgets('a drag on the panel moves the color and the value', (
        tester,
      ) async {
        await pumpThemeView(tester);
        await openColors(tester);

        await tester.tap(swatch('AccentColor'));
        await tester.pumpAndSettle();
        final panel = find.byKey(const ValueKey('color.panel'));
        await tester.tapAt(tester.getTopLeft(panel));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<EditableText>(find.byType(EditableText))
              .controller
              .text,
          'FFFFFF',
          reason: 'the top left of the panel is white',
        );
      });

      testWidgets('Cancel leaves the color as it was', (tester) async {
        await pumpThemeView(tester);
        await openColors(tester);

        await tester.tap(swatch('AccentColor'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(EditableText), 'ff0000');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.byType(ColorPickerDialog), findsNothing);
        expect(find.text('#007AFF'), findsOneWidget);
        expect(save(tester).onTap, isNull);
      });
    });

    testWidgets('moving to another row applies the one being edited', (
      tester,
    ) async {
      await pumpThemeView(tester);
      await openColors(tester);

      await tester.tap(row('AccentColor'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'FF0000');
      await tester.tap(row('IconColor'));
      await tester.pumpAndSettle();

      expect(find.text('#FF0000'), findsOneWidget);
      expect(find.byType(EditableText), findsOneWidget);
      expect(
        find.descendant(
          of: row('IconColor'),
          matching: find.byType(EditableText),
        ),
        findsOneWidget,
      );
      expect(save(tester).onTap, isNotNull);
    });

    testWidgets('saving while a row is open keeps what was typed', (
      tester,
    ) async {
      await pumpThemeView(tester);
      await openColors(tester);

      await tester.tap(row('AccentColor'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), '00FF00');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(readTheme().paletteColors, {'light.AccentColor': 0xFF00FF00});
    });

    testWidgets('a value that is no color leaves the color as it was', (
      tester,
    ) async {
      await pumpThemeView(tester);
      await openColors(tester);

      await setHex(tester, 'AccentColor', 'xyz');

      expect(find.text('#007AFF'), findsOneWidget);
      expect(save(tester).onTap, isNull);
    });

    testWidgets('leaving with edits asks first and can discard them', (
      tester,
    ) async {
      await pumpThemeView(tester);
      await openColors(tester);
      await setHex(tester, 'AccentColor', 'ff0000');

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Save the changes?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AppearanceColorsView), findsNothing);
      expect(readTheme().paletteColors, isEmpty);
    });

    testWidgets('resetting the colors asks and then clears them', (
      tester,
    ) async {
      container
          .read(themeSettingProvider.notifier)
          .update(
            (state) => state.copyWith(
              paletteColors: const {'dark.CanvasColor': 0xFF123456},
            ),
          );
      await pumpThemeView(tester);

      await tester.tap(row('Reset colors'));
      await tester.pumpAndSettle();
      expect(readTheme().paletteColors, isNotEmpty);

      await tester.tap(
        find.descendant(
          of: find.byType(ConfirmDialog),
          matching: find.text('Reset'),
        ),
      );
      await tester.pumpAndSettle();

      expect(readTheme().paletteColors, isEmpty);
    });

    testWidgets('the link copies the colors in force', (tester) async {
      String? copied;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String;
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      container
          .read(themeSettingProvider.notifier)
          .update(
            (state) => state.copyWith(
              paletteColors: const {'dark.AccentColor': 0xFF336699},
            ),
          );
      await pumpThemeView(tester);

      await tester.tap(row('Copy link'));
      await tester.pumpAndSettle();

      final uri = Uri.parse(copied!);
      expect(uri.scheme, 'flclash');
      expect(uri.host, 'color');
      expect(uri.queryParameters['v'], '1.0');
      expect(uri.queryParameters['dark.AccentColor'], '336699');
      expect(uri.queryParameters['dark.CanvasColor'], '000000');
      expect(parseColorLink(uri), isNotNull);
    });
  });

  group('text scale', () {
    testWidgets('starts custom at 88% and can follow the system', (
      tester,
    ) async {
      await pumpThemeView(tester);

      expect(readTheme().textScale.enable, isTrue);
      expect(readTheme().textScale.scale, defaultTextScale);
      expect(find.text('88%'), findsOneWidget);
      expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNotNull);

      await tester.tap(find.text('Follow system'));
      await tester.pumpAndSettle();

      expect(readTheme().textScale.enable, isFalse);
      expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);

      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      expect(readTheme().textScale.enable, isTrue);
    });

    testWidgets('writes the scale only when the drag ends', (tester) async {
      await pumpThemeView(tester);
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      final before = readTheme().textScale.scale;

      final slider = find.byType(Slider);
      final gesture = await tester.startGesture(tester.getCenter(slider));
      await gesture.moveBy(const Offset(120, 0));
      await tester.pump();
      expect(readTheme().textScale.scale, before);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(readTheme().textScale.scale, isNot(before));
    });

    testWidgets('resets a custom scale to 88%', (tester) async {
      container
          .read(themeSettingProvider.notifier)
          .update(
            (state) => state.copyWith.textScale(enable: true, scale: 1.2),
          );

      await pumpThemeView(tester);

      expect(find.text('120%'), findsOneWidget);

      await tester.tap(find.byTooltip('Reset').last);
      await tester.pumpAndSettle();

      expect(readTheme().textScale.scale, defaultTextScale);
      expect(find.text('88%'), findsOneWidget);
    });
  });
}
