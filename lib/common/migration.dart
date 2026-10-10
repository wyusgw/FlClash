import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';

import 'preferences.dart';

abstract interface class MigrationStore {
  /// False when the backing store could not be opened at all, as opposed to a
  /// store that opened but holds nothing.
  Future<bool> get isAvailable;

  Future<Map<String, Object?>?> getConfigMap();

  Future<int> getVersion();

  Future<void> restore(MigrationData data);

  Future<bool> saveConfig(Config config);

  Future<void> setVersion(int version);
}

class _AppMigrationStore implements MigrationStore {
  const _AppMigrationStore();

  @override
  Future<bool> get isAvailable => preferences.isInit;

  @override
  Future<Map<String, Object?>?> getConfigMap() => preferences.getConfigMap();

  @override
  Future<int> getVersion() => preferences.getVersion();

  @override
  Future<void> restore(MigrationData data) {
    return database.restore(data.profiles);
  }

  @override
  Future<bool> saveConfig(Config config) => preferences.saveConfig(config);

  @override
  Future<void> setVersion(int version) => preferences.setVersion(version);
}

class Migration {
  final MigrationStore _store;

  Migration({required MigrationStore store}) : _store = store;

  static const currentVersion = 1;

  Future<Config> run() async {
    final configMap = await _store.getConfigMap();
    final oldVersion = await _store.getVersion();
    if (oldVersion > currentVersion) {
      throw StateError(
        'Local data version $oldVersion is newer than $currentVersion.',
      );
    }
    Config config;
    if (oldVersion == currentVersion) {
      try {
        config = Config.realFromJson(configMap);
      } catch (_) {
        throw StateError(
          'Local data is damaged. A reset is required to fix this issue.',
        );
      }
      final storedDavPassword = _getStoredDavPassword(configMap);
      final hasPlainTextDavPassword =
          storedDavPassword != null &&
          storedDavPassword == config.davProps?.password;
      if (hasPlainTextDavPassword && !await _store.saveConfig(config)) {
        throw StateError('Failed to obfuscate the legacy WebDAV password');
      }
      return config;
    }

    final data = MigrationData(configMap: configMap);
    config = Config.realFromJson(data.configMap);
    await _store.restore(data);
    if (!await _store.saveConfig(config)) {
      // An unopenable store is reported later by the corrupt-cache dialog,
      // which offers a reset; failing here would hide that path.
      if (await _store.isAvailable) {
        throw StateError('Failed to save migrated preferences');
      }
      return config;
    }
    await _store.setVersion(currentVersion);
    return config;
  }
}

String? _getStoredDavPassword(Map<String, Object?>? configMap) {
  final dav = configMap?['davProps'] ?? configMap?['dav'];
  if (dav is! Map) {
    return null;
  }
  final password = dav['password'];
  return password is String && password.isNotEmpty ? password : null;
}

final migration = Migration(store: const _AppMigrationStore());
