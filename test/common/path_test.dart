import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;

  setUpAll(() {
    root = Directory.systemTemp.createTempSync('path_test');
    PathProviderPlatform.instance = _FakePathProvider(root.path);
  });

  tearDownAll(() {
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  });

  test('the Core config is the file the engine loads from its home', () async {
    final path = await appPath.configFilePath;

    expect(basename(path), 'config.json');
    expect(dirname(path), await appPath.homeDirPath);
  });

  test('a profile is stored as json under the profiles directory', () async {
    final path = await appPath.getProfilePath('7');

    expect(basename(path), '7.json');
    expect(dirname(path), await appPath.profilesPath);
  });

  test('the geo data the engine reads sits in the home directory', () async {
    final home = await appPath.homeDirPath;

    expect(join(home, geoIpFileName), endsWith('geoip.dat'));
    expect(join(home, geoSiteFileName), endsWith('geosite.dat'));
  });
}
