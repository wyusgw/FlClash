import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/edit.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _FakePathProvider extends PathProviderPlatform {
  final String root;

  _FakePathProvider(this.root);

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

/// Keeps the setup machinery from running in a widget test.
class _NoopSetupAction extends SetupAction {
  var applied = 0;

  @override
  Future<bool> applyProfile({
    bool silence = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    applied++;
    return true;
  }

  @override
  Future<bool> setRunning(bool running, {bool initialize = false}) async =>
      true;
}

Profile _urlProfile() => Profile.normal(
  label: 'test',
  url: 'https://example.com/sub',
).copyWith(autoUpdate: false);

void main() {
  late Directory tempDir;
  late ProviderContainer container;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('edit_profile_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    await appPath.homeDirPath;
  });

  tearDownAll(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<Profile> openEdit(WidgetTester tester, {Profile? profile}) async {
    final target = profile ?? _urlProfile();
    tester.view.physicalSize = const Size(900, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([target])),
        currentProfileIdProvider.overrideWithBuild((_, _) => target.id),
        setupActionProvider.overrideWith(_NoopSetupAction.new),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(() async => tester.pumpWidget(const SizedBox()));
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(900, 1100);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => BaseNavigator.push(
                  context,
                  EditProfileView(profile: target),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return target;
  }

  Finder field(String label) => find.descendant(
    of: find.ancestor(of: find.text(label), matching: find.byType(Row)).first,
    matching: find.byType(TextField),
  );

  testWidgets('going back leaves without applying the profile again', (
    tester,
  ) async {
    await openEdit(tester);

    await tester.tap(find.byTooltip(currentAppLocalizations.back));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfileView), findsNothing);
    expect(
      (container.read(setupActionProvider.notifier) as _NoopSetupAction)
          .applied,
      0,
    );
  });

  testWidgets('shows the type, the address and the name of a subscription', (
    tester,
  ) async {
    await openEdit(tester);
    final l10n = currentAppLocalizations;

    expect(find.byType(EditProfileView), findsOneWidget);
    expect(find.text(l10n.profileType), findsOneWidget);
    expect(find.text(l10n.subscribe), findsOneWidget);
    expect(
      tester.widget<TextField>(field(l10n.url)).controller?.text,
      'https://example.com/sub',
    );
    expect(tester.widget<TextField>(field(l10n.name)).controller?.text, 'test');
    expect(find.text(l10n.copyLink), findsOneWidget);
    expect(find.text(l10n.copyJson), findsOneWidget);
    expect(find.text(l10n.delete), findsOneWidget);
  });

  testWidgets('the page offers no editing of the file and no upload', (
    tester,
  ) async {
    await openEdit(tester);

    expect(find.widgetWithText(GroupedRow, 'Edit'), findsNothing);
    expect(find.widgetWithText(GroupedRow, 'Upload'), findsNothing);
    expect(find.text(currentAppLocalizations.exportFile), findsOneWidget);
  });

  testWidgets('a file profile has no address and no link to copy', (
    tester,
  ) async {
    await openEdit(tester, profile: Profile.normal(label: 'local'));
    final l10n = currentAppLocalizations;

    expect(find.text(l10n.file), findsOneWidget);
    expect(find.text(l10n.url), findsNothing);
    expect(find.text(l10n.copyLink), findsNothing);
    expect(find.text(l10n.autoUpdate), findsNothing);
  });

  testWidgets('the interval shows only while auto update is on', (
    tester,
  ) async {
    await openEdit(tester);
    final l10n = currentAppLocalizations;
    expect(find.text(l10n.autoUpdateInterval), findsNothing);

    await tester.tap(find.byType(GroupedSwitch));
    await tester.pumpAndSettle();

    expect(find.text(l10n.autoUpdateInterval), findsOneWidget);
  });

  testWidgets('saving keeps the interval typed in minutes', (tester) async {
    final profile = await openEdit(tester);
    await tester.tap(find.byType(GroupedSwitch));
    await tester.pumpAndSettle();

    await tester.enterText(
      field(currentAppLocalizations.autoUpdateInterval),
      '90',
    );
    await tester.tap(find.text(currentAppLocalizations.save));
    await tester.pumpAndSettle();

    final saved = container.read(profilesProvider).single;
    expect(saved.autoUpdate, !profile.autoUpdate);
    expect(saved.autoUpdateDuration, const Duration(minutes: 90));
  });

  testWidgets('saving stores the new name and closes the page', (tester) async {
    final profile = await openEdit(tester);

    await tester.enterText(field(currentAppLocalizations.name), 'renamed');
    await tester.tap(find.text(currentAppLocalizations.save));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfileView), findsNothing);
    expect(
      container
          .read(profilesProvider)
          .firstWhere((item) => item.id == profile.id)
          .label,
      'renamed',
    );
  });

  testWidgets('saving an empty name changes nothing and stays', (tester) async {
    final profile = await openEdit(tester);

    await tester.enterText(field(currentAppLocalizations.name), '');
    await tester.tap(find.text(currentAppLocalizations.save));
    await tester.pump();

    expect(find.byType(EditProfileView), findsOneWidget);
    expect(container.read(profilesProvider).single.label, profile.label);
  });

  testWidgets('saving an address that is not a URL stays on the page', (
    tester,
  ) async {
    await openEdit(tester);

    await tester.enterText(field(currentAppLocalizations.url), 'nope');
    await tester.tap(find.text(currentAppLocalizations.save));
    await tester.pump();

    expect(find.byType(EditProfileView), findsOneWidget);
    expect(
      container.read(profilesProvider).single.url,
      'https://example.com/sub',
    );
  });

  testWidgets('copying the link puts the address on the clipboard', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
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
    await openEdit(tester);

    await tester.tap(find.text(currentAppLocalizations.copyLink));
    await tester.pumpAndSettle();

    expect(copied, 'https://example.com/sub');
  });

  testWidgets('deleting asks first, then removes the profile and closes', (
    tester,
  ) async {
    await openEdit(tester);

    await tester.tap(find.text(currentAppLocalizations.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pump();
    for (var i = 0; i < 50; i++) {
      if (find.byType(EditProfileView).evaluate().isEmpty) break;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.confirm), findsNothing);
    expect(container.read(profilesProvider), isEmpty);
    expect(find.byType(EditProfileView), findsNothing);
  });

  testWidgets('the back arrow leaves without saving', (tester) async {
    final profile = await openEdit(tester);

    await tester.enterText(field(currentAppLocalizations.name), 'unsaved');
    await tester.tap(find.byTooltip(currentAppLocalizations.back));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfileView), findsNothing);
    expect(container.read(profilesProvider).single.label, profile.label);
  });
}
