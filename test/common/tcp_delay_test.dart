import 'dart:io';

import 'package:fl_clash/common/tcp_delay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tcpConnectDelay', () {
    late ServerSocket server;

    setUp(() async {
      server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    });

    tearDown(() => server.close());

    test('measures a connect to a listening port', () async {
      final delay = await tcpConnectDelay(
        '127.0.0.1:${server.port}',
        const Duration(seconds: 2),
      );

      expect(delay, greaterThanOrEqualTo(1));
      expect(delay, lessThan(2000));
    });

    test('reads a bracketed IPv6 host', () async {
      final v6 = await ServerSocket.bind(InternetAddress.loopbackIPv6, 0);
      addTearDown(v6.close);

      final delay = await tcpConnectDelay(
        '[::1]:${v6.port}',
        const Duration(seconds: 2),
      );

      expect(delay, greaterThanOrEqualTo(1));
    });

    test('reports -1 for a port nothing listens on', () async {
      final port = server.port;
      await server.close();

      expect(
        await tcpConnectDelay('127.0.0.1:$port', const Duration(seconds: 2)),
        -1,
      );
    });

    test('reports -1 for an address that is not host:port', () async {
      expect(await tcpConnectDelay(null, const Duration(seconds: 1)), -1);
      expect(
        await tcpConnectDelay('example.com', const Duration(seconds: 1)),
        -1,
      );
      expect(await tcpConnectDelay(':443', const Duration(seconds: 1)), -1);
      expect(await tcpConnectDelay('host:abc', const Duration(seconds: 1)), -1);
    });
  });
}
