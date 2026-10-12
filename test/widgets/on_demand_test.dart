import 'dart:async';

import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/on_demand.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

class _TestExcludeSSIDs extends ExcludeSSIDs {
  _TestExcludeSSIDs(this._initial);

  final List<String> _initial;

  @override
  List<String> build() => _initial;
}

class _TestLocationPermissions extends LocationPermissions {
  _TestLocationPermissions(this._initial);

  final WifiSsidPermission _initial;

  @override
  WifiSsidPermission build() => _initial;
}

void main() {
  late ProviderContainer container;

  Future<void> pumpView(
    WidgetTester tester, {
    List<String> ssids = const [],
    WifiSsidPermission permission = WifiSsidPermission.denied,
    bool isAndroid = false,
    bool isMacOS = false,
    bool isStart = false,
    Locale? locale,
    Size size = const Size(1400, 1000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer(
      overrides: [
        excludeSSIDsProvider.overrideWith(() => _TestExcludeSSIDs(ssids)),
        locationPermissionsProvider.overrideWith(
          () => _TestLocationPermissions(permission),
        ),
        isStartProvider.overrideWithValue(isStart),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          locale: locale,
          child: OnDemandView(isAndroid: isAndroid, isMacOS: isMacOS),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an empty list shows the placeholder and only the add action', (
    tester,
  ) async {
    await pumpView(tester);

    expect(find.text('SSIDs are empty'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Select all'), findsNothing);
    expect(find.byGlyph(AppGlyphs.delete), findsNothing);
  });

  testWidgets('every excluded SSID is rendered', (tester) async {
    await pumpView(tester, ssids: ['Home', 'Office']);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Office'), findsOneWidget);
    expect(find.text('SSIDs are empty'), findsNothing);
  });

  group('typing an SSID in its row', () {
    Future<void> type(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(EditableText), text);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    testWidgets('adding opens a row for typing and keeps what is typed', (
      tester,
    ) async {
      await pumpView(tester, ssids: ['Home']);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(EditableText), findsOneWidget);

      await type(tester, 'Office');

      expect(container.read(excludeSSIDsProvider), ['Home', 'Office']);
      expect(find.byType(EditableText), findsNothing);
      expect(find.text('Office'), findsOneWidget);
    });

    testWidgets('the first SSID can be typed where the placeholder was', (
      tester,
    ) async {
      await pumpView(tester);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('SSIDs are empty'), findsNothing);
      await type(tester, 'Cafe');
      expect(container.read(excludeSSIDsProvider), ['Cafe']);
    });

    testWidgets('an empty or taken name is refused with a reason', (
      tester,
    ) async {
      await pumpView(tester, ssids: ['Home']);
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      await type(tester, '  ');
      expect(
        find.text(AppLocalizations.current.emptyTip('SSID').trim()),
        findsOneWidget,
      );

      await type(tester, 'Home');
      expect(
        find.text(AppLocalizations.current.existsTip('SSID').trim()),
        findsOneWidget,
      );
      expect(container.read(excludeSSIDsProvider), ['Home']);
      expect(find.byType(EditableText), findsOneWidget);
    });

    testWidgets('tapping a name edits it in place and keeps its position', (
      tester,
    ) async {
      await pumpView(tester, ssids: ['Home', 'Office', 'Cafe']);

      await tester.tap(find.text('Office'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'Office',
      );

      await type(tester, 'Work');

      expect(container.read(excludeSSIDsProvider), ['Home', 'Work', 'Cafe']);
    });

    testWidgets('Escape leaves the list as it was', (tester) async {
      await pumpView(tester, ssids: ['Home']);
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'Half');

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(EditableText), findsNothing);
      expect(container.read(excludeSSIDsProvider), ['Home']);
    });
  });

  testWidgets('selecting an item swaps the header into selection mode', (
    tester,
  ) async {
    await pumpView(tester, ssids: ['Home', 'Office']);
    expect(find.byGlyph(AppGlyphs.delete), findsNothing);

    await tester.tap(find.byType(GroupedSelectMark).first);
    await tester.pumpAndSettle();

    expect(find.byGlyph(AppGlyphs.delete), findsOneWidget);
    expect(find.text('Select all'), findsOneWidget);
    expect(find.text('Add'), findsNothing);
  });

  testWidgets('select all takes every SSID, and pressing it again clears', (
    tester,
  ) async {
    await pumpView(tester, ssids: ['Home', 'Office']);
    await tester.tap(find.byType(GroupedSelectMark).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();
    expect(container.read(itemsProvider(_viewKey(tester))), {'Home', 'Office'});

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();
    expect(find.text('Add'), findsOneWidget, reason: 'selection was cleared');
  });

  testWidgets('deleting removes the selected SSIDs and clears the selection', (
    tester,
  ) async {
    await pumpView(tester, ssids: ['Home', 'Office']);
    await tester.tap(find.byType(GroupedSelectMark).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byGlyph(AppGlyphs.delete));
    await tester.pumpAndSettle();

    expect(container.read(excludeSSIDsProvider), ['Office']);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Add'), findsOneWidget, reason: 'selection was cleared');
  });

  testWidgets('the location prerequisite reflects a denied permission', (
    tester,
  ) async {
    await pumpView(
      tester,
      permission: WifiSsidPermission.denied,
      isMacOS: true,
    );

    expect(find.text('Tap to authorize'), findsOneWidget);
    expect(find.text('Authorized'), findsNothing);
  });

  testWidgets('the location prerequisite reflects a granted permission', (
    tester,
  ) async {
    await pumpView(
      tester,
      permission: WifiSsidPermission.granted,
      isMacOS: true,
    );

    expect(find.text('Authorized'), findsOneWidget);
    expect(find.text('Tap to authorize'), findsNothing);
  });

  testWidgets('a refused location request leaves the permission as it was', (
    tester,
  ) async {
    const channel = MethodChannel('wifi_ssid');
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: 'IN_PROGRESS'),
    );
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await pumpView(tester, isMacOS: true);

    await tester.tap(find.text('Tap to authorize'));
    await tester.pumpAndSettle();

    expect(
      container.read(locationPermissionsProvider),
      WifiSsidPermission.denied,
    );
    expect(find.text('Tap to authorize'), findsOneWidget);
  });

  testWidgets('a second tap while the location request waits asks only once', (
    tester,
  ) async {
    const channel = MethodChannel('wifi_ssid');
    final messenger = tester.binding.defaultBinaryMessenger;
    final answer = Completer<Object?>();
    var requests = 0;
    messenger.setMockMethodCallHandler(channel, (_) {
      requests++;
      return answer.future;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await pumpView(tester, isMacOS: true);
    container.read(viewSizeProvider.notifier).value = const Size(1400, 1000);

    await tester.tap(find.text('Tap to authorize'));
    await tester.pump();
    await tester.tap(find.text('Tap to authorize'));
    await tester.pump();
    answer.complete(WifiSsidPermission.permanentlyDenied.index);
    await tester.pumpAndSettle();

    expect(requests, 1);
    expect(find.text('Location permission required'), findsOneWidget);
  });

  testWidgets('Android also asks to be left out of battery optimization', (
    tester,
  ) async {
    await pumpView(tester, isAndroid: true);

    expect(find.text('Ignore battery optimization'), findsOneWidget);
    expect(find.text('Location permission'), findsOneWidget);
  });

  testWidgets('while running the battery item explains instead of asking', (
    tester,
  ) async {
    await pumpView(tester, isAndroid: true, isStart: true);
    container.read(viewSizeProvider.notifier).value = const Size(1400, 1000);

    final appLocalizations = AppLocalizations.of(
      tester.element(find.byType(OnDemandView)),
    );
    expect(
      find.descendant(
        of: find.widgetWithText(
          GroupedRow,
          appLocalizations.ignoreBatteryOptimization,
        ),
        matching: find.text(appLocalizations.tapToAuthorize),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip(appLocalizations.tip));
    await tester.pumpAndSettle();

    expect(
      find.text(appLocalizations.batteryOptimizationStatusTip),
      findsOneWidget,
    );
  });

  testWidgets('the explanation sits under the authorize row', (tester) async {
    await pumpView(tester, isMacOS: true, locale: const Locale('ru'));

    final appLocalizations = AppLocalizations.of(
      tester.element(find.byType(OnDemandView)),
    );
    final desc = find.text(appLocalizations.locationPermissionDesc);
    final row = find.widgetWithText(
      GroupedRow,
      appLocalizations.locationPermission,
    );

    expect(desc, findsOneWidget);
    expect(
      tester.getTopLeft(desc).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(row).dy),
    );
  });

  testWidgets('a desktop that is not macOS asks for no prerequisite', (
    tester,
  ) async {
    await pumpView(tester);

    expect(find.text('Ignore battery optimization'), findsNothing);
    expect(find.text('Location permission'), findsNothing);
    expect(find.text('Tap to authorize'), findsNothing);
  });
}

/// The view keys its shared selection notifier by [UniqueKeyStateMixin.key], so
/// a test has to read the same id off the mounted state.
String _viewKey(WidgetTester tester) {
  final state = tester.state(find.byType(OnDemandView)) as dynamic;
  return state.key as String;
}
