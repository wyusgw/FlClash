import 'package:code_forge/code_forge.dart';
import 'package:fl_clash/features/features.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

const _style = TextStyle(fontSize: 14);

CodeForgeSuggestionDetails _details(
  List<CodeForgeSuggestion> suggestions, {
  int? selectedIndex,
  ValueChanged<int>? onAccept,
}) => CodeForgeSuggestionDetails(
  suggestions: suggestions,
  selectedIndex: selectedIndex,
  onAccept: onAccept ?? (_) {},
  caretRect: Rect.zero,
);

Widget _host(CodeForgeSuggestionDetails details) => TestApp(
  child: Align(
    alignment: Alignment.topLeft,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 200),
      child: EditorCompletionPopup(details: details, textStyle: _style),
    ),
  ),
);

void main() {
  testWidgets('lists the labels with their details and accepts a tap', (
    tester,
  ) async {
    int? accepted;
    await tester.pumpWidget(
      _host(
        _details(
          const [
            CodeForgeSuggestion(label: 'mixed-port', detail: 'number'),
            CodeForgeSuggestion(label: 'mode'),
          ],
          selectedIndex: 0,
          onAccept: (index) => accepted = index,
        ),
      ),
    );

    expect(find.text('mixed-port'), findsOneWidget);
    expect(find.text('number'), findsOneWidget);

    await tester.tap(find.text('mode'));
    expect(accepted, 1);
  });

  testWidgets('scrolls the highlighted entry into view', (tester) async {
    final suggestions = [
      for (var i = 0; i < 40; i++) CodeForgeSuggestion(label: 'entry-$i'),
    ];
    await tester.pumpWidget(_host(_details(suggestions, selectedIndex: 0)));
    expect(find.text('entry-39'), findsNothing);

    await tester.pumpWidget(_host(_details(suggestions, selectedIndex: 39)));
    await tester.pump();
    await tester.pump();
    expect(find.text('entry-39'), findsOneWidget);

    await tester.pumpWidget(_host(_details(suggestions, selectedIndex: 0)));
    await tester.pump();
    await tester.pump();
    expect(find.text('entry-0'), findsOneWidget);
  });

  testWidgets('drops a detail that no longer fits beside its label', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120, maxHeight: 200),
            child: EditorCompletionPopup(
              details: _details(const [
                CodeForgeSuggestion(
                  label: 'a-rather-long-label',
                  detail: 'detail',
                ),
              ]),
              textStyle: _style,
            ),
          ),
        ),
      ),
    );

    expect(find.text('detail'), findsNothing);
  });
}
