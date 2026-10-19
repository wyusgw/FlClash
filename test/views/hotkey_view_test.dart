import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/hotkey.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

final _keyA = PhysicalKeyboardKey.keyA.usbHidUsage;
final _keyB = PhysicalKeyboardKey.keyB.usbHidUsage;

ProviderContainer _containerFor(
  WidgetTester tester, {
  List<HotKeyAction> hotKeyActions = const [],
}) {
  const size = Size(1400, 1400);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  // hotKeyActionsProvider is autoDispose: without a live listener the seeded
  // value is discarded before the assertions read it back.
  final subscription = container.listen(
    hotKeyActionsProvider,
    (_, _) {},
    fireImmediately: true,
  );
  addTearDown(subscription.close);
  container.read(hotKeyActionsProvider.notifier).value = hotKeyActions;
  return container;
}

Future<void> _pumpView(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(child: HotKeyView()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _press(
  WidgetTester tester,
  PhysicalKeyboardKey key,
  LogicalKeyboardKey logicalKey, {
  List<(PhysicalKeyboardKey, LogicalKeyboardKey)> holding = const [],
}) async {
  for (final (physical, logical) in holding) {
    await simulateKeyDownEvent(logical, physicalKey: physical);
  }
  await simulateKeyDownEvent(logicalKey, physicalKey: key);
  await tester.pumpAndSettle();
  await simulateKeyUpEvent(logicalKey, physicalKey: key);
  for (final (physical, logical) in holding.reversed) {
    await simulateKeyUpEvent(logical, physicalKey: physical);
  }
  await tester.pumpAndSettle();
}

const _control = (
  PhysicalKeyboardKey.controlLeft,
  LogicalKeyboardKey.controlLeft,
);

Future<void> _pressControlA(WidgetTester tester) {
  return _press(
    tester,
    PhysicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyA,
    holding: const [_control],
  );
}

void main() {
  group('HotKeyView', () {
    testWidgets('lists every action, bound or not', (tester) async {
      final container = _containerFor(
        tester,
        hotKeyActions: [
          HotKeyAction(
            action: HotAction.view,
            key: _keyA,
            modifiers: const {KeyboardModifier.control},
          ),
        ],
      );
      await _pumpView(tester, container);

      for (final action in HotAction.values) {
        await tester.scrollUntilVisible(find.text(action.label), 100);
        expect(find.text(action.label), findsOne, reason: action.name);
      }
      expect(
        find.text(currentAppLocalizations.hotkeyNotSet),
        findsAtLeastNWidgets(1),
      );
      expect(tester.takeException(), null);
    });

    testWidgets('shows a binding as key caps and clears it in place', (
      tester,
    ) async {
      final container = _containerFor(
        tester,
        hotKeyActions: [
          HotKeyAction(
            action: HotAction.view,
            key: _keyA,
            modifiers: const {KeyboardModifier.shift},
          ),
        ],
      );
      await _pumpView(tester, container);

      final labels = ShortcutLabels.host();
      expect(find.text(labels.modifier(KeyboardModifier.shift)), findsOne);
      expect(find.text(labels.key(_keyA)), findsOne);

      await tester.tap(find.byTooltip(currentAppLocalizations.remove));
      await tester.pumpAndSettle();

      expect(container.read(hotKeyActionsProvider), isEmpty);
      expect(find.text(labels.key(_keyA)), findsNothing);
    });

    testWidgets('flags a binding the OS refused', (tester) async {
      final container = _containerFor(
        tester,
        hotKeyActions: [
          HotKeyAction(
            action: HotAction.view,
            key: _keyA,
            modifiers: const {KeyboardModifier.control},
          ),
        ],
      );
      container.read(hotKeyFailuresProvider.notifier).value = {
        HotAction.view: 'already registered',
      };
      await _pumpView(tester, container);

      expect(find.text(currentAppLocalizations.hotkeyUnavailable), findsOne);
      expect(find.byTooltip('already registered'), findsOne);
    });
  });

  group('recording in place', () {
    Future<void> startRecording(WidgetTester tester, HotAction action) async {
      await tester.scrollUntilVisible(find.text(action.label), 100);
      await tester.tap(find.text(action.label));
      await tester.pumpAndSettle();
    }

    testWidgets('tapping an unset row starts recording right there', (
      tester,
    ) async {
      final container = _containerFor(tester);
      await _pumpView(tester, container);

      await startRecording(tester, HotAction.start);

      expect(find.byType(HotKeyView), findsOne);
      expect(find.text(currentAppLocalizations.pressKeyboard), findsOne);
      expect(container.read(hotKeyRecordingProvider), isTrue);
    });

    testWidgets('a held modifier previews until a key completes it', (
      tester,
    ) async {
      final container = _containerFor(tester);
      await _pumpView(tester, container);
      await startRecording(tester, HotAction.start);

      await simulateKeyDownEvent(
        LogicalKeyboardKey.controlLeft,
        physicalKey: PhysicalKeyboardKey.controlLeft,
      );
      await tester.pumpAndSettle();

      expect(
        find.text(ShortcutLabels.host().modifier(KeyboardModifier.control)),
        findsOne,
      );
      expect(find.text('…'), findsOne);
      expect(find.text(currentAppLocalizations.pressKeyboard), findsNothing);

      await simulateKeyUpEvent(
        LogicalKeyboardKey.controlLeft,
        physicalKey: PhysicalKeyboardKey.controlLeft,
      );
      await tester.pumpAndSettle();

      expect(find.text('…'), findsNothing);
      expect(find.text(currentAppLocalizations.pressKeyboard), findsOne);
    });

    testWidgets('a modifier plus key saves at once and stops recording', (
      tester,
    ) async {
      final container = _containerFor(tester);
      await _pumpView(tester, container);
      await startRecording(tester, HotAction.start);

      await _pressControlA(tester);

      final stored = container.read(hotKeyActionsProvider);
      expect(stored, hasLength(1));
      expect(stored.single.action, HotAction.start);
      expect(stored.single.key, _keyA);
      expect(stored.single.modifiers, {KeyboardModifier.control});
      expect(container.read(hotKeyRecordingProvider), isFalse);
      expect(find.text(currentAppLocalizations.pressKeyboard), findsNothing);
      expect(find.text(ShortcutLabels.host().key(_keyA)), findsOne);
    });

    testWidgets('a bare key is refused with a reason and keeps recording', (
      tester,
    ) async {
      final container = _containerFor(tester);
      await _pumpView(tester, container);
      await startRecording(tester, HotAction.start);

      await _press(tester, PhysicalKeyboardKey.keyA, LogicalKeyboardKey.keyA);

      expect(container.read(hotKeyActionsProvider), isEmpty);
      expect(container.read(hotKeyRecordingProvider), isTrue);
      expect(
        find.text(
          currentAppLocalizations.hotkeyNeedsModifier(
            ShortcutLabels.host()
                .modifierParts(primaryHotKeyModifiers)
                .join(ShortcutLabels.host().isMacOS ? ' ' : ', '),
          ),
        ),
        findsOne,
      );
    });

    testWidgets('a taken combination moves from the other action', (
      tester,
    ) async {
      final taken = HotKeyAction(
        action: HotAction.mode,
        key: _keyA,
        modifiers: const {KeyboardModifier.control},
      );
      final container = _containerFor(tester, hotKeyActions: [taken]);
      await _pumpView(tester, container);
      await startRecording(tester, HotAction.start);

      await _pressControlA(tester);

      final stored = container.read(hotKeyActionsProvider);
      expect(stored, hasLength(1));
      expect(stored.single.action, HotAction.start);
    });

    testWidgets('recording over a bound row replaces its combination', (
      tester,
    ) async {
      final existing = HotKeyAction(
        action: HotAction.start,
        key: _keyB,
        modifiers: const {KeyboardModifier.control},
      );
      final container = _containerFor(tester, hotKeyActions: [existing]);
      await _pumpView(tester, container);
      await startRecording(tester, HotAction.start);

      await _pressControlA(tester);

      final stored = container.read(hotKeyActionsProvider);
      expect(stored, hasLength(1), reason: 'replaces rather than appends');
      expect(stored.single.key, _keyA);
    });

    testWidgets('a bare Escape or a second tap cancels without saving', (
      tester,
    ) async {
      final container = _containerFor(tester);
      await _pumpView(tester, container);
      await startRecording(tester, HotAction.start);

      await _press(
        tester,
        PhysicalKeyboardKey.escape,
        LogicalKeyboardKey.escape,
      );

      expect(find.byType(HotKeyView), findsOne);
      expect(find.text(currentAppLocalizations.pressKeyboard), findsNothing);
      expect(container.read(hotKeyRecordingProvider), isFalse);

      await startRecording(tester, HotAction.start);
      await tester.tap(find.text(HotAction.start.label));
      await tester.pumpAndSettle();

      expect(find.text(currentAppLocalizations.pressKeyboard), findsNothing);
      expect(container.read(hotKeyRecordingProvider), isFalse);
      expect(container.read(hotKeyActionsProvider), isEmpty);
    });

    testWidgets('tapping another row moves the recording there', (
      tester,
    ) async {
      final container = _containerFor(tester);
      await _pumpView(tester, container);
      await startRecording(tester, HotAction.start);
      await startRecording(tester, HotAction.view);

      await _pressControlA(tester);

      expect(
        container.read(hotKeyActionsProvider).single.action,
        HotAction.view,
      );
    });

    testWidgets('a recording row hides its remove button until cancelled', (
      tester,
    ) async {
      final existing = HotKeyAction(
        action: HotAction.start,
        key: _keyB,
        modifiers: const {KeyboardModifier.control},
      );
      final container = _containerFor(tester, hotKeyActions: [existing]);
      await _pumpView(tester, container);
      await startRecording(tester, HotAction.start);

      expect(find.byTooltip(currentAppLocalizations.remove), findsNothing);
      await tester.tap(find.text(HotAction.start.label));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(currentAppLocalizations.remove));
      await tester.pumpAndSettle();

      expect(container.read(hotKeyActionsProvider), isEmpty);
    });

    testWidgets('reset puts every default back once confirmed', (tester) async {
      final container = _containerFor(
        tester,
        hotKeyActions: [
          HotKeyAction(
            action: HotAction.exit,
            key: _keyA,
            modifiers: const {KeyboardModifier.shift},
          ),
        ],
      );
      await _pumpView(tester, container);

      await tester.scrollUntilVisible(
        find.text(currentAppLocalizations.resetHotkeys),
        100,
      );
      await tester.tap(find.text(currentAppLocalizations.resetHotkeys));
      await tester.pumpAndSettle();
      expect(container.read(hotKeyActionsProvider), hasLength(1));

      await tester.tap(find.text(currentAppLocalizations.reset));
      await tester.pumpAndSettle();

      expect(container.read(hotKeyActionsProvider), defaultHotKeyActions);
    });

    testWidgets('leaving the page releases the paused hotkeys', (tester) async {
      final container = _containerFor(tester);
      await _pumpView(tester, container);
      await startRecording(tester, HotAction.start);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      expect(container.read(hotKeyRecordingProvider), isFalse);
    });
  });
}
