import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

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

class _NoopSetupAction extends SetupAction {
  var applied = 0;

  @override
  void applyProfileDebounce({
    bool silence = false,
    bool force = false,
    Duration? duration,
  }) {
    applied++;
  }
}

Map<String, dynamic> _node(String tag) => {
  'tag': tag,
  'protocol': 'shadowsocks',
  'settings': {
    'address': '192.0.2.1',
    'port': 8388,
    'method': 'aes-128-gcm',
    'password': 'secret',
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory home;
  late _MockCore core;
  late ProviderContainer container;

  setUpAll(() async {
    home = Directory.systemTemp.createTempSync('manual_node_test');
    PathProviderPlatform.instance = _FakePathProvider(home.path);
    await appPath.homeDirPath;
    await AppLocalizations.load(const Locale('en'));
  });

  tearDownAll(() => home.deleteSync(recursive: true));

  setUp(() {
    core = _MockCore();
    when(() => core.validateConfig(any())).thenAnswer((_) async => '');
  });

  ProviderContainer build({List<Profile> profiles = const [], int? current}) {
    container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        profilesProvider.overrideWith(() => TestProfiles(profiles)),
        currentProfileIdProvider.overrideWithBuild((_, _) => current),
        setupActionProvider.overrideWith(_NoopSetupAction.new),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    return container;
  }

  Future<List<Map<String, dynamic>>> outboundsOf(Profile profile) async {
    final text = await File(
      await appPath.getProfilePath(profile.id.toString()),
    ).readAsString();
    return ((json.decode(text) as Map)['outbounds'] as List)
        .cast<Map<String, dynamic>>();
  }

  Future<void> add(Map<String, dynamic> outbound) {
    return container
        .read(profilesActionProvider.notifier)
        .addManualNode(outbound);
  }

  test(
    'with no profile it makes a local one and makes it the current',
    () async {
      build();

      await add(_node('first'));

      final profile = container.read(profilesProvider).single;
      expect(profile.type, ProfileType.file);
      expect(profile.label, 'Local servers');
      expect(container.read(currentProfileIdProvider), profile.id);
      expect((await outboundsOf(profile)).map((node) => node['tag']), [
        'first',
      ]);
    },
  );

  test('a second server joins the same local profile', () async {
    build();
    await add(_node('first'));
    final profile = container.read(profilesProvider).single;
    container.read(currentProfileIdProvider.notifier).value = profile.id;

    await add(_node('second'));

    expect(container.read(profilesProvider), hasLength(1));
    expect((await outboundsOf(profile)).map((node) => node['tag']), [
      'first',
      'second',
    ]);
    expect(
      (container.read(setupActionProvider.notifier) as _NoopSetupAction)
          .applied,
      2,
    );
  });

  test('a server with a name already taken is renamed, not replaced', () async {
    build();
    await add(_node('same'));
    final profile = container.read(profilesProvider).single;

    await add(_node('same'));

    final tags = (await outboundsOf(profile)).map((node) => node['tag']);
    expect(tags.toSet(), hasLength(2));
    expect(tags, contains('same'));
  });

  test('a subscription in use is left alone for the local profile', () async {
    final subscription = Profile.normal(
      label: 'sub',
      url: 'https://example.com/sub',
    );
    final local = Profile.normal(label: 'mine');
    build(profiles: [subscription, local], current: subscription.id);

    await add(_node('typed'));

    final saved = container
        .read(profilesProvider)
        .firstWhere((profile) => profile.id == local.id);
    expect((await outboundsOf(saved)).map((node) => node['tag']), ['typed']);
    expect(container.read(currentProfileIdProvider), subscription.id);
  });

  group('replaceNode', () {
    Future<Profile> twoNodes() async {
      build();
      await add(_node('first'));
      await add(_node('second'));
      return container.read(profilesProvider).single;
    }

    Future<void> replace(
      Profile profile,
      String tag,
      Map<String, dynamic> outbound,
    ) {
      return container
          .read(profilesActionProvider.notifier)
          .replaceNode(profile, tag, outbound);
    }

    test('changes the one node and leaves the rest', () async {
      final profile = await twoNodes();
      final changed = _node('first')
        ..['settings'] = {..._node('first')['settings'] as Map, 'port': 9999};

      await replace(profile, 'first', changed);

      final nodes = await outboundsOf(profile);
      expect(nodes.map((node) => node['tag']), ['first', 'second']);
      expect((nodes.first['settings'] as Map)['port'], 9999);
      expect((nodes.last['settings'] as Map)['port'], 8388);
    });

    test('a changed country reaches the node list at once', () async {
      final profile = await twoNodes();
      container.listen(groupsProvider, (_, _) {});

      await replace(profile, 'first', {..._node('first'), 'region': 'DE'});

      final nodes = container.read(groupsProvider).getGroup(nodeGroupName)?.all;
      expect(nodes?.firstWhere((node) => node.name == 'first').region, 'DE');
      expect(nodes?.firstWhere((node) => node.name == 'second').region, isNull);
    });

    test('a renamed node stays the chosen one', () async {
      final profile = await twoNodes();
      container
          .read(profilesProvider.notifier)
          .put(profile.copyWith(selectedMap: {nodeGroupName: 'second'}));

      await replace(
        container.read(profilesProvider).single,
        'second',
        _node('renamed'),
      );

      final saved = container.read(profilesProvider).single;
      expect(saved.selectedMap[nodeGroupName], 'renamed');
      expect((await outboundsOf(saved)).map((node) => node['tag']), [
        'first',
        'renamed',
      ]);
    });

    test('a name another node has is refused and nothing changes', () async {
      final profile = await twoNodes();

      await replace(profile, 'second', _node('first'));

      expect((await outboundsOf(profile)).map((node) => node['tag']), [
        'first',
        'second',
      ]);
    });

    test('reads a node back by its name', () async {
      final profile = await twoNodes();
      final actions = container.read(profilesActionProvider.notifier);

      expect(
        (await actions.readNodeOutbound(profile, 'second'))?['tag'],
        'second',
      );
      expect(await actions.readNodeOutbound(profile, 'gone'), isNull);
    });
  });
}
