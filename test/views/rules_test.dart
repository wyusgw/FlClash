import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:flutter/gestures.dart' show kSecondaryButton;
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/rules.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _set = RuleSet(
  id: 1,
  label: 'Work',
  rules: [
    {
      'domain': ['domain:example.com', 'domain:example.org'],
      'outboundTag': 'direct',
    },
  ],
);

void main() {
  late ProviderContainer container;

  List<RuleSet> sets() => container.read(ruleSetsProvider);

  Future<void> pumpView(
    WidgetTester tester, {
    Widget page = const RulesView(),
    List<RuleSet> initial = const [_set],
    int? currentId,
  }) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.listen(ruleSetsProvider, (_, _) {});
    container.listen(currentRuleSetIdProvider, (_, _) {});
    container.read(viewSizeProvider.notifier).value = const Size(1000, 1800);
    container.read(ruleSetsProvider.notifier).value = initial;
    container.read(currentRuleSetIdProvider.notifier).value = currentId;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder rowOf(String title) => find.widgetWithText(GroupedRow, title);

  testWidgets('the built-in rules are in use until a set is picked', (
    tester,
  ) async {
    await pumpView(tester);

    expect(
      find.descendant(
        of: rowOf('Built-in rules'),
        matching: find.byGlyph(AppGlyphs.check),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: rowOf('Work'),
        matching: find.textContaining(RegExp(r'^\d+\.\dK$')),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Work'));
    await tester.pump();

    expect(container.read(currentRuleSetIdProvider), 1);
    expect(
      find.descendant(
        of: rowOf('Work'),
        matching: find.byGlyph(AppGlyphs.check),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a rule set lists its rules with where each goes', (
    tester,
  ) async {
    await pumpView(tester, page: const RuleSetView(id: 1));

    expect(find.text('domain:example.com +1'), findsOneWidget);
    expect(find.text('Direct'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pump();

    expect(sets().single.rules, isEmpty);
    expect(find.text('No rules yet'), findsOneWidget);
  });

  testWidgets('a rule written by hand is added to the set', (tester) async {
    await pumpView(tester, page: const AddRuleView(ruleSetId: 1));

    await tester.enterText(find.byType(EditableText), 'a.com, b.com');
    await tester.tap(find.text('Domain keyword'));
    await tester.tap(find.text('Reject'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(sets().single.rules.last, {
      'domain': ['keyword:a.com', 'keyword:b.com'],
      'outboundTag': 'block',
    });
  });

  testWidgets('a rule cannot be saved with no value', (tester) async {
    await pumpView(tester, page: const AddRuleView(ruleSetId: 1));

    await tester.enterText(find.byType(EditableText), ' , ');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(sets().single.rules, hasLength(1));
  });

  testWidgets('a set named with no URL starts empty', (tester) async {
    await pumpView(tester, page: const AddRuleSetView(), initial: const []);

    await tester.enterText(find.byType(EditableText).first, 'Mine');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(sets().single.label, 'Mine');
    expect(sets().single.rules, isEmpty);
    expect(sets().single.url, isNull);
  });

  testWidgets('deleting the set in use goes back to the built-in rules', (
    tester,
  ) async {
    await pumpView(tester, page: const RuleSetView(id: 1), currentId: 1);

    await tester.tap(find.text('Delete config'));
    await tester.pumpAndSettle();

    expect(sets(), isEmpty);
    expect(container.read(currentRuleSetIdProvider), isNull);
  });

  testWidgets('restoring the default config picks the built-in rules', (
    tester,
  ) async {
    await pumpView(tester, currentId: 1);

    await tester.tap(find.text('Restore default config'));
    await tester.pump();

    expect(container.read(currentRuleSetIdProvider), isNull);
  });

  testWidgets('testing a domain names the rule it meets', (tester) async {
    await pumpView(tester, page: const TestRulesView(), currentId: 1);

    await tester.enterText(find.byType(EditableText), 'www.example.org');
    await tester.pump();

    expect(find.text('domain:example.com +1'), findsOneWidget);
    expect(find.text('Direct'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'other.net');
    await tester.pump();

    expect(
      find.text('No rule matches, so it goes through the proxy'),
      findsOneWidget,
    );
  });

  group('the menu of a rule config', () {
    Future<void> openMenu(WidgetTester tester) async {
      await tester.tap(find.text('Work'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
    }

    testWidgets('a right click lists what can be done with it', (tester) async {
      await pumpView(tester);

      await openMenu(tester);

      for (final label in [
        'Rename',
        'Edit config',
        'Edit plain text',
        'Delete config',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('rename takes a new name', (tester) async {
      await pumpView(tester);

      await openMenu(tester);
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Home');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(sets().single.label, 'Home');
    });

    testWidgets('delete drops it and the built-in rules take over', (
      tester,
    ) async {
      await pumpView(tester, currentId: 1);

      await openMenu(tester);
      await tester.tap(find.text('Delete config'));
      await tester.pumpAndSettle();

      expect(sets(), isEmpty);
      expect(container.read(currentRuleSetIdProvider), isNull);
    });

    testWidgets('edit config opens its rules', (tester) async {
      await pumpView(tester);

      await openMenu(tester);
      await tester.tap(find.text('Edit config'));
      await tester.pumpAndSettle();

      expect(find.byType(RuleSetView), findsOneWidget);
    });

    testWidgets('the info button opens its rules too', (tester) async {
      await pumpView(tester);

      await tester.tap(find.byTooltip('Edit').last);
      await tester.pumpAndSettle();

      expect(find.text('Work'), findsWidgets);
      expect(find.byType(RuleSetView), findsOneWidget);
    });
  });

  group('the default config', () {
    testWidgets('has a menu with no delete and an info button', (tester) async {
      await pumpView(tester);

      await tester.tap(find.text('Built-in rules'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();

      expect(find.text('Rename'), findsOneWidget);
      expect(find.text('Edit plain text'), findsOneWidget);
      expect(find.text('Delete config'), findsNothing);
      expect(
        find.descendant(
          of: rowOf('Built-in rules'),
          matching: find.byTooltip('Edit'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('opens on the built-in rules before its first edit', (
      tester,
    ) async {
      await pumpView(tester, page: const RuleSetView(id: defaultRuleSetId));

      expect(find.text('geosite:cn'), findsOneWidget);
      expect(find.text('geoip:cn'), findsOneWidget);
      expect(find.text('Delete config'), findsNothing);
    });

    testWidgets('an edit is kept and becomes the rules in use', (tester) async {
      await pumpView(tester, page: const RuleSetView(id: defaultRuleSetId));

      await tester.tap(find.byTooltip('Delete').first);
      await tester.pump();

      final stored = sets().firstWhere((set) => set.id == defaultRuleSetId);
      expect(stored.rules, hasLength(1));
      expect(container.read(activeRulesProvider), stored.rules);
    });

    testWidgets('restoring it puts the built-in rules back', (tester) async {
      await pumpView(
        tester,
        initial: const [
          RuleSet(id: defaultRuleSetId, label: 'Mine', rules: []),
          _set,
        ],
        currentId: 1,
      );

      await tester.tap(find.text('Restore default config'));
      await tester.pump();

      final stored = sets().firstWhere((set) => set.id == defaultRuleSetId);
      expect(stored.rules, builtInRules);
      expect(container.read(currentRuleSetIdProvider), isNull);
    });
  });
}
