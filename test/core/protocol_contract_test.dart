import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/core/event.dart';
import 'package:fl_clash/core/desktop/model.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingCoreHandler extends CoreHandlerInterface {
  final Map<CoreMethod, Object?> calls = {};

  @override
  Future<CoreLifecycleResult> start() async => const CoreLifecycleResult(
    revision: 1,
    outcome: CoreLifecycleOutcome.applied,
  );

  @override
  Future<CoreLifecycleResult> restart() => start();

  @override
  Future<CoreLifecycleResult> stop() => start();

  @override
  Future<CoreLifecycleResult> close() => start();

  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    calls[method] = arguments;
    final result = switch (method) {
      CoreMethod.initCore => true as T,
      CoreMethod.getTraffic ||
      CoreMethod.getTotalTraffic => {'up': 12, 'down': 34},
      CoreMethod.asyncTestDelay => {
        'name': '@direct',
        'url': 'https://example.com',
        'value': 42,
      },
      CoreMethod.probe => {
        'status-code': 204,
        'delay': 17,
        'body': '',
        'url': 'https://example.com/',
        'chains': ['@direct'],
        'rule': '',
        'rule-payload': '',
      },
      CoreMethod.getMemoryStats => {
        'rss': 2048,
        'heapInuse': 1024,
        'heapIdle': 256,
        'stackInuse': 64,
        'runtimeOther': 32,
      },
      CoreMethod.watchRoute => {
        'core-epoch': 1,
        'picks-version': 0,
        'picks': <String, String>{},
      },
      _ => '',
    };
    return result as T;
  }
}

Future<Map<String, dynamic>> _fixture() async {
  return json.decode(
        await File('test/fixtures/core_protocol.json').readAsString(),
      )
      as Map<String, dynamic>;
}

void main() {
  test('method call keeps structured arguments', () async {
    final call = CoreMethodCall.fromJson(
      Map<String, Object?>.from((await _fixture())['methodCall'] as Map),
    );

    expect(call.method, CoreMethod.setupConfig);
    expect(call.arguments, isA<Map<String, dynamic>>());
    expect((call.arguments as Map)['log-level'], 'error');
    expect(call.toJson(), containsPair('arguments', call.arguments));
    expect(call.toJson(), isNot(contains('data')));
  });

  test('the setup parameters decode from what the fixture carries', () async {
    final call = CoreMethodCall.fromJson(
      Map<String, Object?>.from((await _fixture())['methodCall'] as Map),
    );

    final params = SetupParams.fromJson(
      Map<String, dynamic>.from(call.arguments as Map),
    );

    expect(params.testUrl, 'https://www.gstatic.com/generate_204');
    expect(params.logLevel, LogLevel.error);
    expect(params.toJson(), call.arguments);
  });

  test('core interface sends structured request parameters', () async {
    final handler = _RecordingCoreHandler();

    await handler.init(const InitParams(homeDir: '/tmp/flclash', version: 35));
    await handler.setupConfig(const SetupParams(testUrl: 'test'));
    final route = await handler.watchRoute(true);
    expect(route, const RouteSnapshot(coreEpoch: 1));
    expect(handler.calls[CoreMethod.watchRoute], isTrue);
    await handler.asyncTestDelay('https://example.com', '@direct');
    await handler.probe(
      const ProbeParams(
        url: 'https://example.com',
        proxyName: '@direct',
        timeout: 1000,
        maxBody: 64,
      ),
    );

    for (final method in [
      CoreMethod.initCore,
      CoreMethod.setupConfig,
      CoreMethod.asyncTestDelay,
      CoreMethod.probe,
    ]) {
      expect(handler.calls[method], isA<Map>());
    }
    expect(handler.calls[CoreMethod.probe], {
      'url': 'https://example.com',
      'proxy-name': '@direct',
      'headers': <String, String>{},
      'timeout': 1000,
      'max-body': 64,
    });
  });

  test('event contract accepts batches and legacy single events', () async {
    final call = CoreMethodCall.fromJson(
      Map<String, Object?>.from((await _fixture())['eventCall'] as Map),
    );

    final events = coreEventsFromData(call.arguments);
    expect(events, hasLength(2));
    expect(events.first.type, CoreEventType.log);
    expect(events.last.type, CoreEventType.delay);
    final log = Log.fromJson(
      Map<String, Object?>.from(events.first.data as Map),
    );
    expect(log.logLevel, LogLevel.warning);
    expect(log.payload, 'started');

    final legacy = coreEventsFromData({'type': 'crash', 'data': 'core done'});
    expect(legacy.single.data, 'core done');
  });

  test('event contract skips malformed entries without dropping the batch', () {
    final events = coreEventsFromData([
      {'type': 'crash', 'data': 'core-a'},
      {'type': 'invalid-event', 'data': null},
      {'type': 'crash', 'data': 'core-b'},
    ]);

    expect(events.map((event) => event.data), ['core-a', 'core-b']);
  });

  test('core interface converts structured method results', () async {
    final handler = _RecordingCoreHandler();

    expect(await handler.getTraffic(false), const Traffic(up: 12, down: 34));
    expect(
      await handler.getTotalTraffic(false),
      const Traffic(up: 12, down: 34),
    );
    expect(
      await handler.asyncTestDelay('https://example.com', '@direct'),
      const Delay(name: '@direct', url: 'https://example.com', value: 42),
    );
    expect(
      await handler.probe(
        const ProbeParams(url: 'https://example.com', timeout: 1000),
      ),
      const ProbeResult(
        statusCode: 204,
        delay: 17,
        url: 'https://example.com/',
        chains: ['@direct'],
      ),
    );
    final memory = await handler.getMemoryStats();
    expect(memory?.rss, 2048);
    expect(memory?.runtimeTotal, 1024 + 256 + 64 + 32);
  });

  test('method response separates result and structured errors', () async {
    final fixture = await _fixture();
    final success = CoreMethodResponse.fromJson(
      Map<String, Object?>.from(fixture['successResponse'] as Map),
    );
    final structured = CoreMethodResponse.fromJson(
      Map<String, Object?>.from(fixture['structuredResponse'] as Map),
    );
    final failure = CoreMethodResponse.fromJson(
      Map<String, Object?>.from(fixture['errorResponse'] as Map),
    );

    expect(success.unwrap<String>(), '');
    expect(success.toJson(), containsPair('result', ''));
    expect(structured.result, isA<Map>());
    expect(structured.result, isNot(isA<String>()));
    expect(structured.unwrap<Map<String, dynamic>>()?['up'], 12);
    expect(
      () => failure.unwrap<Object?>(),
      throwsA(
        isA<CoreMethodException>()
            .having((error) => error.code, 'code', 'core_error')
            .having((error) => error.message, 'message', 'config not found'),
      ),
    );
    expect(failure.toJson(), contains('error'));
    expect(failure.toJson(), isNot(contains('code')));
  });
}
