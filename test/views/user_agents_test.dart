import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/user_agents.dart';
import 'package:fl_clash/widgets/grouped_input.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _second = 'Custom/2.0';
final _seeded = [...defaultUserAgents, _second];

void main() {
  late ProviderContainer container;

  String? selected() => container.read(appSettingProvider).globalUa;

  List<String> saved() => container.read(appSettingProvider).userAgents;

  Finder menuOf(String userAgent) => find.descendant(
    of: find.ancestor(
      of: find.text(userAgent),
      matching: find.byType(GroupedRow),
    ),
    matching: find.byTooltip(currentAppLocalizations.more),
  );

  Future<void> pumpView(WidgetTester tester, {String? globalUa}) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1000, 1600));
    container
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(globalUa: globalUa, userAgents: _seeded),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: UserAgentsView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submitInput(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(EditableText), text);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  testWidgets('lists the default and the presets, default without a menu', (
    tester,
  ) async {
    await pumpView(tester);

    expect(find.text(currentAppLocalizations.defaultText), findsOneWidget);
    for (final userAgent in _seeded) {
      expect(find.text(userAgent), findsOneWidget);
    }
    expect(
      find.byTooltip(currentAppLocalizations.more),
      findsNWidgets(_seeded.length),
    );
  });

  testWidgets('tapping a row selects it and the default clears it', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.tap(find.text(_second));
    await tester.pumpAndSettle();
    expect(selected(), _second);

    await tester.tap(find.text(currentAppLocalizations.defaultText));
    await tester.pumpAndSettle();
    expect(selected(), isNull);
  });

  testWidgets('adding appends without changing the selection', (tester) async {
    await pumpView(tester);

    await tester.tap(find.text(currentAppLocalizations.add));
    await tester.pumpAndSettle();
    await submitInput(tester, '  CustomUA/1.0  ');

    expect(saved(), [..._seeded, 'CustomUA/1.0']);
    expect(selected(), isNull);
    expect(find.text('CustomUA/1.0'), findsOneWidget);
  });

  testWidgets('adding rejects an empty or duplicate value', (tester) async {
    await pumpView(tester);

    await tester.tap(find.text(currentAppLocalizations.add));
    await tester.pumpAndSettle();
    await submitInput(tester, '   ');
    expect(
      find.text(
        currentAppLocalizations.emptyTip(currentAppLocalizations.userAgent),
      ),
      findsOneWidget,
    );

    await submitInput(tester, defaultUserAgents.first);
    expect(
      find.text(
        currentAppLocalizations.existsTip(currentAppLocalizations.userAgent),
      ),
      findsOneWidget,
    );
    expect(saved(), _seeded);
  });

  testWidgets('editing the selected value keeps it selected', (tester) async {
    await pumpView(tester, globalUa: defaultUserAgents.first);

    await tester.tap(menuOf(defaultUserAgents.first));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.edit));
    await tester.pumpAndSettle();
    await submitInput(tester, 'clash-verge/v3.0.0');

    expect(saved(), ['clash-verge/v3.0.0', _second]);
    expect(selected(), 'clash-verge/v3.0.0');
  });

  testWidgets('deleting the selected value falls back to the default', (
    tester,
  ) async {
    await pumpView(tester, globalUa: _second);

    await tester.tap(menuOf(_second));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(saved(), [defaultUserAgents.first]);
    expect(selected(), isNull);
    expect(find.text(_second), findsNothing);
  });

  testWidgets('shows a selected value that is missing from the list', (
    tester,
  ) async {
    await pumpView(tester, globalUa: 'Legacy/1.0');

    expect(find.text('Legacy/1.0'), findsOneWidget);
    expect(saved(), _seeded);

    await tester.tap(menuOf(defaultUserAgents.first));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(saved(), [_second, 'Legacy/1.0']);
    expect(selected(), 'Legacy/1.0');
  });

  testWidgets('adding types in a row of the list, with no dialog', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.tap(find.text(currentAppLocalizations.add));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(EditableText), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(GroupedInputRow),
        matching: find.text(currentAppLocalizations.userAgent),
      ),
      findsOneWidget,
      reason: 'the row is named',
    );
  });

  testWidgets('Escape drops a row that was being added', (tester) async {
    await pumpView(tester);
    await tester.tap(find.text(currentAppLocalizations.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'Half/1.0');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byType(EditableText), findsNothing);
    expect(saved(), _seeded);
  });

  testWidgets('editing opens the value itself for typing', (tester) async {
    await pumpView(tester);

    await tester.tap(menuOf(defaultUserAgents.first));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.edit));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      defaultUserAgents.first,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byType(EditableText), findsNothing);
    expect(saved(), _seeded);
  });
}
