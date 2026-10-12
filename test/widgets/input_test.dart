import 'dart:ui' as ui;

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

final _viewSizeOverride = viewSizeProvider.overrideWithBuild(
  (_, _) => const Size(1200, 1000),
);

void main() {
  testWidgets('ListItem.toggle toggles when tapping the row', (tester) async {
    bool? changedValue;

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Scaffold(
          body: ListItem.toggle(
            title: const Text('Enabled'),
            value: false,
            onChanged: (value) {
              changedValue = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Enabled'));

    expect(changedValue, isTrue);
  });

  testWidgets('ListItem.toggle is disabled without onChanged', (tester) async {
    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Scaffold(
          body: ListItem.toggle(title: const Text('Disabled'), value: false),
        ),
      ),
    );

    final tile = tester.widget<ListTile>(find.byType(ListTile));
    final control = tester.widget<Switch>(find.byType(Switch));

    expect(tile.onTap, isNull);
    expect(control.onChanged, isNull);

    await tester.tap(find.text('Disabled'));
    await tester.pump();
  });

  testWidgets('ListItem takes the grouped card inside a V3 section', (
    tester,
  ) async {
    bool? changedValue;

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Scaffold(
          body: generateSectionV3(
            items: [
              ListItem.toggle(
                title: const Text('Grouped'),
                value: false,
                onChanged: (value) {
                  changedValue = value;
                },
              ),
              ListItem.open(
                title: const Text('Opens'),
                widget: const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );

    ItemPosition positionOf(String text) => tester
        .widget<ItemPositionProvider>(
          find
              .ancestor(
                of: find.text(text),
                matching: find.byType(ItemPositionProvider),
              )
              .first,
        )
        .position;

    expect(find.byType(DecorationListItem), findsNWidgets(2));
    expect(positionOf('Grouped'), ItemPosition.start);
    expect(positionOf('Opens'), ItemPosition.end);

    await tester.tap(find.text('Grouped'));

    expect(changedValue, isTrue);
  });

  testWidgets('ListItem.checkbox toggles when tapping the row', (tester) async {
    bool? changedValue;

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Scaffold(
          body: ListItem.checkbox(
            title: const Text('Selected'),
            onChanged: (value) {
              changedValue = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Selected'));

    expect(changedValue, isTrue);
  });

  testWidgets('ListItem.input limits dialog text by maxLength', (tester) async {
    String? changedValue;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => const Size(1200, 1000)),
        ],
        child: TestApp(
          overrides: [
            viewSizeProvider.overrideWithBuild(
              (_, _) => const Size(1200, 1000),
            ),
          ],
          child: Scaffold(
            body: ListItem.input(
              title: const Text('Port'),
              dialogTitle: 'Port',
              value: '',
              maxLength: 5,
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Port'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '123456789');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(changedValue, '12345');
  });

  testWidgets('ListEditView reorders using final insertion index', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: TestApp(
          overrides: [
            viewSizeProvider.overrideWithBuild(
              (_, _) => const Size(1200, 1000),
            ),
          ],
          child: const ListEditView(
            title: 'Items',
            items: ['a', 'b', 'c'],
            titleBuilder: _textBuilder,
          ),
        ),
      ),
    );

    final listView = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );

    listView.onReorderItem!(0, 2);
    await tester.pump();

    expect(_top(tester, 'b'), lessThan(_top(tester, 'c')));
    expect(_top(tester, 'c'), lessThan(_top(tester, 'a')));
  });

  testWidgets('ListItem.options keeps a null option apart from dismissal', (
    tester,
  ) async {
    final changes = <String?>[];

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Scaffold(
          body: ListItem<String?>.options(
            title: const Text('Language'),
            dialogTitle: 'Language',
            options: const [null, 'en'],
            value: 'en',
            textBuilder: (value) => value ?? 'Default',
            onChanged: changes.add,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('Default'), findsNothing);
    expect(changes, isEmpty);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();

    expect(changes, [null]);
  });

  testWidgets('OptionsDialog returns the tapped option', (tester) async {
    String? selected;

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Builder(
          builder: (context) {
            return FilledButton(
              onPressed: () async {
                selected = await showDialog<String>(
                  context: context,
                  builder: (_) => const OptionsDialog<String>(
                    title: 'Options',
                    options: ['One', 'Two'],
                    value: 'One',
                    textBuilder: _optionText,
                  ),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();

    expect(selected, 'Two');
  });

  testWidgets('OptionsDialog cancel closes without a value', (tester) async {
    String? selected = 'unset';

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Builder(
          builder: (context) {
            return FilledButton(
              onPressed: () async {
                selected = await showDialog<String>(
                  context: context,
                  builder: (_) => const OptionsDialog<String>(
                    title: 'Options',
                    options: ['One', 'Two'],
                    value: 'One',
                    textBuilder: _optionText,
                  ),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(OptionsDialog<String>), findsNothing);
    expect(selected, isNull);
  });

  testWidgets('InputDialog validates, submits, and resets values', (
    tester,
  ) async {
    String? result;

    await tester.pumpWidget(
      TestApp(
        overrides: [_viewSizeOverride],
        child: Builder(
          builder: (context) {
            return FilledButton(
              onPressed: () async {
                result = await showDialog<String>(
                  context: context,
                  builder: (_) => InputDialog(
                    title: 'Value',
                    value: 'changed',
                    resetValue: 'default',
                    labelText: 'Value',
                    suffixText: 'unit',
                    hintText: 'hint',
                    validator: (value) => value == 'valid' ? null : 'Invalid',
                  ),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(find.text('Invalid'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'valid');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(result, 'valid');

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(result, 'default');
  });

  group('ListEditView typed in its rows', () {
    Future<void> pumpList(
      WidgetTester tester, {
      List<String> items = const ['a', 'b'],
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TestApp(
            overrides: [
              viewSizeProvider.overrideWithBuild(
                (_, _) => const Size(1200, 1000),
              ),
            ],
            child: ListEditView(
              title: 'Items',
              items: items,
              titleBuilder: _textBuilder,
              subtitleBuilder: _textBuilder,
              leadingBuilder: _textBuilder,
              itemMaxLength: 4,
            ),
          ),
        ),
      );
    }

    Future<void> type(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(EditableText), text);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    testWidgets('adds, edits, selects, and deletes items', (tester) async {
      await pumpList(tester);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(TextField), findsNothing);
      await type(tester, 'c');
      expect(find.text('c'), findsNWidgets(3));

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await type(tester, 'a');
      expect(find.text('Value already exists'), findsOneWidget);

      await type(tester, ' x ');
      expect(find.text('x'), findsNWidgets(3));

      await tester.tap(find.text('c').first);
      await tester.pumpAndSettle();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'c',
      );
      await type(tester, 'd');
      expect(find.text('d'), findsNWidgets(3));

      await tester.tap(find.byType(GroupedSelectMark).first);
      await tester.pump();
      expect(find.byGlyph(AppGlyphs.delete), findsOneWidget);
      await tester.tap(find.text('Select all'));
      await tester.pump();
      await tester.tap(find.byGlyph(AppGlyphs.delete));
      await tester.pump();
      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('an edit takes one value only and not one already there', (
      tester,
    ) async {
      await pumpList(tester);

      await tester.tap(find.text('a').first);
      await tester.pumpAndSettle();
      await type(tester, 'x, y');
      expect(find.text('Value must be a single item'), findsOneWidget);

      await type(tester, 'b');
      expect(find.text('Value already exists'), findsOneWidget);

      await type(tester, 'z');
      expect(find.text('z'), findsNWidgets(3));
      expect(find.text('a'), findsNothing);
    });

    testWidgets('an add may be several values apart by commas or lines', (
      tester,
    ) async {
      await pumpList(tester, items: ['a']);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await type(tester, 'a, x, y');

      expect(find.byType(EditableText), findsNothing);
      expect(find.text('a'), findsNWidgets(3), reason: 'not added twice');
      expect(find.text('x'), findsNWidgets(3));
      expect(find.text('y'), findsNWidgets(3));
    });

    testWidgets('a value that is too long is refused with its limit', (
      tester,
    ) async {
      await pumpList(tester, items: ['a']);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'toolong');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.byType(EditableText), findsOneWidget, reason: 'stays open');
      expect(find.text('Value must be at most 4 characters'), findsOneWidget);
    });

    testWidgets('the first value can be typed where the placeholder was', (
      tester,
    ) async {
      await pumpList(tester, items: const []);
      expect(find.text('No data'), findsOneWidget);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('No data'), findsNothing);
      await type(tester, 'q');
      expect(find.text('q'), findsNWidgets(3));
    });

    testWidgets('Escape drops a row that was being added', (tester) async {
      await pumpList(tester);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'half');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(EditableText), findsNothing);
      expect(find.text('half'), findsNothing);
    });
  });

  test('NoInputBorder implements border geometry and interior painting', () {
    const border = NoInputBorder();
    const rect = Rect.fromLTWH(1, 2, 30, 40);

    expect(border.copyWith(), isA<NoInputBorder>());
    expect(border.scale(2), isA<NoInputBorder>());
    expect(border.isOutline, isFalse);
    expect(border.dimensions, EdgeInsets.zero);
    expect(border.preferPaintInterior, isTrue);
    expect(border.getInnerPath(rect).getBounds(), rect);
    expect(border.getOuterPath(rect).getBounds(), rect);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    border.paintInterior(canvas, rect, Paint()..color = Colors.red);
    border.paint(canvas, rect);
    recorder.endRecording();
  });
}

String _optionText(String value) => value;

Widget _textBuilder(String value) {
  return Text(value);
}

double _top(WidgetTester tester, String text) {
  return tester.getTopLeft(find.text(text)).dy;
}
