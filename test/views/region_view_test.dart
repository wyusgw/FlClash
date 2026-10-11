import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/views/profiles/region.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

AppLocalizations get l10n => currentAppLocalizations;

void main() {
  Future<void> open(
    WidgetTester tester, {
    String selected = '',
    String? detected,
    void Function(String?)? onResult,
  }) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  final result = await BaseNavigator.push<String>(
                    context,
                    RegionView(selected: selected, detected: detected),
                  );
                  onResult?.call(result);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('the chosen country carries the check', (tester) async {
    await open(tester, selected: 'FR');

    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(GroupedRow, 'FR'),
        matching: find.byGlyph(AppGlyphs.check),
      ),
      findsOneWidget,
    );
  });

  testWidgets('what was found carries the check while nothing is chosen', (
    tester,
  ) async {
    await open(tester, detected: 'JP');

    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(GroupedRow, 'JP'),
        matching: find.byGlyph(AppGlyphs.check),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a chosen country takes the check from what was found', (
    tester,
  ) async {
    await open(tester, selected: 'FR', detected: 'JP');

    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(GroupedRow, 'FR'),
        matching: find.byGlyph(AppGlyphs.check),
      ),
      findsOneWidget,
    );
  });

  testWidgets('it opens at the checked country', (tester) async {
    await open(tester, detected: 'ZA');

    final viewport = tester.getRect(find.byType(SingleChildScrollView));
    expect(tester.getTopLeft(find.text('ZA')).dy, lessThan(viewport.bottom));
    expect(tester.getTopLeft(find.text('AD')).dy, lessThan(viewport.top));
  });

  testWidgets('picking what was found makes it a choice of its own', (
    tester,
  ) async {
    String? picked = 'untouched';
    await open(tester, detected: 'JP', onResult: (value) => picked = value);

    await tester.tap(find.text('JP'));
    await tester.pumpAndSettle();

    expect(picked, 'JP');
  });

  testWidgets('with none chosen or found nothing is checked', (tester) async {
    await open(tester);

    expect(find.byGlyph(AppGlyphs.check), findsNothing);
    expect(find.byType(GroupedRow).first, isNotNull);
    expect(
      tester.widget<GroupedRow>(find.byType(GroupedRow).first).title,
      'AD',
    );
  });

  testWidgets('searching narrows the list by name or code', (tester) async {
    await open(tester);

    await tester.enterText(find.byType(TextField), 'kor');
    await tester.pump();
    expect(find.text('KR'), findsOneWidget);
    expect(find.text('JP'), findsNothing);

    await tester.enterText(find.byType(TextField), 'jp');
    await tester.pump();
    expect(find.text('JP'), findsOneWidget);
  });

  testWidgets('countries sit under the letter they start with', (tester) async {
    await open(tester);

    final a = tester.getTopLeft(find.text('AD')).dy;
    final b = tester.getTopLeft(find.text('BA')).dy;
    expect(find.text('A'), findsWidgets);
    expect(tester.getTopLeft(find.text('AE')).dy, greaterThan(a));
    expect(b, greaterThan(tester.getTopLeft(find.text('AZ')).dy));
  });

  testWidgets('the letters at the edge jump to their section', (tester) async {
    await open(tester);
    final viewport = tester.getRect(find.byType(SingleChildScrollView));
    expect(tester.getTopLeft(find.text('ZA')).dy, greaterThan(viewport.bottom));

    await tester.tapAt(tester.getCenter(find.text('Z').last));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('ZA')).dy, lessThan(viewport.bottom));
    expect(tester.getTopLeft(find.text('AD')).dy, lessThan(viewport.top));
  });

  testWidgets('searching leaves only the letters that still have a country', (
    tester,
  ) async {
    await open(tester);

    await tester.enterText(find.byType(TextField), 'japan');
    await tester.pump();

    expect(find.text('JP'), findsOneWidget);
    expect(find.text('J'), findsWidgets);
    expect(find.text('Z'), findsNothing);
  });

  testWidgets('picking a country hands back its code', (tester) async {
    String? picked = 'untouched';
    await open(tester, onResult: (value) => picked = value);

    await tester.enterText(find.byType(TextField), 'japan');
    await tester.pump();
    await tester.tap(find.text('JP'));
    await tester.pumpAndSettle();

    expect(picked, 'JP');
  });

  testWidgets('picking the chosen country again hands back an empty code', (
    tester,
  ) async {
    String? picked = 'untouched';
    await open(tester, selected: 'AD', onResult: (value) => picked = value);

    await tester.tap(find.text('AD'));
    await tester.pumpAndSettle();

    expect(picked, '');
  });
}
