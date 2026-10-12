import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

Future<List<String>> _pump(
  WidgetTester tester, {
  String value = 'alpha',
  String? hint,
  String? resetValue,
  String? Function(String value)? validator,
  bool startEditing = false,
  List<String>? cancels,
}) async {
  final submitted = <String>[];
  await tester.pumpWidget(
    TestApp(
      child: Scaffold(
        body: Column(
          children: [
            GroupedInputRow(
              title: 'Name',
              value: value,
              hint: hint,
              resetValue: resetValue,
              validator: validator,
              startEditing: startEditing,
              onSubmitted: submitted.add,
              onCancel: () => cancels?.add('cancel'),
            ),
            const SizedBox(height: 40),
            GroupedRow(title: 'Other', onTap: () {}),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return submitted;
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(EditableText), text);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('at rest it is a plain row with its value', (tester) async {
    await _pump(tester);

    expect(find.text('Name'), findsOneWidget);
    expect(find.text('alpha'), findsOneWidget);
    expect(find.byType(EditableText), findsNothing);
  });

  testWidgets('an empty value shows the hint', (tester) async {
    await _pump(tester, value: '', hint: 'Required');

    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('a tap opens the value in the row, with a caret and no box', (
    tester,
  ) async {
    await _pump(tester);
    final before = tester.getSize(find.byType(GroupedInputRow));

    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.byType(Dialog), findsNothing);
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.controller.text, 'alpha');
    expect(editable.focusNode.hasFocus, isTrue);
    expect(editable.controller.selection.baseOffset, 5);
    expect(tester.getSize(find.byType(GroupedInputRow)).height, before.height);
  });

  testWidgets('Enter keeps a changed valid value', (tester) async {
    final submitted = await _pump(tester);
    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();

    await _type(tester, '  beta  ');

    expect(submitted, ['beta']);
    expect(find.byType(EditableText), findsNothing);
  });

  testWidgets('an unchanged value is not reported', (tester) async {
    final cancels = <String>[];
    final submitted = await _pump(tester, cancels: cancels);
    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();

    await _type(tester, 'alpha');

    expect(submitted, isEmpty);
    expect(cancels, ['cancel']);
  });

  testWidgets('a refused value stays open and says why', (tester) async {
    final submitted = await _pump(
      tester,
      validator: (value) => value.isEmpty ? 'Cannot be empty' : null,
    );
    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();

    await _type(tester, '   ');

    expect(find.text('Cannot be empty'), findsOneWidget);
    expect(find.byType(EditableText), findsOneWidget);
    expect(submitted, isEmpty);

    await _type(tester, 'gamma');
    expect(submitted, ['gamma']);
    expect(find.text('Cannot be empty'), findsNothing);
  });

  testWidgets('Escape leaves the value alone', (tester) async {
    final cancels = <String>[];
    final submitted = await _pump(tester, cancels: cancels);
    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'beta');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byType(EditableText), findsNothing);
    expect(submitted, isEmpty);
    expect(cancels, ['cancel']);
  });

  testWidgets('leaving the row keeps a valid value', (tester) async {
    final submitted = await _pump(tester);
    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'delta');

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(submitted, ['delta']);
    expect(find.byType(EditableText), findsNothing);
  });

  testWidgets('leaving the row drops a value that is refused', (tester) async {
    final submitted = await _pump(
      tester,
      validator: (value) => value.isEmpty ? 'Cannot be empty' : null,
    );
    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), '');

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(submitted, isEmpty);
    expect(find.byType(EditableText), findsNothing);
    expect(find.text('alpha'), findsOneWidget);
  });

  testWidgets('startEditing opens the row already being typed in', (
    tester,
  ) async {
    await _pump(tester, value: '', startEditing: true);

    expect(find.byType(EditableText), findsOneWidget);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );
  });

  testWidgets('Reset appears while the text differs and puts it back', (
    tester,
  ) async {
    final submitted = await _pump(tester, value: 'beta', resetValue: 'default');
    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();
    expect(find.text('Reset'), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(submitted, ['default']);
  });

  testWidgets('Reset is not offered when the text already is the default', (
    tester,
  ) async {
    await _pump(tester, value: 'default', resetValue: 'default');
    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();

    expect(find.text('Reset'), findsNothing);
  });

  testWidgets('the row being typed in lights up like a selected one', (
    tester,
  ) async {
    await _pump(tester);
    final palette = GroupedPalette.of(tester.element(find.text('Name')));
    bool lit() => find
        .descendant(
          of: find.byType(GroupedInputRow),
          matching: find.byWidgetPredicate(
            (widget) => widget is ColoredBox && widget.color == palette.hover,
          ),
        )
        .evaluate()
        .isNotEmpty;

    expect(lit(), isFalse);
    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();
    expect(lit(), isTrue);
  });
}
