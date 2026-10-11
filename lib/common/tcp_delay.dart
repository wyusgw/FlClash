import 'dart:async';
import 'dart:io';

/// The milliseconds a TCP connect to `host:port` takes, or -1 when the address
/// is malformed, refuses, or does not answer within [timeout].
Future<int> tcpConnectDelay(String? address, Duration timeout) async {
  final separator = address?.lastIndexOf(':') ?? -1;
  if (address == null || separator <= 0) {
    return -1;
  }
  final port = int.tryParse(address.substring(separator + 1));
  if (port == null) {
    return -1;
  }
  var host = address.substring(0, separator);
  if (host.startsWith('[') && host.endsWith(']')) {
    host = host.substring(1, host.length - 1);
  }
  final watch = Stopwatch()..start();
  try {
    final socket = await Socket.connect(host, port, timeout: timeout);
    watch.stop();
    socket.destroy();
    return watch.elapsedMilliseconds.clamp(1, timeout.inMilliseconds);
  } on Object {
    return -1;
  }
}
