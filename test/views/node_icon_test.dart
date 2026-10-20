import 'package:country_flags/country_flags.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/views/home/node_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(
  WidgetTester tester,
  String name, {
  String? region,
  String? address,
  Map<String, String?> geo = const {},
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        for (final entry in geo.entries)
          nodeGeoRegionProvider(
            entry.key,
          ).overrideWith((_) async => entry.value),
      ],
      child: MaterialApp(
        home: Center(
          child: NodeIcon(name: name, region: region, address: address),
        ),
      ),
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

  testWidgets('the country the user chose beats the one in the name', (
    tester,
  ) async {
    await _pump(tester, '日本 Tokyo 01', region: 'DE');

    final flag = tester.widget<CountryFlag>(find.byType(CountryFlag));
    expect(flag.flagCode, 'de');
  });

  testWidgets('a chosen country with no flag falls back to the badge', (
    tester,
  ) async {
    await _pump(tester, '日本 Tokyo 01', region: 'ZZ');

    expect(find.byType(CountryFlag), findsNothing);
    expect(find.byType(GlyphIcon), findsOneWidget);
  });

  testWidgets('a name with no country is placed by where its server is', (
    tester,
  ) async {
    await _pump(
      tester,
      'Premium',
      address: '203.0.113.9:8388',
      geo: {'203.0.113.9': 'JP'},
    );
    await tester.pump();

    final flag = tester.widget<CountryFlag>(find.byType(CountryFlag));
    expect(flag.flagCode, 'jp');
  });

  testWidgets(
    'a line of the subscription\'s notes is not placed by its address',
    (tester) async {
      await _pump(
        tester,
        '📆套餐到期: 永久不过期',
        address: 'notes.example.com:443',
        geo: {'notes.example.com': 'CN'},
      );
      await tester.pump();

      expect(find.byType(CountryFlag), findsNothing);
      expect(
        tester.widget<GlyphIcon>(find.byType(GlyphIcon)).glyph,
        AppGlyphs.home,
      );
    },
  );

  testWidgets('until the lookup answers the house badge stands in', (
    tester,
  ) async {
    await _pump(
      tester,
      'Premium',
      address: '203.0.113.9:8388',
      geo: {'203.0.113.9': null},
    );
    await tester.pump();

    expect(find.byType(CountryFlag), findsNothing);
    expect(
      tester.widget<GlyphIcon>(find.byType(GlyphIcon)).glyph,
      AppGlyphs.home,
    );
  });

  testWidgets('a country in the name is never looked up', (tester) async {
    var asked = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nodeGeoRegionProvider('203.0.113.9').overrideWith((_) async {
            asked = true;
            return 'DE';
          }),
        ],
        child: const MaterialApp(
          home: NodeIcon(name: '日本 01', address: '203.0.113.9:443'),
        ),
      ),
    );
    await tester.pump();

    expect(asked, isFalse);
    expect(tester.widget<CountryFlag>(find.byType(CountryFlag)).flagCode, 'jp');
  });
}
