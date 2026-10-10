import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/request.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/about.dart';
import 'package:fl_clash/views/proxies/setting.dart';
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

  testWidgets('proxies setting sheet renders and switches layout type', (
    tester,
  ) async {
    final container = _containerFor(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: Scaffold(body: ProxiesSetting())),
      ),
    );
    await tester.pump();

    expect(find.byType(ProxiesSetting), findsOneWidget);
    expect(tester.takeException(), null);

    container
        .read(proxiesStyleSettingProvider.notifier)
        .update((state) => state.copyWith(type: ProxiesType.list));
    await tester.pump();

    expect(container.read(proxiesStyleSettingProvider).type, ProxiesType.list);
    expect(tester.takeException(), null);
  });

  testWidgets('proxies setting sorts by delay when selected', (tester) async {
    final container = _containerFor(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: Scaffold(body: ProxiesSetting())),
      ),
    );
    await tester.pump();

    container
        .read(proxiesStyleSettingProvider.notifier)
        .update((state) => state.copyWith(sortType: ProxiesSortType.delay));
    await tester.pump();

    expect(
      container.read(proxiesStyleSettingProvider).sortType,
      ProxiesSortType.delay,
    );
    expect(tester.takeException(), null);
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
    final hero = find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString() == '_AboutHero',
    );
    expect(
      tester.getRect(hero).top,
      tester.getRect(find.byType(AppBar)).bottom + 12,
    );
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
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await tester.tap(find.text('Check for updates'));
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

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

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('The app is already up to date'), findsOneWidget);
    expect(tester.takeException(), null);
  });
}
