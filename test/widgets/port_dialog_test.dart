import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/general.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

Future<ProviderContainer> _pumpPortRow(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1000, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [profilesProvider.overrideWith(TestProfiles.new)],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.listen(coreSettingProvider, (_, _) {});
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
  return container;
}

Future<void> _typePort(WidgetTester tester, String text) async {
  await tester.tap(find.byType(PortItem));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(EditableText), text);
}

Future<void> _enter(WidgetTester tester) async {
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the current proxy port on the row', (tester) async {
    final container = await _pumpPortRow(tester);

    expect(
      find.text(container.read(coreSettingProvider).mixedPort.toString()),
      findsOneWidget,
    );
    expect(find.byType(EditableText), findsNothing);
  });

  testWidgets('a tap opens the port for typing in the row, with no dialog', (
    tester,
  ) async {
    final container = await _pumpPortRow(tester);

    await tester.tap(find.byType(PortItem));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      container.read(coreSettingProvider).mixedPort.toString(),
    );
  });

  testWidgets('a port outside the allowed range is refused with a reason', (
    tester,
  ) async {
    final container = await _pumpPortRow(tester);
    final before = container.read(coreSettingProvider).mixedPort;

    await _typePort(tester, '80');
    await _enter(tester);

    expect(find.textContaining('1024'), findsWidgets);
    expect(find.byType(EditableText), findsOneWidget, reason: 'stays open');
    expect(container.read(coreSettingProvider).mixedPort, before);
  });

  testWidgets('a valid port is written to the core config on Enter', (
    tester,
  ) async {
    final container = await _pumpPortRow(tester);

    await _typePort(tester, '7891');
    await _enter(tester);

    expect(container.read(coreSettingProvider).mixedPort, 7891);
    expect(find.byType(EditableText), findsNothing);
    expect(find.text('7891'), findsOneWidget);
  });

  testWidgets('only digits can be typed', (tester) async {
    await _pumpPortRow(tester);

    await _typePort(tester, '78a9b1');

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '7891',
    );
  });

  testWidgets('Escape leaves the port as it was', (tester) async {
    final container = await _pumpPortRow(tester);
    final before = container.read(coreSettingProvider).mixedPort;

    await _typePort(tester, '7891');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byType(EditableText), findsNothing);
    expect(container.read(coreSettingProvider).mixedPort, before);
  });

  testWidgets('Reset puts the default port back in one tap', (tester) async {
    final container = await _pumpPortRow(tester);
    container
        .read(coreSettingProvider.notifier)
        .update((state) => state.copyWith(mixedPort: 7891));
    await tester.pump();

    await tester.tap(find.byType(PortItem));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(container.read(coreSettingProvider).mixedPort, defaultMixedPort);
  });

  test('validatePort names what is wrong', () {
    final l10n = AppLocalizations.current;

    expect(validatePort('', l10n), isNotNull);
    expect(validatePort('abc', l10n), isNotNull);
    expect(validatePort('80', l10n), isNotNull);
    expect(validatePort('60000', l10n), isNotNull);
    expect(validatePort('7890', l10n), isNull);
  });
}
