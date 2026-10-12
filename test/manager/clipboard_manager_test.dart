import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/clipboard_manager.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

const _subscription = 'https://example.com/sub?token=1';
const _node = 'trojan://secret@example.org:443#Osaka';

class _RecordingProfilesAction extends ProfilesAction {
  static final imported = <ClipboardImport>[];

  @override
  Future<void> importFromClipboard(ClipboardImport source) async {
    imported.add(source);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  String? clipboard;

  setUp(() {
    clipboard = null;
    _RecordingProfilesAction.imported.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.getData') {
            final text = clipboard;
            return text == null ? null : <String, Object?>{'text': text};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> pump(
    WidgetTester tester, {
    bool enabled = true,
    bool visible = true,
  }) async {
    container = ProviderContainer(
      overrides: [
        profilesActionProvider.overrideWith(_RecordingProfilesAction.new),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.listen(appSettingProvider, (_, _) {});
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(clipboardDetection: enabled));
    container.read(appVisibleProvider.notifier).value = visible;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ClipboardManager(child: SizedBox())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a subscription address on the clipboard is offered at launch', (
    tester,
  ) async {
    clipboard = _subscription;

    await pump(tester);

    expect(find.byType(ConfirmDialog), findsOneWidget);
    expect(
      find.textContaining(_subscription, findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.text(AppLocalizations.current.confirm).last);
    await tester.pumpAndSettle();

    final imported = _RecordingProfilesAction.imported.single;
    expect((imported as ClipboardSubscription).url, _subscription);
  });

  testWidgets('node links are offered with their count', (tester) async {
    clipboard = '$_node\n$_node';

    await pump(tester);

    expect(
      find.text(AppLocalizations.current.importNodesFromClipboardTip(2)),
      findsOneWidget,
    );

    await tester.tap(find.text(AppLocalizations.current.confirm).last);
    await tester.pumpAndSettle();

    expect(
      (_RecordingProfilesAction.imported.single as ClipboardNodes).outbounds,
      hasLength(2),
    );
  });

  testWidgets(
    'declining imports nothing and the same copy is not asked again',
    (tester) async {
      clipboard = _subscription;
      await pump(tester);

      await tester.tap(find.text(AppLocalizations.current.cancel));
      await tester.pumpAndSettle();
      expect(_RecordingProfilesAction.imported, isEmpty);

      container.read(appVisibleProvider.notifier).value = false;
      await tester.pumpAndSettle();
      container.read(appVisibleProvider.notifier).value = true;
      await tester.pumpAndSettle();

      expect(find.byType(ConfirmDialog), findsNothing);
    },
  );

  testWidgets('a new copy is asked about when the app comes back', (
    tester,
  ) async {
    clipboard = _subscription;
    await pump(tester);
    await tester.tap(find.text(AppLocalizations.current.cancel));
    await tester.pumpAndSettle();

    clipboard = 'https://example.org/other';
    container.read(appVisibleProvider.notifier).value = false;
    await tester.pumpAndSettle();
    container.read(appVisibleProvider.notifier).value = true;
    await tester.pumpAndSettle();

    expect(find.byType(ConfirmDialog), findsOneWidget);
  });

  testWidgets('with the permission off the clipboard is never read', (
    tester,
  ) async {
    clipboard = _subscription;

    await pump(tester, enabled: false);

    expect(find.byType(ConfirmDialog), findsNothing);
  });

  testWidgets('turning the permission on offers what is already copied', (
    tester,
  ) async {
    clipboard = _subscription;
    await pump(tester, enabled: false);

    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(clipboardDetection: true));
    await tester.pumpAndSettle();

    expect(find.byType(ConfirmDialog), findsOneWidget);
  });

  testWidgets('text that is no proxy server asks nothing', (tester) async {
    clipboard = 'meeting at noon';

    await pump(tester);

    expect(find.byType(ConfirmDialog), findsNothing);
  });

  testWidgets('a hidden window waits until it is shown', (tester) async {
    clipboard = _subscription;

    await pump(tester, visible: false);
    expect(find.byType(ConfirmDialog), findsNothing);

    container.read(appVisibleProvider.notifier).value = true;
    await tester.pumpAndSettle();

    expect(find.byType(ConfirmDialog), findsOneWidget);
  });
}
