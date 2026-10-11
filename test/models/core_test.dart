import 'dart:convert';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('SetupParams', () {
    test('fromJson uses snake-case keys', () {
      final json = {
        'test-url': 'http://test.com',
        'log-level': 'debug',
      };
      final params = SetupParams.fromJson(json);
      expect(params.testUrl, 'http://test.com');
      expect(params.logLevel, LogLevel.debug);
    });

    test('the log level defaults to error', () {
      final params = SetupParams.fromJson({
        'test-url': 'http://test.com',
      });
      expect(params.logLevel, LogLevel.error);
    });

    test('toJson uses snake-case keys', () {
      const params = SetupParams(
        testUrl: 'http://t.com',
        logLevel: LogLevel.warning,
      );
      final json = params.toJson();
      expect(json['test-url'], 'http://t.com');
      expect(json['log-level'], 'warning');
    });
  });

  group('InitParams', () {
    test('fromJson and toJson', () {
      final json = {'home-dir': '/data/clash', 'version': 3};
      final params = InitParams.fromJson(json);
      expect(params.homeDir, '/data/clash');
      expect(params.version, 3);
      final restored = jsonDecode(jsonEncode(params.toJson()));
      expect(restored['home-dir'], '/data/clash');
      expect(restored['version'], 3);
    });
  });

  group('Delay', () {
    test('fromJson and toJson', () {
      final json = {'name': 'P1', 'url': 'test.com', 'value': 42};
      final delay = Delay.fromJson(json);
      expect(delay.name, 'P1');
      expect(delay.url, 'test.com');
      expect(delay.value, 42);
      final out = delay.toJson();
      expect(out['value'], 42);
    });

    test('null value', () {
      final delay = Delay.fromJson({'name': 'P1', 'url': 'test.com'});
      expect(delay.value, null);
    });
  });

  group('Now', () {
    test('fromJson and toJson', () {
      final now = Now.fromJson({'name': 'test', 'value': '123'});
      expect(now.name, 'test');
      expect(now.value, '123');
    });
  });

  group('CoreEvent', () {
    test('fromJson with type and data', () {
      final event = CoreEvent.fromJson({'type': 'log', 'data': 'test log'});
      expect(event.type, CoreEventType.log);
      expect(event.data, 'test log');
    });
  });

  group('InvokeMessage', () {
    test('fromJson', () {
      final msg = InvokeMessage.fromJson({
        'type': 'protect',
        'data': {'method': 'test'},
      });
      expect(msg.type, InvokeMessageType.protect);
    });
  });
}
