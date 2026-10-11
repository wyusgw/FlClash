import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/request.dart';
import 'package:path/path.dart' show join;

import 'file.dart';
import 'path.dart';
import 'print.dart';
import 'subscription.dart';

const _service = 'https://api.country.is/';
const _concurrency = 3;
const _retryAfter = Duration(minutes: 10);

/// The country a server is in, found by asking a GeoIP service about its
/// address once and keeping the answer on disk. It sends the address to that
/// service, so callers ask only when the user allows it.
class GeoRegionResolver {
  final _cache = <String, String>{};
  final _inflight = <String, Future<String?>>{};
  final _failed = <String, DateTime>{};
  final _waiting = Queue<Completer<void>>();
  var _running = 0;
  Future<void>? _loading;

  Future<File> get _file async =>
      File(join(await appPath.homeDirPath, 'geo_regions.json'));

  Future<void> _load() {
    return _loading ??= () async {
      try {
        final file = await _file;
        if (!await file.exists()) return;
        final data = json.decode(await file.readAsString());
        if (data is Map) {
          for (final entry in data.entries) {
            _cache['${entry.key}'] = '${entry.value}';
          }
        }
      } on Object {
        // A cache that cannot be read is asked for again.
      }
    }();
  }

  Future<void> _save() async {
    try {
      await (await _file).safeWriteAsString(json.encode(_cache));
    } on Object catch (error) {
      commonPrint.log('geo region cache not saved: $error');
    }
  }

  /// The alpha-2 code of the country [host] is in; null when it has none to
  /// ask about (a private address) or the service could not say.
  Future<String?> resolve(String host) async {
    await _load();
    final cached = _cache[host];
    if (cached != null) return cached.isEmpty ? null : cached;
    final failed = _failed[host];
    if (failed != null && DateTime.now().difference(failed) < _retryAfter) {
      return null;
    }
    return _inflight[host] ??= _fetch(host).whenComplete(() {
      _inflight.remove(host);
    });
  }

  Future<String?> _fetch(String host) async {
    final address = await _publicAddress(host);
    if (address == null) {
      _cache[host] = '';
      await _save();
      return null;
    }
    await _acquire();
    try {
      final response = await request.dio.get<Object?>(
        '$_service${address.address}',
        options: Options(
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      final data = response.data;
      final country = data is Map ? '${data['country'] ?? ''}' : '';
      if (!RegExp(r'^[A-Za-z]{2}$').hasMatch(country)) {
        _failed[host] = DateTime.now();
        return null;
      }
      _cache[host] = country.toUpperCase();
      await _save();
      return _cache[host];
    } on Object catch (error) {
      commonPrint.log('geo region of $host failed: ${compactError(error)}');
      _failed[host] = DateTime.now();
      return null;
    } finally {
      _release();
    }
  }

  /// The address worth asking about: [host] itself when it is one, else what
  /// its name resolves to; null for a private or unresolvable one.
  Future<InternetAddress?> _publicAddress(String host) async {
    if (isPrivateHost(host) && !host.contains(':')) return null;
    final literal = InternetAddress.tryParse(host);
    List<InternetAddress> addresses;
    try {
      addresses = literal == null
          ? await InternetAddress.lookup(host)
          : [literal];
    } on SocketException {
      return null;
    }
    for (final address in addresses) {
      if (_isPublic(address)) return address;
    }
    return null;
  }

  bool _isPublic(InternetAddress address) {
    if (address.isLoopback || address.isLinkLocal || address.isMulticast) {
      return false;
    }
    final bytes = address.rawAddress;
    if (address.type == InternetAddressType.IPv6) {
      return (bytes.first & 0xFE) != 0xFC && !bytes.every((byte) => byte == 0);
    }
    return !isPrivateHost(address.address) &&
        bytes.first != 0 &&
        !(bytes[0] == 100 && bytes[1] >= 64 && bytes[1] < 128);
  }

  Future<void> _acquire() {
    if (_running < _concurrency) {
      _running++;
      return Future.value();
    }
    final waiter = Completer<void>();
    _waiting.add(waiter);
    return waiter.future;
  }

  void _release() {
    if (_waiting.isNotEmpty) {
      _waiting.removeFirst().complete();
      return;
    }
    _running--;
  }
}

final geoRegion = GeoRegionResolver();

/// What a node's address holds apart from its port: `host:port` as the node
/// list shows it, or a bracket-free IPv6 address with its port.
String? hostOfAddress(String? address) {
  if (address == null || address.isEmpty) return null;
  final colon = address.lastIndexOf(':');
  if (colon < 0) return address;
  final head = address.substring(0, colon);
  return head.isEmpty ? address : head;
}
