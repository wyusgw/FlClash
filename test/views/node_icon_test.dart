import 'package:country_flags/country_flags.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/views/home/node_icon.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, String name) {
  return tester.pumpWidget(
    MaterialApp(
      home: Center(child: NodeIcon(name: name)),
    ),
  );
}

void main() {
  testWidgets('a name that points at a country gets its round flag', (
    tester,
  ) async {
    await _pump(tester, '日本 Tokyo 01');

    expect(find.byType(CountryFlag), findsOneWidget);
    expect(find.byType(ClipOval), findsOneWidget);
    expect(tester.getSize(find.byType(CountryFlag)), const Size.square(19));
    expect(find.byType(GlyphIcon), findsNothing);
  });

  testWidgets('a name that points at none gets the house badge', (
    tester,
  ) async {
    await _pump(tester, 'Premium');

    expect(find.byType(CountryFlag), findsNothing);
    expect(find.byType(GlyphIcon), findsOneWidget);
  });
}
