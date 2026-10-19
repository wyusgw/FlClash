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
const _resolver = 'https://cloudflare-dns.com/dns-query';
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
            final host = '${entry.key}';
            // An empty answer kept for a public name came from a lookup that
            // failed, so it is asked again.
            if ('${entry.value}'.isEmpty && !isPrivateHost(host)) continue;
            _cache[host] = '${entry.value}';
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
    if (isPrivateHost(host) && !host.contains(':')) {
      _cache[host] = '';
      await _save();
      return null;
    }
    final address = await _publicAddress(host);
    if (address == null) {
      // A name that did not resolve now may resolve later, so it is asked
      // again after a while instead of being kept as having no country.
      _failed[host] = DateTime.now();
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
  /// its name resolves to; null for a private or unresolvable one. A name the
  /// system answers with a fake or private address, as it does behind a TUN or
  /// a fake-IP resolver, is asked of a DNS-over-HTTPS service instead.
  Future<InternetAddress?> _publicAddress(String host) async {
    final literal = InternetAddress.tryParse(host);
    if (literal != null) return _isPublic(literal) ? literal : null;
    try {
      for (final address in await InternetAddress.lookup(host)) {
        if (_isPublic(address)) return address;
      }
    } on SocketException {
      // Falls through to the DNS-over-HTTPS answer.
    }
    return _lookupOverHttps(host);
  }

  Future<InternetAddress?> _lookupOverHttps(String host) async {
    try {
      final response = await request.dio.get<Object?>(
        _resolver,
        queryParameters: {'name': host, 'type': 'A'},
        options: Options(
          responseType: ResponseType.json,
          headers: {'accept': 'application/dns-json'},
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      final data = response.data;
      final answers = data is Map ? data['Answer'] : null;
      if (answers is! List) return null;
      for (final answer in answers) {
        if (answer is! Map || answer['type'] != 1) continue;
        final address = InternetAddress.tryParse('${answer['data']}');
        if (address != null && _isPublic(address)) return address;
      }
    } on Object catch (error) {
      commonPrint.log('dns of $host failed: ${compactError(error)}');
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
        !(bytes[0] == 100 && bytes[1] >= 64 && bytes[1] < 128) &&
        !(bytes[0] == 198 && (bytes[1] & 0xFE) == 18);
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
