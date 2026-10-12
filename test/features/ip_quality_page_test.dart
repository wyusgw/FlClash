import 'package:fl_clash/common/ip_quality.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/ip_quality/ip_quality.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/ip_quality.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod/misc.dart' show Override;

import '../helpers/test_app.dart';

const _ip = '2.2.2.2';

Future<ProviderContainer> _pump(
  WidgetTester tester,
  Future<IpQuality> Function() lookup,
) async {
  tester.view.physicalSize = const Size(900, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: <Override>[
      ipQualityProvider(_ip).overrideWith((ref) => lookup()),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(child: IpQualityPage(ip: _ip)),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('lists the address, quality, flags and network of the lookup', (
    tester,
  ) async {
    await _pump(
      tester,
      () async => const IpQuality(
        ip: _ip,
        source: IpQualitySource.ipQuery,
        type: IpType.residential,
        organization: 'Example Net',
        asn: 64500,
        isVpn: true,
      ),
    );

    final l10n = AppLocalizations.current;
    expect(find.text(_ip), findsOneWidget);
    expect(find.text(l10n.ipQualityGood), findsOneWidget);
    expect(find.text(l10n.ipTypeResidential), findsOneWidget);
    expect(find.text(l10n.ipFlagVpn), findsOneWidget);
    expect(find.text('Example Net'), findsOneWidget);
    expect(find.text('AS64500'), findsOneWidget);
    expect(find.text(IpQualitySource.ipQuery.label), findsOneWidget);
  });

  testWidgets('a failed lookup says so and lists each source', (tester) async {
    await _pump(
      tester,
      () async => throw const IpQualityLookupException([
        (
          source: IpQualitySource.ipQuery,
          status: IpQualitySourceStatus.timeout,
        ),
      ]),
    );

    final l10n = AppLocalizations.current;
    expect(find.text(l10n.ipQualityFailed), findsOneWidget);
    expect(find.text(l10n.ipQualitySources), findsOneWidget);
    expect(find.text(IpQualitySource.ipQuery.label), findsOneWidget);
    expect(find.text(l10n.timeout), findsOneWidget);
  });

  testWidgets('the hide switch masks the address', (tester) async {
    final container = await _pump(
      tester,
      () async => const IpQuality(
        ip: _ip,
        source: IpQualitySource.ipQuery,
        type: IpType.hosting,
      ),
    );

    await tester.tap(find.byType(GroupedSwitch));
    await tester.pumpAndSettle();

    expect(container.read(appSettingProvider).hideIp, isTrue);
    expect(find.text(_ip), findsNothing);
    expect(find.text(ipMask), findsOneWidget);
  });
}
