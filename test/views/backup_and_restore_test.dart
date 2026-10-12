import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/backup_and_restore.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _existing = DAVProps(
  uri: 'https://dav.example.com/remote',
  user: 'alice',
  password: 'secret',
  fileName: 'custom.zip',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 1400);
    container.listen(davSettingProvider, (_, _) {}, fireImmediately: true);
  });

  tearDown(() => container.dispose());

  Future<void> pumpDialog(WidgetTester tester, Widget dialog) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: Scaffold(body: dialog)),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('RestoreOptionsDialog', () {
    Future<RestoreOption?> openAndChoose(
      WidgetTester tester,
      String label,
    ) async {
      tester.view.physicalSize = const Size(1200, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      RestoreOption? chosen;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    chosen = await showDialog<RestoreOption>(
                      context: context,
                      builder: (_) => const RestoreOptionsDialog(),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      return chosen;
    }

    testWidgets('returns onlyProfiles for the config-only option', (
      tester,
    ) async {
      expect(
        await openAndChoose(tester, 'Restore profiles only'),
        RestoreOption.onlyProfiles,
      );
    });

    testWidgets('returns all for the full-data option', (tester) async {
      expect(
        await openAndChoose(tester, 'Restore all data'),
        RestoreOption.all,
      );
    });
  });

  group('WebDAVFormPage', () {
    Finder row(String label) =>
        find.widgetWithText(GroupedFieldRow, label).first;

    Finder field(String label) =>
        find.descendant(of: row(label), matching: find.byType(TextField));

    Future<void> fill(
      WidgetTester tester, {
      String address = 'https://dav.example.com/remote',
      String account = 'alice',
      String password = 'secret',
    }) async {
      await tester.enterText(field('Address'), address);
      await tester.enterText(field('Account'), account);
      await tester.enterText(field('Password'), password);
    }

    Future<void> save(WidgetTester tester) async {
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
    }

    testWidgets('is a page of rows, not a dialog', (tester) async {
      await pumpDialog(tester, const WebDAVFormPage());

      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(GroupedPage), findsOneWidget);
      for (final label in ['Address', 'Account', 'Password']) {
        expect(row(label), findsOneWidget);
      }
    });

    testWidgets('rejects an empty form, says why and stores nothing', (
      tester,
    ) async {
      await pumpDialog(tester, const WebDAVFormPage());

      await save(tester);

      expect(container.read(davSettingProvider), isNull);
      expect(find.byType(WebDAVFormPage), findsOneWidget);
      expect(find.text(AppLocalizations.current.addressTip), findsOneWidget);
    });

    testWidgets('names the password toggle by what pressing it does', (
      tester,
    ) async {
      await pumpDialog(tester, const WebDAVFormPage());

      expect(find.byTooltip('Show password'), findsOneWidget);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Hide password'), findsOneWidget);
      expect(find.byGlyph(AppGlyphs.eyeOff), findsOneWidget);
    });

    testWidgets('rejects a malformed address', (tester) async {
      await pumpDialog(tester, const WebDAVFormPage());

      await fill(tester, address: 'not-a-url');
      await save(tester);

      expect(container.read(davSettingProvider), isNull);
      expect(find.text(AppLocalizations.current.addressTip), findsOneWidget);
    });

    testWidgets('an empty account or password is named', (tester) async {
      await pumpDialog(tester, const WebDAVFormPage());

      await fill(tester, account: '');
      await save(tester);
      expect(
        find.text(AppLocalizations.current.emptyTip('Account')),
        findsOneWidget,
      );

      await fill(tester, password: '');
      await save(tester);
      expect(container.read(davSettingProvider), isNull);
    });

    testWidgets('stores a valid binding with the default file name', (
      tester,
    ) async {
      await pumpDialog(tester, const WebDAVFormPage());

      await fill(tester);
      await save(tester);

      final dav = container.read(davSettingProvider);
      expect(dav?.uri, 'https://dav.example.com/remote');
      expect(dav?.user, 'alice');
      expect(dav?.password, 'secret');
      expect(dav?.fileName, defaultDavFileName);
    });

    testWidgets('Enter on the password row saves too', (tester) async {
      await pumpDialog(tester, const WebDAVFormPage());

      await fill(tester);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(container.read(davSettingProvider)?.user, 'alice');
    });

    testWidgets('editing preserves the previously chosen file name', (
      tester,
    ) async {
      container.read(davSettingProvider.notifier).update((_) => _existing);
      await pumpDialog(tester, const WebDAVFormPage(dav: _existing));

      await tester.enterText(field('Account'), 'bob');
      await save(tester);

      final dav = container.read(davSettingProvider);
      expect(dav?.user, 'bob');
      expect(dav?.fileName, 'custom.zip');
    });

    testWidgets('offers delete only when editing an existing binding', (
      tester,
    ) async {
      await pumpDialog(tester, const WebDAVFormPage());
      expect(find.text('Delete'), findsNothing);

      await pumpDialog(tester, const WebDAVFormPage(dav: _existing));
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('delete clears the stored binding', (tester) async {
      container.read(davSettingProvider.notifier).update((_) => _existing);
      await pumpDialog(tester, const WebDAVFormPage(dav: _existing));

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(container.read(davSettingProvider), isNull);
    });
  });

  group('file name row', () {
    testWidgets('types the file name in the row and keeps it on Enter', (
      tester,
    ) async {
      container.read(davSettingProvider.notifier).update((_) => _existing);
      tester.view.physicalSize = const Size(1200, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: BackupAndRestore()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('custom.zip'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      await tester.enterText(find.byType(EditableText), 'mine.zip');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(container.read(davSettingProvider)?.fileName, 'mine.zip');
      expect(container.read(davSettingProvider)?.user, 'alice');
    });
  });
}
