import 'dart:convert';

import 'package:fl_clash/common/migration.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Migration', () {
    test('returns current config without rewriting storage', () async {
      final configMap = _createConfigMap(
        davProps: const DAVProps(
          uri: 'https://example.com/dav',
          user: 'user',
          password: 'secret',
        ),
      );
      final store = _FakeMigrationStore(
        configMap: configMap,
        version: Migration.currentVersion,
      );

      final config = await Migration(store: store).run();

      expect(config, Config.realFromJson(configMap));
      expect(config.davProps?.password, 'secret');
      expect(store.events, ['getConfigMap', 'getVersion']);
    });

    test(
      'obfuscates a compatible DAV password without a version migration',
      () async {
        final configMap = _createConfigMap(
          davProps: const DAVProps(
            uri: 'https://example.com/dav',
            user: 'user',
          ),
        );
        final davProps = configMap['davProps']! as Map<String, Object?>;
        davProps['password'] = 'secret';
        final store = _FakeMigrationStore(configMap: configMap, version: 1);

        final config = await Migration(store: store).run();

        expect(config.davProps?.user, 'user');
        expect(config.davProps?.password, 'secret');
        expect(store.savedConfig, config);
        expect(store.version, Migration.currentVersion);
        expect(store.events, ['getConfigMap', 'getVersion', 'saveConfig']);
        final savedConfigMap =
            jsonDecode(jsonEncode(store.savedConfig)) as Map<String, Object?>;
        final savedDavProps =
            savedConfigMap['davProps']! as Map<String, Object?>;
        expect(savedDavProps['password'], startsWith('v1.'));
        expect(savedDavProps['password'], isNot(contains('secret')));
      },
    );

    test('data saved before versioning is kept and then versioned', () async {
      final configMap = _createConfigMap(
        davProps: const DAVProps(
          uri: 'https://example.com/dav',
          user: 'user',
          password: 'secret',
        ),
      );
      final store = _FakeMigrationStore(configMap: configMap, version: 0);

      final config = await Migration(store: store).run();

      expect(config.davProps?.password, 'secret');
      expect(store.savedConfig, config);
      expect(store.version, Migration.currentVersion);
      expect(store.events, [
        'getConfigMap',
        'getVersion',
        'restore',
        'saveConfig',
        'setVersion',
      ]);
    });

    test('settings saved under the earlier engine name carry over', () async {
      final configMap = _createConfigMap();
      configMap['patchClashConfig'] = configMap.remove('coreConfig');
      (configMap['patchClashConfig']! as Map<String, Object?>)['mixed-port'] =
          1234;
      final store = _FakeMigrationStore(
        configMap: configMap,
        version: Migration.currentVersion,
      );

      final config = await Migration(store: store).run();

      expect(config.coreConfig.mixedPort, 1234);
    });

    test('does not set the version when saving fails', () async {
      final store = _FakeMigrationStore(
        configMap: _createConfigMap(),
        version: 0,
        configSaveResult: false,
      );

      await expectLater(
        Migration(store: store).run(),
        throwsA(isA<StateError>()),
      );

      expect(store.version, 0);
      expect(store.events, [
        'getConfigMap',
        'getVersion',
        'restore',
        'saveConfig',
        'isAvailable',
      ]);
    });

    test('starts with defaults when the store cannot be opened', () async {
      final store = _FakeMigrationStore(
        configMap: null,
        version: 0,
        configSaveResult: false,
        available: false,
      );

      final config = await Migration(store: store).run();

      expect(config, isNotNull);
      expect(store.version, 0);
      expect(store.events, [
        'getConfigMap',
        'getVersion',
        'restore',
        'saveConfig',
        'isAvailable',
      ]);
    });

    test('refuses data from a newer version', () async {
      final store = _FakeMigrationStore(
        configMap: _createConfigMap(),
        version: Migration.currentVersion + 1,
      );

      await expectLater(
        Migration(store: store).run(),
        throwsA(isA<StateError>()),
      );
      expect(store.events, ['getConfigMap', 'getVersion']);
    });

    test('keeps the current version when password obfuscation fails', () async {
      final configMap = _createConfigMap(
        davProps: const DAVProps(uri: 'https://example.com/dav', user: 'user'),
      );
      final davProps = configMap['davProps']! as Map<String, Object?>;
      davProps['password'] = 'secret';
      final store = _FakeMigrationStore(
        configMap: configMap,
        version: Migration.currentVersion,
        configSaveResult: false,
      );

      await expectLater(
        Migration(store: store).run(),
        throwsA(isA<StateError>()),
      );

      expect(store.events, ['getConfigMap', 'getVersion', 'saveConfig']);
      expect(store.version, Migration.currentVersion);
    });
  });
}

Map<String, Object?> _createConfigMap({DAVProps? davProps}) {
  return jsonDecode(
        jsonEncode(Config(themeProps: defaultThemeProps, davProps: davProps)),
      )
      as Map<String, Object?>;
}

class _FakeMigrationStore implements MigrationStore {
  final Map<String, Object?>? configMap;
  final bool configSaveResult;
  final bool available;
  final List<String> events = [];

  int version;
  Config? savedConfig;
  MigrationData? restoredData;

  _FakeMigrationStore({
    required this.configMap,
    required this.version,
    this.configSaveResult = true,
    this.available = true,
  });

  @override
  Future<bool> get isAvailable async {
    events.add('isAvailable');
    return available;
  }

  @override
  Future<Map<String, Object?>?> getConfigMap() async {
    events.add('getConfigMap');
    return configMap;
  }

  @override
  Future<int> getVersion() async {
    events.add('getVersion');
    return version;
  }

  @override
  Future<void> restore(MigrationData data) async {
    events.add('restore');
    restoredData = data;
  }

  @override
  Future<bool> saveConfig(Config config) async {
    events.add('saveConfig');
    savedConfig = config;
    return configSaveResult;
  }

  @override
  Future<void> setVersion(int version) async {
    events.add('setVersion');
    this.version = version;
  }
}
