import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/backup_and_restore.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/views/data.dart';
import 'package:fl_clash/views/home/delay_test.dart';
import 'package:fl_clash/views/profiles/profiles.dart';
import 'package:fl_clash/views/tools.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

Profile _profile(int id, String label) => Profile(
  id: id,
  label: label,
  autoUpdateDuration: Duration.zero,
  url: 'https://example.com/$id',
  lastUpdateDate: DateTime(2026, 9, 26, 13, 41, 43),
);

void main() {
  late Directory home;
  late ProviderContainer container;

  setUpAll(() async {
    home = Directory.systemTemp.createTempSync('grouped_pages_test');
    PathProviderPlatform.instance = _FakePathProvider(home.path);
    await appPath.homeDirPath;
  });

  tearDownAll(() => home.deleteSync(recursive: true));

  Future<void> pumpPage(
    WidgetTester tester,
    Widget page, {
    List<Profile> profiles = const [],
  }) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles(profiles)),
        currentProfileIdProvider.overrideWithBuild(
          (_, _) => profiles.firstOrNull?.id,
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(900, 900);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: page),
      ),
    );
    await tester.pump();
  }

  group('profiles page', () {
    testWidgets('without profiles it only offers to add one', (tester) async {
      await pumpPage(tester, const ProfilesView());

      expect(find.text('Add profile'), findsOneWidget);
      expect(find.text('Update all'), findsNothing);
      expect(find.text('Sort profiles'), findsNothing);
      expect(find.text('A check mark marks the profile in use.'), findsNothing);
    });

    testWidgets('lists each profile with its date and marks the one in use', (
      tester,
    ) async {
      await pumpPage(
        tester,
        const ProfilesView(),
        profiles: [_profile(1, 'first'), _profile(2, 'second')],
      );

      expect(find.text('first'), findsOneWidget);
      expect(find.text('second'), findsOneWidget);
      expect(find.text('2026-09-26 13:41:43'), findsNWidgets(2));
      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
      expect(
        find.descendant(
          of: find.widgetWithText(GroupedRow, 'first'),
          matching: find.byGlyph(AppGlyphs.check),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping a profile makes it the one in use', (tester) async {
      await pumpPage(
        tester,
        const ProfilesView(),
        profiles: [_profile(1, 'first'), _profile(2, 'second')],
      );

      await tester.tap(find.text('second'));
      await tester.pump();

      expect(container.read(currentProfileIdProvider), 2);
      expect(
        find.descendant(
          of: find.widgetWithText(GroupedRow, 'second'),
          matching: find.byGlyph(AppGlyphs.check),
        ),
        findsOneWidget,
      );
    });

    testWidgets('offers updating and sorting once there is a profile', (
      tester,
    ) async {
      await pumpPage(
        tester,
        const ProfilesView(),
        profiles: [_profile(1, 'first')],
      );

      expect(find.text('Update all'), findsOneWidget);
      expect(find.text('Sort profiles'), findsOneWidget);
      expect(
        find.text('A check mark marks the profile in use.'),
        findsOneWidget,
      );
    });
  });

  group('data page', () {
    testWidgets('groups backup, logs and profiles', (tester) async {
      await pumpPage(
        tester,
        const DataView(),
        profiles: [_profile(1, 'first')],
      );

      expect(find.text('Backup and restore'), findsOneWidget);
      expect(find.text('Sync data via WebDAV or files'), findsOneWidget);
      expect(find.text('Logs'), findsWidgets);
      expect(find.text('Export file'), findsOneWidget);
      expect(find.text('Delete all profiles'), findsOneWidget);
    });

    testWidgets('the logcat switch flips the setting', (tester) async {
      await pumpPage(tester, const DataView());
      expect(container.read(appSettingProvider).openLogs, isFalse);

      await tester.tap(find.byType(GroupedSwitch));
      await tester.pumpAndSettle();

      expect(container.read(appSettingProvider).openLogs, isTrue);
      expect(
        tester.widget<GroupedSwitch>(find.byType(GroupedSwitch)).value,
        true,
      );
    });

    testWidgets('the backup row opens the backup page', (tester) async {
      await pumpPage(tester, const DataView());

      await tester.tap(find.text('Backup and restore'));
      await tester.pumpAndSettle();

      expect(find.byType(BackupAndRestore), findsOneWidget);
    });

    testWidgets('deleting every profile asks first and then clears them', (
      tester,
    ) async {
      await pumpPage(
        tester,
        const DataView(),
        profiles: [_profile(1, 'first'), _profile(2, 'second')],
      );

      await tester.tap(find.text('Delete all profiles'));
      await tester.pumpAndSettle();
      expect(container.read(profilesProvider), hasLength(2));

      await tester.tap(find.text('Confirm'));
      for (var i = 0; i < 50; i++) {
        if (container.read(profilesProvider).isEmpty) break;
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(container.read(profilesProvider), isEmpty);
    });

    testWidgets('with no profile the profile rows do nothing', (tester) async {
      await pumpPage(tester, const DataView());

      await tester.tap(find.text('Delete all profiles'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm'), findsNothing);
    });
  });

  group('settings page', () {
    testWidgets('shows the language and the groups of settings', (
      tester,
    ) async {
      await pumpPage(tester, const ToolsView());

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Developer mode'), findsNothing);
    });

    testWidgets('the developer page shows once developer mode is on', (
      tester,
    ) async {
      await pumpPage(tester, const ToolsView());

      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(developerMode: true));
      await tester.pump();

      expect(find.text('Developer mode'), findsOneWidget);
    });

    testWidgets('picking a language checks it and stores it', (tester) async {
      await pumpPage(tester, const ToolsView());

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      expect(find.byType(LanguageView), findsOneWidget);
      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pump();

      expect(container.read(appSettingProvider).locale, 'en');
      expect(
        find.descendant(
          of: find.widgetWithText(GroupedRow, 'English'),
          matching: find.byGlyph(AppGlyphs.check),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the delay test method opens its page and a pick sticks', (
      tester,
    ) async {
      await pumpPage(tester, const ToolsView());
      expect(find.text('Delay test method'), findsOneWidget);
      expect(find.text('TCP'), findsOneWidget);

      await tester.tap(find.text('Delay test method'));
      await tester.pumpAndSettle();
      expect(find.byType(DelayMethodView), findsOneWidget);

      await tester.tap(find.text('CONNECT'));
      await tester.pumpAndSettle();
      expect(
        container.read(appSettingProvider).delayTestMethod,
        DelayTestMethod.url,
      );

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('CONNECT'), findsOneWidget);
    });

    testWidgets('the language page goes back', (tester) async {
      await pumpPage(tester, const ToolsView());

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(LanguageView), findsNothing);
      expect(find.byType(ToolsView), findsOneWidget);
    });
  });
}
