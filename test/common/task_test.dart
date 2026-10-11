import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';

int _double(int value) => value * 2;

void main() {
  test('encoding helpers round-trip structured data', () async {
    final encoded = await encodeJSONTask({
      'name': 'FlClash',
      'values': [1, true, null],
    });
    final decoded = await decodeJSONTask<Map<String, dynamic>>(encoded);

    expect(decoded['name'], 'FlClash');
    expect(decoded['values'], [1, true, null]);
    expect(await encodeMD5Task('abc'), '900150983cd24fb0d6963f7d28e17f72');
  });

  test('toGroupsTask puts the nodes in one sorted list', () async {
    final groups = await toGroupsTask(
      const ComputeGroupsState(
        nodes: [
          Proxy(name: 'Zulu', type: 'vless'),
          Proxy(name: 'Beta', type: 'trojan'),
        ],
        sortType: ProxiesSortType.name,
        delayMap: {},
        selectedMap: {},
        defaultTestUrl: 'https://example.com/generate_204',
      ),
    );

    expect(groups, hasLength(1));
    expect(groups.single.name, nodeGroupName);
    expect(groups.single.all.map((proxy) => proxy.name), ['Beta', 'Zulu']);
  });

  test('toGroupsTask returns empty data without nodes', () async {
    final groups = await toGroupsTask(
      const ComputeGroupsState(
        nodes: [],
        sortType: ProxiesSortType.none,
        delayMap: {},
        selectedMap: {},
        defaultTestUrl: '',
      ),
    );

    expect(groups, isEmpty);
  });

  test('makeRealProfileTask builds the config off the main isolate', () async {
    final result = await makeRealProfileTask(
      MakeRealProfileState(
        outbounds: parseSubscription(
          'trojan://pass@tj.example.com:443?security=tls#node-a',
        ),
        coreConfig: const CoreConfig(),
        routeMode: RouteMode.config,
      ),
    );

    final config = await decodeJSONTask<Map<String, dynamic>>(result.json);
    expect(
      (config['outbounds'] as List).map((item) => (item as Map)['tag']),
      containsAll(['node-a', directOutboundTag]),
    );
    expect(result.md5, await encodeMD5Task(result.json));
  });

  group('shakeOrphanFiles', () {
    late Directory dir;

    setUp(() => dir = Directory.systemTemp.createTempSync('shake'));

    tearDown(() => dir.deleteSync(recursive: true));

    test('names the profile files no profile owns', () {
      for (final name in ['1.json', '2.json', 'stale.json', '3.yaml']) {
        File(join(dir.path, name)).writeAsStringSync('x');
      }

      final targets = shakeOrphanFiles(
        profileIds: const [1, 2],
        profilesDirPath: dir.path,
      );

      expect(targets.map(basename).toSet(), {'stale.json', '3.yaml'});
    });

    test('a missing directory has nothing to shake', () {
      expect(
        shakeOrphanFiles(
          profileIds: const [1],
          profilesDirPath: join(dir.path, 'missing'),
        ),
        isEmpty,
      );
    });
  });

  test('log and list tasks produce stable mapped output', () async {
    final logs = [
      const Log(
        logLevel: LogLevel.info,
        payload: 'first',
        dateTime: '2026-07-26 10:00:00',
      ),
      const Log(
        logLevel: LogLevel.error,
        payload: 'second',
        dateTime: '2026-07-26 10:00:01',
      ),
    ];

    final encoded = await encodeLogsTask(logs);

    expect(encoded, contains('first'));
    expect(encoded, contains('\n'));
    expect(await mapListTask([1, 2, 3], _double), [2, 4, 6]);
  });
}
