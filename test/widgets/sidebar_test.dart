import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:fl_clash/widgets/sidebar.dart';
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
    expect(tester.getSize(find.byType(NavigationSidebar)).width, sidebarWidth);
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
    expect(tester.getSize(find.byType(NavigationSidebar)).width, sidebarWidth);
  });
}
