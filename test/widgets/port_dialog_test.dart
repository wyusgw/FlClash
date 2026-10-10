import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/general.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

Future<ProviderContainer> _openPortDialog(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1000, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [profilesProvider.overrideWith(TestProfiles.new)],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container
      .read(viewSizeProvider.notifier)
      .update((_) => const Size(1000, 900));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: Scaffold(body: ListView(children: const [PortItem()])),
      ),
    ),
  );
  await tester.pump();

  await tester.tap(find.byType(PortItem));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('opens with the current proxy port', (tester) async {
    final container = await _openPortDialog(tester);
    final config = container.read(coreSettingProvider);

    expect(find.byType(TextFormField), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller?.text,
      config.mixedPort.toString(),
    );
  });

  testWidgets('rejects a port outside the allowed range', (tester) async {
    await _openPortDialog(tester);

    await tester.enterText(find.byType(TextFormField), '80');
    await tester.pumpAndSettle();

    expect(find.textContaining('1024'), findsWidgets);
  });

  testWidgets('a rejected port is not written', (tester) async {
    final container = await _openPortDialog(tester);
    final before = container.read(coreSettingProvider).mixedPort;

    await tester.enterText(find.byType(TextFormField), '80');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(container.read(coreSettingProvider).mixedPort, before);
    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('submitting a valid port writes it to the core config', (
    tester,
  ) async {
    final container = await _openPortDialog(tester);

    await tester.enterText(find.byType(TextFormField), '7891');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(container.read(coreSettingProvider).mixedPort, 7891);
    expect(find.byType(TextFormField), findsNothing);
  });
}
