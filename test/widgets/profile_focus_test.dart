import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/profiles.dart';
import 'package:fl_clash/views/profiles/subscription_info.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_profiles.dart';

Profile urlProfile(String label) =>
    Profile.normal(label: label, url: 'https://example.com/sub').copyWith(
      subscriptionInfo: const SubscriptionInfo(
        upload: 1024,
        download: 2048,
        total: 4096,
        expire: 1234567890,
      ),
    );

Future<ProviderContainer> pumpProfiles(
  WidgetTester tester, {
  required List<Profile> profiles,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(900, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(() => TestProfiles(profiles)),
      currentProfileIdProvider.overrideWithBuild((_, _) => profiles.first.id),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).value = const Size(900, 800);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: globalState.navigatorKey,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        builder: (context, child) {
          globalState.measure = Measure.of(context, 1);
          globalState.theme = CommonTheme.of(context, 1);
          return child!;
        },
        home: const ProfilesView(),
      ),
    ),
  );
  await tester.pump();
  return container;
}

Finder _infoOf(String label) {
  final row = find.ancestor(
    of: find.text(label),
    matching: find.byType(GroupedRow),
  );
  return find.descendant(of: row, matching: find.byGlyph(AppGlyphs.info));
}

void main() {
  testWidgets('every profile gets a row with its own menu button', (
    tester,
  ) async {
    final profiles = [
      urlProfile('url 1'),
      Profile.normal(label: 'file 1'),
      urlProfile('url 2'),
    ];
    await pumpProfiles(tester, profiles: profiles);

    for (final profile in profiles) {
      expect(_infoOf(profile.realLabel), findsOneWidget);
    }
  });

  testWidgets('the menu button opens the actions of its profile', (
    tester,
  ) async {
    await pumpProfiles(tester, profiles: [urlProfile('url')]);

    await tester.tap(_infoOf('url'));
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.edit), findsOneWidget);
    expect(find.text(currentAppLocalizations.preview), findsOneWidget);
    expect(find.text(currentAppLocalizations.delete), findsOneWidget);
  });

  testWidgets('subscription menu item opens the usage page', (tester) async {
    await pumpProfiles(tester, profiles: [urlProfile('url')]);

    await tester.tap(_infoOf('url'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(currentAppLocalizations.more).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.subscriptionInfo));
    await tester.pumpAndSettle();

    expect(find.byType(SubscriptionInfoPage), findsOneWidget);
    expect(find.text(currentAppLocalizations.subscriptionInfo), findsOneWidget);
  });
}
