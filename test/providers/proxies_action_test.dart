import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

class MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

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

class _FakeSetupAction extends SetupAction {
  int applied = 0;
  bool Function() result = () => true;

  @override
  Future<bool> applyProfile({
    bool silence = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    applied++;
    return result();
  }
}

Map<String, Object?> _node(String tag) => {
  'tag': tag,
  'protocol': 'shadowsocks',
  'settings': {
    'address': '192.0.2.1',
    'port': 8388,
    'method': 'aes-128-gcm',
    'password': 'secret',
  },
};

const _testUrl = 'http://delay.test';

Group _group(String name, List<Proxy> all) =>
    Group(type: GroupType.Selector, name: name, all: all);

const _proxy = Proxy(name: 'HK-01', type: 'ss');

Profile _selectedProfile(String proxyName) => Profile(
  id: 1,
  autoUpdateDuration: Duration.zero,
  selectedMap: {nodeGroupName: proxyName},
);

final _delayKey = delayTestKey(_testUrl, 'HK-01');

ProviderContainer _delayContainer(ProviderContainer Function() build) {
  final container = build();
  container.read(appSettingProvider.notifier).value = const AppSettingProps(
    testUrl: _testUrl,
    delayTestMethod: DelayTestMethod.url,
  );
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCoreHandlerInterface core;

  late Directory home;

  setUpAll(() async {
    home = Directory.systemTemp.createTempSync('proxies_action_test');
    PathProviderPlatform.instance = _FakePathProvider(home.path);
    core = MockCoreHandlerInterface();
    await AppLocalizations.load(const Locale('en'));
  });

  tearDownAll(() => home.deleteSync(recursive: true));

  setUp(() => reset(core));

  ProviderContainer buildContainer({Profile? profile, SetupAction? setup}) {
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        if (setup != null) setupActionProvider.overrideWith(() => setup),
        profilesProvider.overrideWith(() => TestProfiles([?profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile?.id),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  ProxiesAction actionOf(ProviderContainer container) =>
      container.read(proxiesActionProvider.notifier);

  group('updateGroups', () {
    test('publishes the nodes of the current profile as one list', () async {
      File(await appPath.getProfilePath('1'))
        ..createSync(recursive: true)
        ..writeAsStringSync(
          jsonEncode({
            'outbounds': [_node('HK-01'), _node('JP-01')],
          }),
        );
      final container = buildContainer(profile: _selectedProfile('HK-01'));

      await actionOf(container).updateGroups();

      final groups = container.read(groupsProvider);
      expect(groups.map((group) => group.name), [nodeGroupName]);
      expect(groups.single.all.map((proxy) => proxy.name), ['HK-01', 'JP-01']);
      expect(groups.single.all.first.type, 'shadowsocks');
    });

    test('clears the list when there is no profile', () async {
      final container = buildContainer();
      container.read(groupsProvider.notifier).value = [
        _group('Stale', const []),
      ];

      await actionOf(container).updateGroups();

      expect(container.read(groupsProvider), isEmpty);
    });

    test('a core status change alone does not clear the groups', () {
      final container = buildContainer();
      actionOf(container);
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      container.read(groupsProvider.notifier).value = [
        _group('Stale', const []),
      ];

      container.read(coreStatusProvider.notifier).value =
          CoreStatus.disconnected;

      expect(container.read(groupsProvider).map((group) => group.name), [
        'Stale',
      ]);
    });
  });

  group('changeProxy', () {
    test('writes the node into the config by applying the profile', () async {
      final setup = _FakeSetupAction();
      final container = buildContainer(
        profile: _selectedProfile('HK-00'),
        setup: setup,
      );

      await actionOf(
        container,
      ).changeProxy(groupName: nodeGroupName, proxyName: 'HK-01');

      expect(setup.applied, 1);
      expect(container.read(currentProfileProvider)?.selectedMap, {
        nodeGroupName: 'HK-01',
      });
    });

    test('rolls the selection back when the Core refuses the config', () async {
      final setup = _FakeSetupAction()..result = () => false;
      final container = buildContainer(
        profile: _selectedProfile('HK-00'),
        setup: setup,
      );

      await actionOf(
        container,
      ).changeProxy(groupName: nodeGroupName, proxyName: 'HK-01');

      expect(container.read(currentProfileProvider)?.selectedMap, {
        nodeGroupName: 'HK-00',
      });
    });

    test('rolls the selection back when applying throws', () async {
      final setup = _FakeSetupAction()
        ..result = () => throw StateError('core down');
      final container = buildContainer(
        profile: _selectedProfile('HK-00'),
        setup: setup,
      );

      await actionOf(
        container,
      ).changeProxy(groupName: nodeGroupName, proxyName: 'HK-01');

      expect(container.read(currentProfileProvider)?.selectedMap, {
        nodeGroupName: 'HK-00',
      });
    });

    test(
      'rolls back to the last selection the Core applied, not the last tap',
      () async {
        final setup = _FakeSetupAction()..result = () => false;
        final container = buildContainer(
          profile: _selectedProfile('HK-00'),
          setup: setup,
        );
        final action = actionOf(container);

        action.changeProxyDebounce(nodeGroupName, 'HK-01');
        action.changeProxyDebounce(nodeGroupName, 'HK-02');
        expect(container.read(currentProfileProvider)?.selectedMap, {
          nodeGroupName: 'HK-02',
        });

        await action.changeProxy(groupName: nodeGroupName, proxyName: 'HK-02');

        expect(container.read(currentProfileProvider)?.selectedMap, {
          nodeGroupName: 'HK-00',
        });
        debouncer.cancel((FunctionTag.changeProxy, nodeGroupName));
      },
    );
  });

  group('proxyDelayTest', () {
    test('marks the node pending while it runs, then records it', () async {
      late ProviderContainer container;
      final observed = <bool>[];
      when(
        () => core.asyncTestDelay(
          _testUrl,
          'HK-01',
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((_) async {
        observed.add(
          container.read(pendingDelayTestsProvider).containsKey(_delayKey),
        );
        return const Delay(name: 'HK-01', url: _testUrl, value: 128);
      });
      container = _delayContainer(buildContainer);

      await actionOf(container).proxyDelayTest(_proxy);

      expect(observed, [true]);
      expect(container.read(delayDataSourceProvider)[_testUrl]?['HK-01'], 128);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test('keeps the last measurement when the Core does not answer', () async {
      when(
        () => core.asyncTestDelay(
          _testUrl,
          'HK-01',
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((_) async => null);
      final container = _delayContainer(buildContainer);
      container
          .read(delayDataSourceProvider.notifier)
          .setDelay(const Delay(name: 'HK-01', url: _testUrl, value: 42));

      await actionOf(container).proxyDelayTest(_proxy);

      expect(container.read(delayDataSourceProvider)[_testUrl]?['HK-01'], 42);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test('falls back to untested when a throwing call had no value', () async {
      when(
        () => core.asyncTestDelay(
          _testUrl,
          'HK-01',
          timeout: any(named: 'timeout'),
        ),
      ).thenThrow(StateError('channel is gone'));
      final container = _delayContainer(buildContainer);

      await actionOf(container).proxyDelayTest(_proxy);

      expect(container.read(delayDataSourceProvider)[_testUrl]?['HK-01'], null);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test('does nothing when the resolved proxy name is empty', () async {
      final container = buildContainer();

      await actionOf(container).proxyDelayTest(const Proxy(name: '', type: ''));

      expect(container.read(delayDataSourceProvider), isEmpty);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
      verifyNever(
        () => core.asyncTestDelay(any(), any(), timeout: any(named: 'timeout')),
      );
    });
  });

  group('delay test method', () {
    test('a TCP test connects to the node and never asks the Core', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(server.close);
      final container = buildContainer();
      container.read(appSettingProvider.notifier).value = const AppSettingProps(
        testUrl: _testUrl,
      );

      await actionOf(container).delayTest([
        Proxy(name: 'HK-01', type: 'ss', address: '127.0.0.1:${server.port}'),
      ]);

      final value = container.read(delayDataSourceProvider)[_testUrl]?['HK-01'];
      expect(value, greaterThanOrEqualTo(1));
      verifyNever(
        () => core.asyncTestDelay(any(), any(), timeout: any(named: 'timeout')),
      );
    });

    test('a TCP test of a node nobody answers for records a timeout', () async {
      final container = buildContainer();
      container.read(appSettingProvider.notifier).value = const AppSettingProps(
        testUrl: _testUrl,
      );

      await actionOf(container).delayTest(const [
        Proxy(name: 'HK-01', type: 'ss', address: '127.0.0.1:1'),
        Proxy(name: 'HK-02', type: 'ss'),
      ]);

      final delays = container.read(delayDataSourceProvider)[_testUrl];
      expect(delays?['HK-01'], -1);
      expect(delays?['HK-02'], -1);
    });

    test('a URL test hands the configured timeout to the Core', () async {
      when(
        () => core.asyncTestDelay(
          _testUrl,
          'HK-01',
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer(
        (_) async => const Delay(name: 'HK-01', url: _testUrl, value: 20),
      );
      final container = buildContainer();
      container.read(appSettingProvider.notifier).value = const AppSettingProps(
        testUrl: _testUrl,
        delayTestMethod: DelayTestMethod.url,
        delayTestTimeoutSeconds: 3,
      );

      await actionOf(container).delayTest(const [_proxy]);

      verify(
        () => core.asyncTestDelay(
          _testUrl,
          'HK-01',
          timeout: const Duration(seconds: 3),
        ),
      ).called(1);
    });
  });

  group('delayTest', () {
    test('measures every proxy and bumps the sort counter', () async {
      when(
        () => core.asyncTestDelay(
          _testUrl,
          any(),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer(
        (invocation) async => Delay(
          name: invocation.positionalArguments[1] as String,
          url: _testUrl,
          value: 10,
        ),
      );
      final container = _delayContainer(buildContainer);
      final before = container.read(sortNumProvider);

      await actionOf(
        container,
      ).delayTest(const [_proxy, Proxy(name: 'HK-02', type: 'ss')]);

      final delays = container.read(delayDataSourceProvider)[_testUrl];
      expect(delays?['HK-01'], 10);
      expect(delays?['HK-02'], 10);
      expect(container.read(sortNumProvider), before + 1);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test('lands a run of quick results in batches, not one per node', () async {
      when(
        () => core.asyncTestDelay(
          _testUrl,
          any(),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer(
        (invocation) async => Delay(
          name: invocation.positionalArguments[1] as String,
          url: _testUrl,
          value: 10,
        ),
      );
      final container = _delayContainer(buildContainer);
      var delayChanges = 0;
      var pendingChanges = 0;
      container.listen(delayDataSourceProvider, (_, _) => delayChanges++);
      container.listen(pendingDelayTestsProvider, (_, _) => pendingChanges++);
      final proxies = List.generate(
        1000,
        (index) => Proxy(name: 'HK-$index', type: 'ss'),
      );

      await actionOf(container).delayTest(proxies);

      expect(
        container.read(delayDataSourceProvider)[_testUrl],
        hasLength(1000),
      );
      expect(container.read(pendingDelayTestsProvider), isEmpty);
      expect(delayChanges, 1);
      expect(pendingChanges, lessThanOrEqualTo(2));
    });

    test(
      'marks only nodes the pool runs as running, the rest queued',
      () async {
        final answers = <String, Completer<Delay?>>{};
        when(
          () => core.asyncTestDelay(
            _testUrl,
            any(),
            timeout: any(named: 'timeout'),
          ),
        ).thenAnswer(
          (invocation) => answers
              .putIfAbsent(
                invocation.positionalArguments[1] as String,
                Completer<Delay?>.new,
              )
              .future,
        );
        final container = _delayContainer(buildContainer);
        final proxies = List.generate(
          maxConcurrentDelayTests + 1,
          (index) => Proxy(name: 'HK-$index', type: 'ss'),
        );
        DelayTestPhase? phaseOf(int index) => container.read(
          pendingDelayTestsProvider,
        )[delayTestKey(_testUrl, 'HK-$index')];

        final run = actionOf(container).delayTest(proxies);

        expect(phaseOf(0), DelayTestPhase.running);
        expect(phaseOf(maxConcurrentDelayTests - 1), DelayTestPhase.running);
        expect(phaseOf(maxConcurrentDelayTests), DelayTestPhase.queued);

        answers['HK-0']!.complete(null);
        await Future<void>.delayed(renderThrottleDuration * 2);

        expect(phaseOf(0), isNull);
        expect(phaseOf(maxConcurrentDelayTests), DelayTestPhase.running);

        for (final answer in answers.values) {
          if (!answer.isCompleted) {
            answer.complete(null);
          }
        }
        await run;

        expect(container.read(pendingDelayTestsProvider), isEmpty);
      },
    );

    test('probes a node that appears twice only once', () async {
      when(
        () => core.asyncTestDelay(
          _testUrl,
          'HK-01',
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer(
        (_) async => const Delay(name: 'HK-01', url: _testUrl, value: 10),
      );
      final container = _delayContainer(buildContainer);

      await actionOf(container).delayTest(const [_proxy, _proxy]);

      verify(
        () => core.asyncTestDelay(
          _testUrl,
          'HK-01',
          timeout: any(named: 'timeout'),
        ),
      ).called(1);
    });

    test('testing groups probes a shared node once per test URL', () async {
      const otherUrl = 'http://other.test';
      when(
        () => core.asyncTestDelay(any(), any(), timeout: any(named: 'timeout')),
      ).thenAnswer(
        (invocation) async => Delay(
          url: invocation.positionalArguments[0] as String,
          name: invocation.positionalArguments[1] as String,
          value: 10,
        ),
      );
      final container = _delayContainer(buildContainer);
      final before = container.read(sortNumProvider);

      await actionOf(container).delayTestGroups([
        _group('A', const [_proxy]),
        _group('B', const [_proxy, Proxy(name: 'HK-02', type: 'ss')]),
        const Group(
          type: GroupType.URLTest,
          name: 'C',
          testUrl: otherUrl,
          all: [_proxy],
        ),
      ]);

      verify(
        () => core.asyncTestDelay(
          _testUrl,
          'HK-01',
          timeout: any(named: 'timeout'),
        ),
      ).called(1);
      verify(
        () => core.asyncTestDelay(
          _testUrl,
          'HK-02',
          timeout: any(named: 'timeout'),
        ),
      ).called(1);
      verify(
        () => core.asyncTestDelay(
          otherUrl,
          'HK-01',
          timeout: any(named: 'timeout'),
        ),
      ).called(1);
      expect(container.read(sortNumProvider), before + 1);
    });

    test(
      'testing a page group probes the nodes the timeout filter hides',
      () async {
        when(
          () => core.asyncTestDelay(
            _testUrl,
            any(),
            timeout: any(named: 'timeout'),
          ),
        ).thenAnswer(
          (invocation) async => Delay(
            name: invocation.positionalArguments[1] as String,
            url: _testUrl,
            value: 10,
          ),
        );
        final container = _delayContainer(buildContainer);
        container
            .read(groupsProvider.notifier)
            .update(
              (_) => [
                _group('Proxy', const [
                  _proxy,
                  Proxy(name: 'HK-02', type: 'ss'),
                  Proxy(name: 'JP-01', type: 'ss'),
                ]),
              ],
            );
        container
            .read(delayDataSourceProvider.notifier)
            .setDelay(const Delay(url: _testUrl, name: 'HK-02', value: -1));
        container
            .read(proxiesStyleSettingProvider.notifier)
            .update((state) => state.copyWith(hideTimeoutProxies: true));
        container.read(queryProvider(QueryTag.proxies).notifier).value = 'HK';

        await actionOf(container).delayTestPageGroup('Proxy');

        verify(
          () => core.asyncTestDelay(
            _testUrl,
            'HK-01',
            timeout: any(named: 'timeout'),
          ),
        ).called(1);
        verify(
          () => core.asyncTestDelay(
            _testUrl,
            'HK-02',
            timeout: any(named: 'timeout'),
          ),
        ).called(1);
        verifyNever(
          () => core.asyncTestDelay(
            _testUrl,
            'JP-01',
            timeout: any(named: 'timeout'),
          ),
        );
      },
    );

    test('a page group holds its testing mark until the run settles', () async {
      final release = Completer<Delay?>();
      when(
        () => core.asyncTestDelay(
          _testUrl,
          'HK-01',
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((_) => release.future);
      final container = _delayContainer(buildContainer);
      container
          .read(groupsProvider.notifier)
          .update(
            (_) => [
              _group('Proxy', const [_proxy]),
            ],
          );

      final run = actionOf(container).delayTestPageGroup('Proxy');
      await actionOf(container).delayTestPageGroup('Proxy');

      expect(container.read(delayTestingGroupsProvider), {'Proxy'});
      release.completeError(
        const CoreMethodException(code: 'internal_error', message: 'boom'),
      );
      await run;

      verify(
        () => core.asyncTestDelay(
          _testUrl,
          'HK-01',
          timeout: any(named: 'timeout'),
        ),
      ).called(1);
      expect(container.read(delayTestingGroupsProvider), isEmpty);
    });

    test('stops the run once the transport is gone', () async {
      var calls = 0;
      when(
        () => core.asyncTestDelay(
          _testUrl,
          any(),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((_) async {
        calls++;
        throw const CoreMethodException(
          code: 'transport_disconnected',
          message: 'the Core is gone',
        );
      });
      final container = _delayContainer(buildContainer);
      final proxies = List.generate(
        maxConcurrentDelayTests * 3,
        (index) => Proxy(name: 'HK-$index', type: 'ss'),
      );

      await actionOf(container).delayTest(proxies);

      expect(calls, lessThanOrEqualTo(maxConcurrentDelayTests));
      expect(calls, lessThan(proxies.length));
      expect(container.read(delayDataSourceProvider), isEmpty);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test('a proxy that answers nothing leaves the rest of the run', () async {
      var calls = 0;
      when(
        () => core.asyncTestDelay(
          _testUrl,
          any(),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((invocation) async {
        calls++;
        final name = invocation.positionalArguments[1] as String;
        if (name == 'HK-1') {
          return null;
        }
        return Delay(name: name, url: _testUrl, value: 10);
      });
      final container = _delayContainer(buildContainer);
      final proxies = List.generate(
        8,
        (index) => Proxy(name: 'HK-$index', type: 'ss'),
      );

      await actionOf(container).delayTest(proxies);

      expect(calls, proxies.length);
      final delays = container.read(delayDataSourceProvider)[_testUrl];
      expect(delays?.length, proxies.length - 1);
      expect(delays?['HK-1'], isNull);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test('a proxy that fails leaves the rest of the run', () async {
      var calls = 0;
      when(
        () => core.asyncTestDelay(
          _testUrl,
          any(),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((invocation) async {
        calls++;
        final name = invocation.positionalArguments[1] as String;
        if (name == 'HK-1') {
          throw const CoreMethodException(
            code: 'internal_error',
            message: 'internal panic',
          );
        }
        return Delay(name: name, url: _testUrl, value: 10);
      });
      final container = _delayContainer(buildContainer);
      final proxies = List.generate(
        8,
        (index) => Proxy(name: 'HK-$index', type: 'ss'),
      );

      await actionOf(container).delayTest(proxies);

      expect(calls, proxies.length);
      final delays = container.read(delayDataSourceProvider)[_testUrl];
      expect(delays?.length, proxies.length - 1);
      expect(delays?['HK-1'], isNull);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });

    test('drops every spinner when the Core goes away mid-run', () async {
      final release = Completer<Delay?>();
      when(
        () => core.asyncTestDelay(
          _testUrl,
          any(),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((_) => release.future);
      final container = _delayContainer(buildContainer);
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;

      final run = actionOf(
        container,
      ).delayTest(const [_proxy, Proxy(name: 'HK-02', type: 'ss')]);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(pendingDelayTestsProvider), isNotEmpty);

      container.read(coreStatusProvider.notifier).value =
          CoreStatus.disconnected;
      expect(container.read(pendingDelayTestsProvider), isEmpty);

      release.complete(const Delay(name: 'HK-01', url: _testUrl, value: 10));
      await run;

      expect(container.read(delayDataSourceProvider), isEmpty);
      expect(container.read(pendingDelayTestsProvider), isEmpty);
    });
  });

  group('current profile mutations', () {
    test('updateCurrentGroupName writes the new group onto the profile', () {
      final profile = Profile.normal(label: 'p');
      final container = buildContainer(profile: profile);

      actionOf(container).updateCurrentGroupName('Proxy');

      expect(container.read(profilesProvider).single.currentGroupName, 'Proxy');
    });

    test('updateCurrentGroupName is a no-op for the same group', () {
      final profile = Profile.normal(
        label: 'p',
      ).copyWith(currentGroupName: 'Proxy');
      final container = buildContainer(profile: profile);

      actionOf(container).updateCurrentGroupName('Proxy');

      expect(container.read(profilesProvider).single, same(profile));
    });

    test('updateCurrentUnfoldSet is a no-op without a current profile', () {
      final container = buildContainer();

      expect(
        () => actionOf(container).updateCurrentUnfoldSet({'Proxy'}),
        returnsNormally,
      );
      expect(container.read(profilesProvider), isEmpty);
    });

    test('updateCurrentUnfoldSet stores the set on the current profile', () {
      final profile = Profile.normal(label: 'p');
      final container = buildContainer(profile: profile);

      actionOf(container).updateCurrentUnfoldSet({'Proxy', 'Auto'});

      expect(container.read(profilesProvider).single.unfoldSet, {
        'Proxy',
        'Auto',
      });
    });
  });
}
