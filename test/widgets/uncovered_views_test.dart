import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/link.dart';
import 'package:fl_clash/common/request.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/about.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _PendingAdapter implements HttpClientAdapter {
  final response = Completer<ResponseBody>();
  int requests = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests++;
    return response.future;
  }

  @override
  void close({bool force = false}) {}
}

ProviderContainer _containerFor(
  WidgetTester tester, {
  List<Override> overrides = const [],
  List<Profile>? profiles,
  Size size = const Size(1400, 1000),
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(
        profiles == null ? TestProfiles.new : () => TestProfiles(profiles),
      ),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  return container;
}

void main() {
  setUpAll(() {
    // AboutView reads globalState.packageInfo, which only the real app bootstrap
    // populates.
    globalState.packageInfo = PackageInfo(
      appName: 'FlClash',
      packageName: 'com.follow.clash',
      version: '0.0.0',
      buildNumber: '1',
    );
  });

  testWidgets('about view renders version and link sections', (tester) async {
    final container = _containerFor(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: AboutView()),
      ),
    );
    await tester.pump();

    expect(find.byType(AboutView), findsOneWidget);
    expect(find.text('Telegram'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('0.0.0 (1)'), findsOneWidget);
    expect(find.text('Star on GitHub'), findsOneWidget);
    expect(find.text('Feedback'), findsNWidgets(2));
    expect(find.text('URL Schemes'), findsNWidgets(2));
    expect(tester.takeException(), null);

    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isNotEmpty) {
      for (var index = 0; index < 4; index++) {
        await tester.drag(scrollables.first, const Offset(0, -400));
        await tester.pump();
      }
    }
    expect(tester.takeException(), null);
  });

  testWidgets('about view lists the credits and the URL schemes page', (
    tester,
  ) async {
    final container = _containerFor(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: AboutView()),
      ),
    );
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Xray-core'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Xray-core'), findsOneWidget);
    expect(find.text('June2'), findsOneWidget);

    await tester.tap(find.widgetWithText(GroupedRow, 'URL Schemes'));
    await tester.pumpAndSettle();
    expect(find.byType(UrlSchemesView), findsOneWidget);
    for (final path in [...appLinkPaths.values, '$addLinkPath/{url}']) {
      expect(find.text('flclash://$path'), findsOneWidget);
    }
    expect(find.text('Toggle the VPN tunnel'), findsOneWidget);
    expect(find.text('Start the VPN tunnel'), findsOneWidget);
    expect(find.text('Stop the VPN tunnel'), findsOneWidget);
    expect(find.text('Switch server'), findsOneWidget);
    expect(find.text('Add a server'), findsOneWidget);
    expect(find.text('Switch routing'), findsOneWidget);
  });

  testWidgets('about view shows progress while checking for updates', (
    tester,
  ) async {
    final container = _containerFor(tester);
    final originalAdapter = request.dio.httpClientAdapter;
    addTearDown(() => request.dio.httpClientAdapter = originalAdapter);
    final adapter = _PendingAdapter();
    request.dio.httpClientAdapter = adapter;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: AboutView()),
      ),
    );
    await tester.pump();
    expect(find.byType(IosSpinner), findsNothing);

    await tester.tap(find.text('Check for updates'));
    await tester.pump();
    expect(find.byType(IosSpinner), findsOneWidget);

    await tester.tap(find.text('Check for updates'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(adapter.requests, 1);

    adapter.response.complete(
      ResponseBody.fromString(
        jsonEncode({'tag_name': 'v0.0.0'}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(IosProgressBar), findsNothing);
    expect(find.text('The app is already up to date'), findsOneWidget);
    expect(tester.takeException(), null);
  });
}
