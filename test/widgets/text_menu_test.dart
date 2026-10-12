import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart' show kSecondaryMouseButton;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_window_port.dart';
import '../helpers/test_app.dart';

void main() {
  late FakeWindowPort window;
  late TextEditingController controller;

  setUp(() {
    window = FakeWindowPort.choosing('paste');
    windowPort = window;
    controller = TextEditingController();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          switch (call.method) {
            case 'Clipboard.hasStrings':
              return <String, Object?>{'value': true};
            case 'Clipboard.getData':
              return <String, Object?>{'text': 'https://example.com/sub'};
          }
          return null;
        });
  });

  tearDown(() {
    windowPort = null;
    controller.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> rightClickField(WidgetTester tester, Widget field) async {
    await tester.pumpWidget(TestApp(child: Scaffold(body: field)));
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField), buttons: kSecondaryMouseButton);
    await tester.pumpAndSettle();
  }

  testWidgets('a settings field pastes through the system menu', (
    tester,
  ) async {
    await rightClickField(
      tester,
      GroupedFieldRow(label: 'URL', hint: 'Required', controller: controller),
    );

    expect(window.requests, hasLength(1));
    expect(controller.text, 'https://example.com/sub');
    expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('a search field pastes through the system menu', (tester) async {
    await rightClickField(
      tester,
      GroupedSearchField(
        controller: controller,
        hint: 'Search',
        clearTooltip: 'Clear',
      ),
    );

    expect(window.requests, hasLength(1));
    expect(controller.text, 'https://example.com/sub');
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('with nothing to cut, copy or paste no menu is popped', (
    tester,
  ) async {
    windowPort = FakeWindowPort();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.hasStrings') {
            return <String, Object?>{'value': false};
          }
          return null;
        });
    final empty = windowPort! as FakeWindowPort;

    await rightClickField(
      tester,
      GroupedFieldRow(label: 'URL', hint: 'Required', controller: controller),
    );

    expect(empty.requests, isEmpty);
    expect(find.byType(EditableText), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
