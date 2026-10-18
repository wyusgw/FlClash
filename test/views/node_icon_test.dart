import 'package:country_flags/country_flags.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/views/home/node_icon.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

Future<void> _pump(
  WidgetTester tester,
  String name, {
  String? region,
  String? address,
  Proxy? lead,
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
          child: NodeIcon(
            name: name,
            region: region,
            address: address,
            lead: lead,
          ),
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

  testWidgets('a line of the subscription\'s notes gets its own icon', (
    tester,
  ) async {
    await _pump(tester, '套餐到期：2026年12月05日');

    expect(find.byType(CountryFlag), findsNothing);
    final glyph = tester.widget<GlyphIcon>(find.byType(GlyphIcon));
    expect(glyph.glyph, AppGlyphs.clock);
  });

  testWidgets('a country in the name still wins over the notes', (
    tester,
  ) async {
    await _pump(tester, '日本 流量 x2');

    expect(find.byType(CountryFlag), findsOneWidget);
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

  testWidgets('a line of the notes takes the first node\'s named country', (
    tester,
  ) async {
    await _pump(
      tester,
      '套餐到期：2026年12月05日',
      address: '203.0.113.9:8388',
      lead: const Proxy(
        name: '中国台湾省 G1',
        type: 'vless',
        address: '203.0.113.9:8388',
      ),
      geo: {'203.0.113.9': 'JP'},
    );
    await tester.pump();

    expect(tester.widget<CountryFlag>(find.byType(CountryFlag)).flagCode, 'tw');
  });

  testWidgets('a line of the notes takes where the first node\'s server is', (
    tester,
  ) async {
    await _pump(
      tester,
      '套餐到期：2026年12月05日',
      lead: const Proxy(
        name: 'Premium',
        type: 'vless',
        address: '203.0.113.9:8388',
      ),
      geo: {'203.0.113.9': 'JP'},
    );
    await tester.pump();

    expect(tester.widget<CountryFlag>(find.byType(CountryFlag)).flagCode, 'jp');
  });

  testWidgets('a line of the notes keeps its icon when nothing places it', (
    tester,
  ) async {
    await _pump(
      tester,
      '套餐到期：2026年12月05日',
      address: '203.0.113.9:8388',
      lead: const Proxy(name: 'Premium', type: 'vless'),
      geo: {'203.0.113.9': 'TW'},
    );
    await tester.pump();

    expect(find.byType(CountryFlag), findsNothing);
    expect(
      tester.widget<GlyphIcon>(find.byType(GlyphIcon)).glyph,
      AppGlyphs.clock,
    );
  });

  testWidgets('the traffic line gets the British flag', (tester) async {
    await _pump(
      tester,
      '剩余流量:+888395.81+GB',
      address: '203.0.113.9:8388',
      lead: const Proxy(name: '日本 01', type: 'vless'),
      geo: {'203.0.113.9': 'JP'},
    );
    await tester.pump();

    expect(tester.widget<CountryFlag>(find.byType(CountryFlag)).flagCode, 'gb');
  });

  testWidgets('a country chosen for the traffic line beats the British flag', (
    tester,
  ) async {
    await _pump(tester, '剩余流量：8.08 GB', region: 'DE');

    expect(tester.widget<CountryFlag>(find.byType(CountryFlag)).flagCode, 'de');
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

  group('leadNode', () {
    test(
      'skips the notes lines and takes the first node that names a country',
      () {
        final lead = leadNode(const [
          Proxy(name: '剩余流量：8.08 GB', type: 'vless', address: 'a.example:1'),
          Proxy(name: 'direct', type: 'direct'),
          Proxy(name: 'Premium', type: 'vless', address: 'b.example:1'),
          Proxy(name: '日本 01', type: 'vless'),
        ]);

        expect(lead?.name, '日本 01');
      },
    );

    test('settles for the first node with a server when none names one', () {
      final lead = leadNode(const [
        Proxy(name: 'direct', type: 'direct'),
        Proxy(name: 'Premium', type: 'vless', address: 'b.example:1'),
      ]);

      expect(lead?.name, 'Premium');
    });

    test('has none without nodes', () {
      expect(leadNode(null), isNull);
      expect(leadNode(const []), isNull);
    });
  });

  testWidgets('the server form flags a line of the notes like the list', (
    tester,
  ) async {
    Future<String?> flagOf(String remark) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TestApp(
            child: SingleChildScrollView(
              child: NodeFormFields(
                kind: NodeKind.shadowsocks,
                values: {
                  ...nodeDefaults(NodeKind.shadowsocks),
                  'remark': remark,
                },
                onChanged: (_, _) {},
                lead: const Proxy(name: '日本 01', type: 'vless'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final flags = find.byType(CountryFlag);
      return flags.evaluate().isEmpty
          ? null
          : tester.widget<CountryFlag>(flags).flagCode;
    }

    expect(await flagOf('套餐到期：永久'), 'jp');
    expect(await flagOf('剩余流量：8.08 GB'), 'gb');
    expect(await flagOf('Premium'), isNull);
  });
}
