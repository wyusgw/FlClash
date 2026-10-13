import 'package:fl_clash/widgets/swipe_actions.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> pressed;

  setUp(() => pressed = []);

  SwipeAction action(String label) => SwipeAction(
    label: label,
    color: swipeActionNeutral,
    onPressed: () => pressed.add(label),
  );

  Future<void> pump(WidgetTester tester, {bool enabled = true}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              for (final row in ['one', 'two'])
                SwipeActions(
                  enabled: enabled,
                  leading: [action('$row test'), action('$row copy')],
                  trailing: [action('$row qr'), action('$row delete')],
                  child: ListTile(
                    title: Text(row),
                    onTap: () => pressed.add('$row tap'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('dragging right shows the leading buttons', (tester) async {
    await pump(tester);

    expect(find.text('one test'), findsNothing);
    await tester.drag(find.text('one'), const Offset(200, 0));
    await tester.pumpAndSettle();

    expect(find.text('one test'), findsOneWidget);
    expect(find.text('one copy'), findsOneWidget);
    expect(find.text('one qr'), findsNothing);
  });

  testWidgets('dragging left shows the trailing buttons', (tester) async {
    await pump(tester);

    await tester.drag(find.text('one'), const Offset(-200, 0));
    await tester.pumpAndSettle();

    expect(find.text('one qr'), findsOneWidget);
    expect(find.text('one delete'), findsOneWidget);
    expect(find.text('one test'), findsNothing);
  });

  testWidgets('a short drag springs back shut', (tester) async {
    await pump(tester);

    await tester.timedDrag(
      find.text('one'),
      const Offset(-20, 0),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();

    expect(find.text('one qr'), findsNothing);
  });

  testWidgets('a button runs and closes the row', (tester) async {
    await pump(tester);
    await tester.drag(find.text('one'), const Offset(-200, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('one delete'));
    await tester.pumpAndSettle();

    expect(pressed, ['one delete']);
    expect(find.text('one delete'), findsNothing);
  });

  testWidgets('a tap on an open row only closes it', (tester) async {
    await pump(tester);
    await tester.drag(find.text('one'), const Offset(200, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('one'));
    await tester.pumpAndSettle();

    expect(pressed, isEmpty);
    expect(find.text('one test'), findsNothing);

    await tester.tap(find.text('one'));
    expect(pressed, ['one tap']);
  });

  testWidgets('opening a row closes the one left open', (tester) async {
    await pump(tester);
    await tester.drag(find.text('one'), const Offset(200, 0));
    await tester.pumpAndSettle();

    await tester.drag(find.text('two'), const Offset(-200, 0));
    await tester.pumpAndSettle();

    expect(find.text('one test'), findsNothing);
    expect(find.text('two qr'), findsOneWidget);
  });

  testWidgets('a disabled row does not move', (tester) async {
    await pump(tester, enabled: false);

    await tester.drag(find.text('one'), const Offset(200, 0));
    await tester.pumpAndSettle();

    expect(find.text('one test'), findsNothing);
  });
}
