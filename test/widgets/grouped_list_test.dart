import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

Widget _app(Widget child) {
  return TestApp(
    child: Scaffold(
      body: Center(child: SizedBox(width: 400, child: child)),
    ),
  );
}

void main() {
  testWidgets('a section puts a hairline between its rows only', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const GroupedSection(
          children: [
            GroupedRow(title: 'One'),
            GroupedRow(title: 'Two'),
            GroupedRow(title: 'Three'),
          ],
        ),
      ),
    );

    final hairlines = find.byWidgetPredicate(
      (widget) => widget is SizedBox && widget.height == 1,
    );
    expect(hairlines, findsNWidgets(2));
  });

  testWidgets('a hairline starts where the row text starts', (tester) async {
    await tester.pumpWidget(
      _app(
        const GroupedSection(
          children: [
            GroupedRow(title: 'Plain'),
            GroupedRow(
              title: 'With icon',
              leading: GroupedIcon(AppGlyphs.rocket),
            ),
          ],
        ),
      ),
    );

    final hairline = find.byWidgetPredicate(
      (widget) => widget is SizedBox && widget.height == 1,
    );
    final padding = tester.widget<Padding>(
      find.ancestor(of: hairline, matching: find.byType(Padding)).first,
    );
    const iconRow = GroupedRow(
      title: 'x',
      leading: GroupedIcon(AppGlyphs.rocket),
    );

    expect(
      (padding.padding as EdgeInsetsDirectional).start,
      iconRow.separatorInset,
    );
  });

  testWidgets('a row shows its title, subtitle and value and takes a tap', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _app(
        GroupedSection(
          children: [
            GroupedRow(
              title: 'Routing',
              subtitle: 'Forward by rules',
              value: 'Rule',
              chevron: true,
              onTap: () => taps++,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Routing'), findsOneWidget);
    expect(find.text('Forward by rules'), findsOneWidget);
    expect(find.text('Rule'), findsOneWidget);
    await tester.tap(find.text('Routing'));
    expect(taps, 1);
  });

  testWidgets('a section shows its header and footer', (tester) async {
    await tester.pumpWidget(
      _app(
        const GroupedSection(
          header: 'Header text',
          footer: 'Footer text',
          children: [GroupedRow(title: 'Row')],
        ),
      ),
    );

    expect(find.text('Header text'), findsOneWidget);
    expect(find.text('Footer text'), findsOneWidget);
  });

  testWidgets('the switch asks for the opposite value when tapped', (
    tester,
  ) async {
    final values = <bool>[];
    var value = false;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (_, setState) => GroupedSwitch(
            value: value,
            onChanged: (next) {
              values.add(next);
              setState(() => value = next);
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(GroupedSwitch));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(GroupedSwitch));
    await tester.pumpAndSettle();

    expect(values, [true, false]);
  });

  testWidgets('a switch without a handler ignores taps', (tester) async {
    await tester.pumpWidget(_app(const GroupedSwitch(value: true)));

    await tester.tap(find.byType(GroupedSwitch));

    expect(tester.takeException(), isNull);
  });

  test('both palettes keep the label readable on the fill', () {
    for (final palette in [GroupedPalette.dark, GroupedPalette.light]) {
      expect(palette.label, isNot(palette.fill));
      expect(palette.accent, isNot(palette.canvas));
    }
  });
}
