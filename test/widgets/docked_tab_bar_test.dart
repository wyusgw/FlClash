import 'dart:ui' show Tristate;

import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

const _destinations = [
  NavigationDockDestination(glyph: AppGlyphs.home, label: 'Home'),
  NavigationDockDestination(glyph: AppGlyphs.folder, label: 'Profiles'),
  NavigationDockDestination(glyph: AppGlyphs.dataUsage, label: 'Data'),
  NavigationDockDestination(glyph: AppGlyphs.settings, label: 'Settings'),
];

Future<void> _pump(
  WidgetTester tester, {
  int selected = 0,
  ValueChanged<int>? onSelected,
  double bottomInset = 0,
}) async {
  tester.view.physicalSize = const Size(800, 600);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding(bottom: bottomInset);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    TestApp(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: DockedTabBar(
          destinations: _destinations,
          selectedIndex: selected,
          onSelected: onSelected ?? (_) {},
        ),
      ),
    ),
  );
}

Color? _labelColor(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style?.color;

void main() {
  testWidgets('shows an icon over a small label for every page', (
    tester,
  ) async {
    await _pump(tester);

    for (final destination in _destinations) {
      expect(find.text(destination.label), findsOneWidget);
      expect(find.byGlyph(destination.glyph), findsOneWidget);
    }
    expect(
      tester.widget<Text>(find.text('Home')).style?.fontSize,
      lessThan(11),
    );
  });

  testWidgets('spreads the pages evenly along the whole width', (tester) async {
    await _pump(tester);

    final centers = [
      for (final destination in _destinations)
        tester.getCenter(find.byGlyph(destination.glyph)).dx,
    ];
    expect(centers.first, lessThan(800 / 4));
    expect(centers.last, greaterThan(800 * 3 / 4));
    for (var i = 1; i < centers.length; i++) {
      expect(centers[i] - centers[i - 1], moreOrLessEquals(200, epsilon: 1));
    }
  });

  testWidgets('the page in view is in the accent color, the rest are not', (
    tester,
  ) async {
    await _pump(tester, selected: 3);
    final palette = GroupedPalette.of(
      tester.element(find.byType(DockedTabBar)),
    );

    expect(_labelColor(tester, 'Settings'), palette.accent);
    for (final label in ['Home', 'Profiles', 'Data']) {
      expect(_labelColor(tester, label), palette.secondary, reason: label);
    }
    expect(
      tester.widget<GlyphIcon>(find.byGlyph(AppGlyphs.settings)).color,
      palette.accent,
    );
  });

  testWidgets('a tap anywhere on a page reports its index', (tester) async {
    final taps = <int>[];
    await _pump(tester, onSelected: taps.add);

    await tester.tap(find.text('Profiles'));
    await tester.tapAt(
      tester.getTopLeft(find.byType(DockedTabBar)) + const Offset(790, 30),
    );

    expect(taps, [1, 3]);
  });

  testWidgets('is flat, compact and sits clear of the home indicator', (
    tester,
  ) async {
    await _pump(tester, bottomInset: 34);
    final palette = GroupedPalette.of(
      tester.element(find.byType(DockedTabBar)),
    );

    final size = tester.getSize(find.byType(DockedTabBar));
    expect(size.width, 800);
    expect(size.height, 1 + 49 + 34);
    expect(
      find.descendant(
        of: find.byType(DockedTabBar),
        matching: find.byWidgetPredicate(
          (widget) => widget is ColoredBox && widget.color == palette.bar,
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(DockedTabBar),
        matching: find.byWidgetPredicate(
          (widget) => widget is ColoredBox && widget.color == palette.separator,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tells assistive technology which page is selected', (
    tester,
  ) async {
    await _pump(tester, selected: 1);

    final semantics = tester.getSemantics(find.text('Profiles'));
    expect(semantics.flagsCollection.isSelected, Tristate.isTrue);
    expect(semantics.label, 'Profiles');
  });
}
