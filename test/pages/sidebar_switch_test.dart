import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/pages/home.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/navigation.dart';
import 'package:fl_clash/views/tools.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  setUp(() {
    navigationPort = navigation;
    addTearDown(() => navigationPort = null);
  });

  testWidgets(
    'turning the sidebar off docks the bottom bar and back on brings the sidebar out',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = ProviderContainer(
        overrides: [profilesProvider.overrideWith(TestProfiles.new)],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container.listen(appSettingProvider, (_, _) {});
      container.read(viewSizeProvider.notifier).value = const Size(1200, 800);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: HomePage()),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> openSidebarPage() async {
        await tester.tap(find.text('Settings').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sidebar'));
        await tester.pumpAndSettle();
      }

      expect(find.byType(NavigationSidebar), findsOneWidget);
      await openSidebarPage();
      await tester.tap(find.text('Off'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationSidebar), findsNothing);
      expect(find.byType(DockedTabBar), findsOneWidget);
      expect(find.byType(NavigationDock), findsNothing);

      await openSidebarPage();
      expect(find.byType(SidebarView), findsOneWidget);
      await tester.tap(find.text('On'));
      await tester.pumpAndSettle();

      expect(find.byType(SidebarView), findsNothing);
      expect(find.byType(NavigationSidebar), findsOneWidget);
      expect(find.byType(DockedTabBar), findsNothing);
      expect(find.byType(NavigationDock), findsNothing);
    },
  );
}
