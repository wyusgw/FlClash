import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/test_profiles.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

class _NoopSetupAction extends SetupAction {
  @override
  void applyProfileDebounce({
    bool silence = false,
    bool force = false,
    Duration? duration,
  }) {}
}

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

void main() {
  late Directory home;

  setUpAll(() async {
    home = Directory.systemTemp.createTempSync('profile_notices_test');
    PathProviderPlatform.instance = _FakePathProvider(home.path);
    await appPath.homeDirPath;
    await AppLocalizations.load(const Locale('en'));
  });

  tearDownAll(() => home.deleteSync(recursive: true));

  Future<ProviderContainer> pumpHost(
    WidgetTester tester, {
    List<Profile> profiles = const [],
  }) async {
    final core = _MockCore();
    when(() => core.validateConfig(any())).thenAnswer((_) async => '');
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        profilesProvider.overrideWith(() => TestProfiles(profiles)),
        currentProfileIdProvider.overrideWithBuild((_, _) => null),
        setupActionProvider.overrideWith(_NoopSetupAction.new),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: globalState.navigatorKey,
          localizationsDelegates: const [AppLocalizations.delegate],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          builder: (context, child) => StatusManager(child: child!),
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      ),
    );
    return container;
  }

  testWidgets('deleting a profile says it was deleted', (tester) async {
    final profile = Profile.normal(label: 'doomed');
    final container = await pumpHost(tester, profiles: [profile]);

    await tester.runAsync(
      () => container
          .read(profilesActionProvider.notifier)
          .deleteProfile(profile.id),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(container.read(profilesProvider), isEmpty);
    expect(find.text('Deleted successfully'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('adding a server by hand says it was added', (tester) async {
    final container = await pumpHost(tester);

    await tester.runAsync(
      () => container.read(profilesActionProvider.notifier).addManualNode({
        'tag': 'typed',
        'protocol': 'shadowsocks',
        'settings': {
          'address': '192.0.2.1',
          'port': 8388,
          'method': 'aes-128-gcm',
          'password': 'secret',
        },
      }),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(container.read(profilesProvider), hasLength(1));
    expect(find.text('Added successfully'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
