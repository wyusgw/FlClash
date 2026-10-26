import 'dart:async';
import 'dart:io';

/// The host and port of a `host:port` address, the host without the brackets
/// of an IPv6 literal, or null when the address is malformed.
({String host, int port})? splitHostPort(String? address) {
  final separator = address?.lastIndexOf(':') ?? -1;
  if (address == null || separator <= 0) {
    return null;
  }
  final port = int.tryParse(address.substring(separator + 1));
  if (port == null) {
    return null;
  }
  var host = address.substring(0, separator);
  if (host.startsWith('[') && host.endsWith(']')) {
    host = host.substring(1, host.length - 1);
  }
  return (host: host, port: port);
}

/// The milliseconds a TCP connect to `host:port` takes, or -1 when the address
/// is malformed, refuses, or does not answer within [timeout].
Future<int> tcpConnectDelay(String? address, Duration timeout) async {
  final target = splitHostPort(address);
  if (target == null) {
    return -1;
  }
  final watch = Stopwatch()..start();
  try {
    final socket = await Socket.connect(
      target.host,
      target.port,
      timeout: timeout,
    );
    watch.stop();
    socket.destroy();
    return watch.elapsedMilliseconds.clamp(1, timeout.inMilliseconds);
  } on Object {
    return -1;
  }
}
