import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter_test/flutter_test.dart';
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

class _GeoAdapter implements HttpClientAdapter {
  final requested = <String>[];
  Map<String, Object?> answers = const {};
  bool fail = false;
  Set<String> down = const {};
  Map<String, List<String>> dns = const {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requested.add(options.uri.toString());
    if (fail || down.contains(options.uri.host)) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    if (options.uri.host == 'cloudflare-dns.com') {
      final name = options.uri.queryParameters['name'];
      return ResponseBody.fromString(
        jsonEncode({
          'Answer': [
            {'name': name, 'type': 5, 'data': 'alias.example.'},
            for (final ip in dns[name] ?? const <String>[])
              {'name': name, 'type': 1, 'data': ip},
          ],
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }
    final ip = options.uri.pathSegments.last;
    if (options.uri.host == 'ipwho.is') {
      return ResponseBody.fromString(
        jsonEncode({'ip': ip, 'success': true, 'country_code': 'KR'}),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }
    final body = answers[ip] ?? {'ip': ip, 'country': 'JP'};
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory home;
  late _GeoAdapter adapter;
  late HttpClientAdapter original;

  setUpAll(() async {
    home = Directory.systemTemp.createTempSync('geo_region_test');
    PathProviderPlatform.instance = _FakePathProvider(home.path);
    await appPath.homeDirPath;
  });

  tearDownAll(() => home.deleteSync(recursive: true));

  setUp(() {
    final file = File('${home.path}/geo_regions.json');
    if (file.existsSync()) file.deleteSync();
    adapter = _GeoAdapter();
    original = request.dio.httpClientAdapter;
    request.dio.httpClientAdapter = adapter;
    addTearDown(() => request.dio.httpClientAdapter = original);
  });

  test(
    'asks the service about a public address and upper-cases the code',
    () async {
      adapter.answers = {
        '8.8.8.8': {'ip': '8.8.8.8', 'country': 'us'},
      };

      expect(await GeoRegionResolver().resolve('8.8.8.8'), 'US');
      expect(adapter.requested, ['https://api.country.is/8.8.8.8']);
    },
  );

  test('never sends a private address anywhere', () async {
    final resolver = GeoRegionResolver();

    for (final host in [
      '10.0.0.5',
      '192.168.1.1',
      '127.0.0.1',
      'localhost',
      '::1',
      'fd00::1',
      '198.18.0.5',
    ]) {
      expect(await resolver.resolve(host), isNull, reason: host);
    }
    expect(adapter.requested, isEmpty);
  });

  test('keeps an answer, so the second ask costs nothing', () async {
    final resolver = GeoRegionResolver();

    await resolver.resolve('8.8.4.4');
    await resolver.resolve('8.8.4.4');

    expect(adapter.requested, hasLength(1));
  });

  test('keeps it across runs through the file', () async {
    await GeoRegionResolver().resolve('1.1.1.1');
    adapter.requested.clear();

    expect(await GeoRegionResolver().resolve('1.1.1.1'), 'JP');
    expect(adapter.requested, isEmpty);
  });

  test('asks once for a burst of the same address', () async {
    final resolver = GeoRegionResolver();

    final answers = await Future.wait([
      resolver.resolve('9.9.9.9'),
      resolver.resolve('9.9.9.9'),
      resolver.resolve('9.9.9.9'),
    ]);

    expect(answers, ['JP', 'JP', 'JP']);
    expect(adapter.requested, hasLength(1));
  });

  test('a failed ask gives nothing and is not repeated at once', () async {
    final resolver = GeoRegionResolver();
    adapter.fail = true;

    expect(await resolver.resolve('4.4.4.4'), isNull);
    expect(await resolver.resolve('4.4.4.4'), isNull);

    expect(adapter.requested, [
      'https://api.country.is/4.4.4.4',
      'https://ipwho.is/4.4.4.4',
    ]);
  });

  test('asks the next service when the first is down', () async {
    adapter.down = {'api.country.is'};

    expect(await GeoRegionResolver().resolve('6.6.6.6'), 'KR');
    expect(adapter.requested, [
      'https://api.country.is/6.6.6.6',
      'https://ipwho.is/6.6.6.6',
    ]);
  });

  test('an answer that is no country code is no answer', () async {
    adapter.down = {'ipwho.is'};
    adapter.answers = {
      '5.5.5.5': {'ip': '5.5.5.5', 'country': 'Narnia'},
    };

    expect(await GeoRegionResolver().resolve('5.5.5.5'), isNull);
  });

  group('a domain', () {
    // `.invalid` never resolves, so the system lookup gives nothing and the
    // name goes to the DNS-over-HTTPS service.
    const host = 'node.flclash.invalid';

    test('is resolved over HTTPS when the system cannot', () async {
      adapter.dns = {
        host: ['8.8.8.8'],
      };

      expect(await GeoRegionResolver().resolve(host), 'JP');
      expect(adapter.requested, [
        'https://cloudflare-dns.com/dns-query?name=$host&type=A',
        'https://api.country.is/8.8.8.8',
      ]);
    });

    test('is not flagged by a fake or private answer', () async {
      adapter.dns = {
        host: ['198.18.0.9', '10.0.0.7'],
      };

      expect(await GeoRegionResolver().resolve(host), isNull);
      expect(
        adapter.requested.where((url) => url.contains('country.is')),
        isEmpty,
      );
    });

    test('that did not resolve is not kept as having no country', () async {
      expect(await GeoRegionResolver().resolve(host), isNull);

      adapter.dns = {
        host: ['8.8.8.8'],
      };
      expect(await GeoRegionResolver().resolve(host), 'JP');
    });
  });

  group('hostOfAddress', () {
    test('drops the port', () {
      expect(hostOfAddress('jp.example.com:443'), 'jp.example.com');
      expect(hostOfAddress('1.2.3.4:8388'), '1.2.3.4');
    });

    test('keeps a bare host and reads nothing from nothing', () {
      expect(hostOfAddress('jp.example.com'), 'jp.example.com');
      expect(hostOfAddress(null), isNull);
      expect(hostOfAddress(''), isNull);
    });
  });
}
