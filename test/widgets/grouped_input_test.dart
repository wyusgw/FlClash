import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart' show kSecondaryMouseButton;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_window_port.dart';
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

  group('the system menu', () {
    late FakeWindowPort window;

    void useWindow({String? choosing, Exception? error}) {
      window = choosing == null
          ? FakeWindowPort(error: error)
          : FakeWindowPort.choosing(choosing, error: error);
      windowPort = window;
    }

    setUp(() {
      useWindow();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            switch (call.method) {
              case 'Clipboard.hasStrings':
                return <String, Object?>{'value': true};
              case 'Clipboard.getData':
                return <String, Object?>{'text': 'pasted'};
            }
            return null;
          });
    });

    tearDown(() {
      windowPort = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    Future<void> rightClick(WidgetTester tester) async {
      await _pump(tester);
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byType(EditableText),
        buttons: kSecondaryMouseButton,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a right click pops the system menu, not a drawn one', (
      tester,
    ) async {
      await rightClick(tester);

      final request = window.requests.single;
      expect(request.items.map((item) => item.id), [
        'cut',
        'copy',
        'paste',
        'select-all',
      ]);
      expect(request.items.map((item) => item.label), contains('Paste'));
      expect(request.position.dx, greaterThan(0));
      expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);
      expect(find.byType(TextSelectionToolbar), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('choosing Paste puts the clipboard text into the row', (
      tester,
    ) async {
      useWindow(choosing: 'paste');

      await rightClick(tester);

      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        contains('pasted'),
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('dismissing the menu changes nothing', (tester) async {
      await rightClick(tester);

      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'alpha',
      );
      expect(find.byType(EditableText), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    for (final platform in [TargetPlatform.windows, TargetPlatform.linux]) {
      testWidgets('${platform.name} pops its native menu too', (tester) async {
        useWindow(choosing: 'paste');

        await rightClick(tester);

        expect(window.requests, hasLength(1));
        expect(
          tester
              .widget<EditableText>(find.byType(EditableText))
              .controller
              .text,
          contains('pasted'),
        );
      }, variant: TargetPlatformVariant.only(platform));
    }

    testWidgets('a clipboard that answers late still gets its Paste', (
      tester,
    ) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            switch (call.method) {
              case 'Clipboard.hasStrings':
                await Future<void>.delayed(const Duration(milliseconds: 200));
                return <String, Object?>{'value': true};
              case 'Clipboard.getData':
                return <String, Object?>{'text': 'pasted'};
            }
            return null;
          });

      await rightClick(tester);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(window.requests, hasLength(1));
      expect(
        window.requests.single.items.map((item) => item.id),
        contains('paste'),
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    bool enabled(String id) =>
        window.requests.last.items.singleWhere((item) => item.id == id).enabled;

    testWidgets('a word under the pointer enables Cut and Copy beside Paste', (
      tester,
    ) async {
      await rightClick(tester);

      expect(enabled('cut'), isTrue);
      expect(enabled('copy'), isTrue);
      expect(enabled('paste'), isTrue);
      expect(
        enabled('select-all'),
        isFalse,
        reason: 'the one word is already all there is',
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('with more text than the selection Select All is enabled', (
      tester,
    ) async {
      await _pump(tester, value: 'alpha beta gamma');
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      await tester.tapAt(
        tester.getCenter(find.byType(EditableText)),
        buttons: kSecondaryMouseButton,
      );
      await tester.pumpAndSettle();

      expect(window.requests, hasLength(1));
      expect(enabled('select-all'), isTrue);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('Cut and Copy are listed but greyed with nothing selected', (
      tester,
    ) async {
      await _pump(tester, value: '', startEditing: true);
      await tester.tap(find.byType(EditableText));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byType(EditableText),
        buttons: kSecondaryMouseButton,
      );
      await tester.pumpAndSettle();

      expect(window.requests, hasLength(1));
      expect(enabled('cut'), isFalse);
      expect(enabled('copy'), isFalse);
      expect(enabled('paste'), isTrue);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('the Speech entry is given the selection to read', (
      tester,
    ) async {
      await rightClick(tester);

      expect(window.requests.single.speech, 'alpha');
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('a window that is missing the call falls back to the toolbar', (
      tester,
    ) async {
      useWindow(error: MissingPluginException('showTextMenu'));

      await rightClick(tester);

      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
      expect(find.text('Paste'), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('a window that fails the call falls back to the toolbar', (
      tester,
    ) async {
      useWindow(error: PlatformException(code: 'unsupported'));

      await rightClick(tester);

      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('a phone keeps the toolbar of its platform', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byType(EditableText),
        buttons: kSecondaryMouseButton,
      );
      await tester.pumpAndSettle();

      expect(window.requests, isEmpty);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets('without a window to ask the drawn toolbar stands in', (
      tester,
    ) async {
      windowPort = null;

      await rightClick(tester);

      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
  });
}
