import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:fl_clash/widgets/sidebar.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

const _destinations = [
  SidebarDestination(glyph: AppGlyphs.home, label: 'Home'),
  SidebarDestination(glyph: AppGlyphs.folder, label: 'Profiles'),
  SidebarDestination(glyph: AppGlyphs.settings, label: 'Settings'),
];

Widget _sidebar({
  int selectedIndex = 0,
  ValueChanged<int>? onSelected,
  Size windowControls = Size.zero,
}) {
  return TestApp(
    child: Scaffold(
      body: Row(
        children: [
          SizedBox(
            height: 400,
            child: NavigationSidebar(
              destinations: _destinations,
              selectedIndex: selectedIndex,
              onSelected: onSelected ?? (_) {},
              windowControls: windowControls,
            ),
          ),
          const Expanded(child: SizedBox.expand(key: ValueKey('content'))),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('every destination shows its icon and its label', (tester) async {
    await tester.pumpWidget(_sidebar());

    for (final destination in _destinations) {
      expect(find.text(destination.label), findsOneWidget);
      expect(find.byGlyph(destination.glyph), findsOneWidget);
    }
    expect(
      tester.getSize(find.byType(NavigationSidebar)).width,
      defaultSidebarWidth,
    );
  });

  testWidgets('the selected destination sits on the accent', (tester) async {
    await tester.pumpWidget(_sidebar(selectedIndex: 1));
    final accent = GroupedPalette.of(
      tester.element(find.byType(NavigationSidebar)),
    ).accent;

    Color fillOf(String label) {
      final material = tester.widget<Material>(
        find
            .ancestor(of: find.text(label), matching: find.byType(Material))
            .first,
      );
      return material.color!;
    }

    expect(fillOf('Profiles'), accent);
    expect(fillOf('Home'), isNot(accent));
    expect(fillOf('Settings'), isNot(accent));
  });

  testWidgets('no destination takes a shade under the pointer', (tester) async {
    await tester.pumpWidget(_sidebar(selectedIndex: 1));

    for (final label in ['Home', 'Profiles', 'Settings']) {
      final inkWell = tester.widget<InkWell>(
        find
            .ancestor(of: find.text(label), matching: find.byType(InkWell))
            .first,
      );
      expect(inkWell.hoverColor, Colors.transparent, reason: label);
    }
  });

  testWidgets('a mouse resting on a destination paints nothing over it', (
    tester,
  ) async {
    await tester.pumpWidget(_sidebar(selectedIndex: 1));
    final palette = GroupedPalette.of(
      tester.element(find.byType(NavigationSidebar)),
    );
    final material = find
        .ancestor(of: find.text('Home'), matching: find.byType(Material))
        .first;
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);

    await mouse.moveTo(tester.getCenter(find.text('Home')));
    await tester.pumpAndSettle();

    expect(
      tester.renderObject(material),
      isNot(paints..rect(color: palette.hover)),
    );
    expect(
      tester.renderObject(material),
      isNot(paints..rect(color: palette.hoverShade)),
    );
  });

  testWidgets('tapping a destination reports its index', (tester) async {
    final selected = <int>[];
    await tester.pumpWidget(_sidebar(onSelected: selected.add));

    await tester.tap(find.text('Settings'));
    await tester.tap(find.text('Home'));

    expect(selected, [2, 0]);
  });

  testWidgets('the list stays clear of the window buttons', (tester) async {
    await tester.pumpWidget(_sidebar(windowControls: const Size(78, 32)));

    final top = tester.getTopLeft(find.text('Home')).dy;

    expect(top, greaterThan(32));
  });

  testWidgets('a long label is cut instead of wrapping', (tester) async {
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: NavigationSidebar(
            destinations: const [
              SidebarDestination(
                glyph: AppGlyphs.home,
                label: 'A destination name far too long to fit the pane at all',
              ),
            ],
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(NavigationSidebar)).width,
      defaultSidebarWidth,
    );
  });

  group('resizing', () {
    Widget resizable({double width = defaultSidebarWidth, List<double>? out}) {
      return TestApp(
        child: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Row(
              children: [
                SizedBox(
                  height: 400,
                  child: NavigationSidebar(
                    destinations: _destinations,
                    selectedIndex: 0,
                    onSelected: (_) {},
                    width: width,
                    onResize: (value) {
                      out?.add(value);
                      setState(() => width = value);
                    },
                  ),
                ),
                const Expanded(child: SizedBox.expand()),
              ],
            ),
          ),
        ),
      );
    }

    Future<void> drag(WidgetTester tester, double dx) async {
      await tester.drag(
        find.byKey(const ValueKey('sidebar-grip')),
        Offset(dx, 0),
      );
      await tester.pumpAndSettle();
    }

    double widthOf(WidgetTester tester) =>
        tester.getSize(find.byType(NavigationSidebar)).width;

    testWidgets('has no grip while nothing listens', (tester) async {
      await tester.pumpWidget(_sidebar());

      expect(find.byKey(const ValueKey('sidebar-grip')), findsNothing);
    });

    testWidgets('dragging the edge follows the pointer and reports once', (
      tester,
    ) async {
      final out = <double>[];
      await tester.pumpWidget(resizable(out: out));

      await drag(tester, 30);

      expect(widthOf(tester), defaultSidebarWidth + 30);
      expect(out, [defaultSidebarWidth + 30]);
    });

    testWidgets('stops at the narrowest and the widest', (tester) async {
      final out = <double>[];
      await tester.pumpWidget(resizable(out: out));

      await drag(tester, 1000);
      expect(widthOf(tester), maxSidebarWidth);

      await tester.pumpWidget(resizable(width: maxSidebarWidth, out: out));
      await drag(tester, -1000);
      expect(widthOf(tester), minSidebarWidth);
      expect(out, [maxSidebarWidth, minSidebarWidth]);
    });

    testWidgets('a width outside the bounds is drawn inside them', (
      tester,
    ) async {
      await tester.pumpWidget(resizable(width: 10));
      expect(widthOf(tester), minSidebarWidth);

      await tester.pumpWidget(resizable(width: 5000));
      expect(widthOf(tester), maxSidebarWidth);
    });

    testWidgets('a double tap on the edge asks for the default width', (
      tester,
    ) async {
      final out = <double>[];
      await tester.pumpWidget(resizable(width: 300, out: out));

      final grip = find.byKey(const ValueKey('sidebar-grip'));
      await tester.tap(grip);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(grip);
      await tester.pumpAndSettle();

      expect(out, [defaultSidebarWidth]);
    });
  });
}
