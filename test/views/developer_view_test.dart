import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:fl_clash/views/developer.dart';
import 'package:fl_clash/widgets/null_status.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

ProviderContainer _containerFor(WidgetTester tester) {
  const size = Size(1400, 1000);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  return container;
}

Future<void> _pumpDeveloperView(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(child: DeveloperView()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    // canCrashCore reads appEnv, which only the real app bootstrap populates.
    // 'dev' also enables the crash-test row.
    globalState.appEnv = 'dev';
    globalState.packageInfo = PackageInfo(
      appName: 'FlClash',
      packageName: 'app.fl_clash',
      version: '1.2.3',
      buildNumber: '45',
    );
  });

  testWidgets('toggles developer mode through the header switch', (
    tester,
  ) async {
    final container = _containerFor(tester);
    await _pumpDeveloperView(tester, container);

    final initial = container.read(appSettingProvider).developerMode;
    await tester.tap(find.byType(GroupedSwitch));
    await tester.pumpAndSettle();

    expect(container.read(appSettingProvider).developerMode, !initial);
    expect(tester.takeException(), null);
  });

  testWidgets('logs test fills the log buffer', (tester) async {
    final container = _containerFor(tester);
    await _pumpDeveloperView(tester, container);

    expect(container.read(logsProvider).list, isEmpty);

    await tester.tap(find.text(currentAppLocalizations.logsTest));
    await tester.pumpAndSettle();

    expect(container.read(logsProvider).list, isNotEmpty);
    expect(tester.takeException(), null);
  });

  testWidgets('clear data asks for confirmation and aborts on cancel', (
    tester,
  ) async {
    final container = _containerFor(tester);
    await _pumpDeveloperView(tester, container);

    await tester.tap(find.text(currentAppLocalizations.clearData));
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.confirmClearAllData), findsOne);

    await tester.tap(find.text(currentAppLocalizations.cancel));
    await tester.pumpAndSettle();

    expect(
      find.text(currentAppLocalizations.confirmClearAllData),
      findsNothing,
    );
    expect(tester.takeException(), null);
  });

  testWidgets('message test surfaces a notification', (tester) async {
    final container = _containerFor(tester);
    await _pumpDeveloperView(tester, container);

    await tester.tap(find.text(currentAppLocalizations.messageTest));
    await tester.pumpAndSettle();

    expect(tester.takeException(), null);
  });

  testWidgets('dialog test opens a dialog that closes on confirm', (
    tester,
  ) async {
    final container = _containerFor(tester);
    await _pumpDeveloperView(tester, container);

    await tester.tap(find.text(currentAppLocalizations.dialogTest));
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.dialogTestTip), findsOneWidget);

    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.dialogTestTip), findsNothing);
    expect(tester.takeException(), null);
  });

  testWidgets('haptic test fires a tick, then a knock', (tester) async {
    final container = _containerFor(tester);
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          calls.add(call.arguments as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _pumpDeveloperView(tester, container);

    await tester.tap(find.text(currentAppLocalizations.hapticTest));
    await tester.pump();
    expect(calls, ['HapticFeedbackType.selectionClick']);

    await tester.pump(const Duration(milliseconds: 500));
    expect(calls, [
      'HapticFeedbackType.selectionClick',
      'HapticFeedbackType.heavyImpact',
    ]);
    expect(tester.takeException(), null);
  });

  testWidgets('empty states page shows every illustration', (tester) async {
    final container = _containerFor(tester);
    await _pumpDeveloperView(tester, container);

    await tester.tap(find.text(currentAppLocalizations.emptyStatesTest));
    await tester.pumpAndSettle();

    expect(find.byType(EmptyStatesView), findsOneWidget);
    for (final type in NullStatusIllustration.values) {
      expect(find.byKey(ValueKey(type)), findsOneWidget, reason: type.name);
    }
    expect(tester.takeException(), null);
  });

  testWidgets('copy diagnostics puts the build details on the clipboard', (
    tester,
  ) async {
    final container = _containerFor(tester);
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _pumpDeveloperView(tester, container);

    await tester.tap(find.text(currentAppLocalizations.copyDiagnostics));
    await tester.pumpAndSettle();

    expect(copied, contains('FlClash 1.2.3 (45)'));
    expect(copied, contains('env: debug'));
    expect(copied, contains('platform: '));
    expect(tester.takeException(), null);
  });
}
