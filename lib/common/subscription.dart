import 'dart:convert';

/// The outbound protocols a subscription entry may name.
const supportedOutboundProtocols = {
  'vless',
  'vmess',
  'trojan',
  'shadowsocks',
  'hysteria',
  'tuic',
  'anytls',
};

const _shadowsocksMethods = {
  '2022-blake3-aes-128-gcm',
  '2022-blake3-aes-256-gcm',
  '2022-blake3-chacha20-poly1305',
  'aes-128-gcm',
  'aes-256-gcm',
  'chacha20-poly1305',
  'chacha20-ietf-poly1305',
  'xchacha20-poly1305',
};

/// Reads a subscription into Xray outbounds, one per usable node.
///
/// Three shapes are understood: an Xray config (or a list of outbounds) as
/// JSON, a base64 blob of share links, and the share links themselves, one per
/// line. Nodes that cannot be expressed as an Xray outbound are skipped.
List<Map<String, dynamic>> parseSubscription(String content) {
  final text = content.trim().replaceFirst('\u{feff}', '');
  if (text.isEmpty) {
    return const [];
  }
  final nodes = text.startsWith('{') || text.startsWith('[')
      ? _fromJson(text)
      : _fromLinks(_linkLines(text));
  return _uniqueTags(nodes);
}

List<Map<String, dynamic>> _fromJson(String text) {
  final Object? decoded;
  try {
    decoded = json.decode(text);
  } on FormatException {
    return const [];
  }
  final Object? outbounds = decoded is Map ? decoded['outbounds'] : decoded;
  if (outbounds is! List) {
    return const [];
  }
  final nodes = <Map<String, dynamic>>[];
  for (final item in outbounds.whereType<Map>()) {
    final node = Map<String, dynamic>.from(item);
    final protocol = '${node['protocol']}'.toLowerCase();
    if (!supportedOutboundProtocols.contains(protocol)) {
      continue;
    }
    node['protocol'] = protocol;
    nodes.add(node);
  }
  return nodes;
}

List<String> _linkLines(String text) {
  var lines = text.split(RegExp(r'[\r\n]+'));
  if (!lines.any((line) => line.contains('://'))) {
    final decoded = _decodeBase64(text);
    if (decoded != null) {
      lines = decoded.split(RegExp(r'[\r\n]+'));
    }
  }
  return lines
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}

List<Map<String, dynamic>> _fromLinks(List<String> lines) {
  final nodes = <Map<String, dynamic>>[];
  for (final line in lines) {
    final node = parseShareLink(line);
    if (node != null) {
      nodes.add(node);
    }
  }
  return nodes;
}

/// Turns one share link into an outbound, or null when the link is not a
/// supported node.
Map<String, dynamic>? parseShareLink(String link) {
  final separator = link.indexOf('://');
  if (separator <= 0) {
    return null;
  }
  final scheme = link.substring(0, separator).toLowerCase();
  final body = link.substring(separator + 3);
  try {
    return switch (scheme) {
      'vmess' => _vmess(body),
      'vless' => _vless(Uri.parse(link)),
      'trojan' => _trojan(Uri.parse(link)),
      'ss' => _shadowsocks(body),
      'hysteria2' || 'hy2' => _hysteria(Uri.parse(link)),
      'tuic' => _tuic(Uri.parse(link)),
      'anytls' => _anytls(Uri.parse(link)),
      _ => null,
    };
  } on FormatException {
    return null;
  }
}

String? _decodeBase64(String value) {
  var normalized = value.trim().replaceAll(RegExp(r'\s+'), '');
  normalized = normalized.replaceAll('-', '+').replaceAll('_', '/');
  final padding = normalized.length % 4;
  if (padding == 1) {
    return null;
  }
  if (padding != 0) {
    normalized = normalized.padRight(normalized.length + 4 - padding, '=');
  }
  try {
    return utf8.decode(base64.decode(normalized), allowMalformed: true);
  } on FormatException {
    return null;
  }
}

int? _port(Object? value) {
  final port = value is int ? value : int.tryParse('$value');
  return port != null && port > 0 && port < 65536 ? port : null;
}

String _name(Uri uri) => Uri.decodeComponent(uri.fragment).trim();

String _defaultName(String protocol, String host, int port) =>
    '$protocol-$host:$port';

String? _param(Map<String, String> query, List<String> keys) {
  for (final key in keys) {
    final value = query[key];
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }
  return null;
}

bool _truthy(String? value) => value == '1' || value?.toLowerCase() == 'true';

List<String>? _list(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

/// A name or address Xray treats as private: it lets a node skip TLS.
bool _isPrivateHost(String host) {
  final lower = host.toLowerCase();
  if (lower == 'localhost' ||
      lower.endsWith('.local') ||
      lower.endsWith('.lan') ||
      !lower.contains('.')) {
    return true;
  }
  final octets = lower.split('.').map(int.tryParse).toList();
  if (octets.length == 4 && octets.every((item) => item != null)) {
    final a = octets[0]!;
    final b = octets[1]!;
    return a == 10 ||
        a == 127 ||
        (a == 172 && b >= 16 && b < 32) ||
        (a == 192 && b == 168) ||
        (a == 169 && b == 254);
  }
  return false;
}

Map<String, dynamic>? _transport({
  required String? network,
  required String? security,
  required String host,
  required Map<String, String> query,
}) {
  final type = (network ?? 'tcp').toLowerCase();
  final stream = <String, dynamic>{};
  final path = _param(query, ['path']);
  final hostHeader = _param(query, ['host']);
  switch (type) {
    case 'tcp' || 'raw':
      if (_param(query, ['headerType']) == 'http') {
        stream['network'] = 'raw';
        stream['rawSettings'] = {
          'header': {
            'type': 'http',
            'request': {
              'path': [path ?? '/'],
              if (hostHeader != null) 'headers': {'Host': _list(hostHeader)},
            },
          },
        };
      }
    case 'ws' || 'websocket':
      stream['network'] = 'ws';
      stream['wsSettings'] = {'path': ?path, 'host': ?hostHeader};
    case 'httpupgrade':
      stream['network'] = 'httpupgrade';
      stream['httpupgradeSettings'] = {'path': ?path, 'host': ?hostHeader};
    case 'xhttp' || 'splithttp':
      stream['network'] = 'xhttp';
      stream['xhttpSettings'] = {
        'path': ?path,
        'host': ?hostHeader,
        'mode': ?_param(query, ['mode']),
      };
    case 'grpc':
      stream['network'] = 'grpc';
      stream['grpcSettings'] = {
        'serviceName':
            _param(query, ['serviceName', 'service_name', 'path']) ?? '',
        'multiMode': _param(query, ['mode']) == 'multi',
      };
    default:
      return null;
  }

  final fingerprint = _param(query, ['fp', 'fingerprint']);
  final serverName = _param(query, ['sni', 'peer', 'serverName']) ?? hostHeader;
  switch (security) {
    case 'tls':
      stream['security'] = 'tls';
      stream['tlsSettings'] = {
        'serverName': serverName ?? host,
        'alpn': ?_list(_param(query, ['alpn'])),
        'fingerprint': ?fingerprint,
        if (_truthy(_param(query, ['allowInsecure', 'insecure'])))
          'allowInsecure': true,
      };
    case 'reality':
      final publicKey = _param(query, ['pbk', 'publicKey']);
      if (publicKey == null) {
        return null;
      }
      stream['security'] = 'reality';
      stream['realitySettings'] = {
        'serverName': serverName ?? host,
        'fingerprint': fingerprint ?? 'chrome',
        'publicKey': publicKey,
        'shortId': _param(query, ['sid', 'shortId']) ?? '',
        'spiderX': _param(query, ['spx', 'spiderX']) ?? '/',
      };
    default:
      break;
  }
  return stream;
}

Map<String, dynamic>? _vmess(String body) {
  final decoded = _decodeBase64(body.split('#').first);
  if (decoded == null) {
    return null;
  }
  final Object? raw = json.decode(decoded);
  if (raw is! Map) {
    return null;
  }
  final host = '${raw['add'] ?? ''}'.trim();
  final port = _port(raw['port']);
  final id = '${raw['id'] ?? ''}'.trim();
  if (host.isEmpty || port == null || id.isEmpty) {
    return null;
  }
  final tls = '${raw['tls'] ?? ''}';
  final query = <String, String>{
    for (final entry in {
      'path': raw['path'],
      'host': raw['host'],
      'sni': raw['sni'],
      'alpn': raw['alpn'],
      'fp': raw['fp'],
      'headerType': raw['type'],
      'mode': raw['mode'],
    }.entries)
      if (entry.value != null && '${entry.value}'.isNotEmpty)
        entry.key: '${entry.value}',
  };
  final stream = _transport(
    network: '${raw['net'] ?? 'tcp'}',
    security: tls == 'tls' ? 'tls' : null,
    host: host,
    query: query,
  );
  if (stream == null) {
    return null;
  }
  final security = '${raw['scy'] ?? 'auto'}';
  return {
    'tag': '${raw['ps'] ?? ''}'.trim().isEmpty
        ? _defaultName('vmess', host, port)
        : '${raw['ps']}'.trim(),
    'protocol': 'vmess',
    'settings': {
      'address': host,
      'port': port,
      'id': id,
      'security':
          const {'auto', 'aes-128-gcm', 'chacha20-poly1305'}.contains(security)
          ? security
          : 'auto',
    },
    if (stream.isNotEmpty) 'streamSettings': stream,
  };
}

Map<String, dynamic>? _vless(Uri uri) {
  final id = Uri.decodeComponent(uri.userInfo);
  final port = _port(uri.port);
  if (id.isEmpty || uri.host.isEmpty || port == null) {
    return null;
  }
  final query = uri.queryParameters;
  final security = _param(query, ['security']);
  final encryption = _param(query, ['encryption']) ?? 'none';
  if (encryption == 'none' &&
      (security == null || security == 'none') &&
      !_isPrivateHost(uri.host)) {
    return null;
  }
  final stream = _transport(
    network: _param(query, ['type']),
    security: security,
    host: uri.host,
    query: query,
  );
  if (stream == null) {
    return null;
  }
  return {
    'tag': _name(uri).isEmpty
        ? _defaultName('vless', uri.host, port)
        : _name(uri),
    'protocol': 'vless',
    'settings': {
      'address': uri.host,
      'port': port,
      'id': id,
      'encryption': encryption,
      if (_param(query, ['flow']) != null) 'flow': _param(query, ['flow']),
    },
    if (stream.isNotEmpty) 'streamSettings': stream,
  };
}

Map<String, dynamic>? _trojan(Uri uri) {
  final password = Uri.decodeComponent(uri.userInfo);
  final port = _port(uri.port);
  if (password.isEmpty || uri.host.isEmpty || port == null) {
    return null;
  }
  final query = uri.queryParameters;
  final security = _param(query, ['security']) ?? 'tls';
  final stream = _transport(
    network: _param(query, ['type']),
    security: security,
    host: uri.host,
    query: query,
  );
  if (stream == null) {
    return null;
  }
  return {
    'tag': _name(uri).isEmpty
        ? _defaultName('trojan', uri.host, port)
        : _name(uri),
    'protocol': 'trojan',
    'settings': {'address': uri.host, 'port': port, 'password': password},
    if (stream.isNotEmpty) 'streamSettings': stream,
  };
}

Map<String, dynamic>? _shadowsocks(String body) {
  var rest = body;
  var name = '';
  final hash = rest.indexOf('#');
  if (hash >= 0) {
    name = Uri.decodeComponent(rest.substring(hash + 1)).trim();
    rest = rest.substring(0, hash);
  }
  var query = <String, String>{};
  final question = rest.indexOf('?');
  if (question >= 0) {
    query = Uri.splitQueryString(rest.substring(question + 1));
    rest = rest.substring(0, question);
  }
  if (query['plugin']?.isNotEmpty == true) {
    return null;
  }
  rest = rest.replaceAll(RegExp(r'/+$'), '');

  String credentials;
  String hostPort;
  final at = rest.lastIndexOf('@');
  if (at >= 0) {
    credentials = rest.substring(0, at);
    hostPort = rest.substring(at + 1);
    if (!credentials.contains(':')) {
      credentials = _decodeBase64(credentials) ?? credentials;
    } else {
      credentials = Uri.decodeComponent(credentials);
    }
  } else {
    final decoded = _decodeBase64(rest);
    final decodedAt = decoded?.lastIndexOf('@') ?? -1;
    if (decoded == null || decodedAt < 0) {
      return null;
    }
    credentials = decoded.substring(0, decodedAt);
    hostPort = decoded.substring(decodedAt + 1);
  }
  final colon = credentials.indexOf(':');
  if (colon <= 0) {
    return null;
  }
  final method = credentials.substring(0, colon).toLowerCase();
  final password = credentials.substring(colon + 1);
  final uri = Uri.tryParse('ss://$hostPort');
  final port = uri == null ? null : _port(uri.port);
  if (uri == null || uri.host.isEmpty || port == null || password.isEmpty) {
    return null;
  }
  if (!_shadowsocksMethods.contains(method)) {
    return null;
  }
  return {
    'tag': name.isEmpty ? _defaultName('ss', uri.host, port) : name,
    'protocol': 'shadowsocks',
    'settings': {
      'address': uri.host,
      'port': port,
      'method': method,
      'password': password,
    },
  };
}

Map<String, dynamic>? _hysteria(Uri uri) {
  final auth = Uri.decodeComponent(uri.userInfo);
  final port = _port(uri.hasPort ? uri.port : 443);
  if (auth.isEmpty || uri.host.isEmpty || port == null) {
    return null;
  }
  final query = uri.queryParameters;
  final obfsPassword = _param(query, ['obfs-password', 'obfsPassword']);
  final ports = _param(query, ['mport']);
  return {
    'tag': _name(uri).isEmpty
        ? _defaultName('hysteria', uri.host, port)
        : _name(uri),
    'protocol': 'hysteria',
    'settings': {'version': 2, 'address': uri.host, 'port': port},
    'streamSettings': {
      'network': 'hysteria',
      'security': 'tls',
      'tlsSettings': {
        'serverName': _param(query, ['sni']) ?? uri.host,
        'alpn': ['h3'],
        if (_truthy(_param(query, ['insecure', 'allowInsecure'])))
          'allowInsecure': true,
      },
      'hysteriaSettings': {'version': 2, 'auth': auth},
      if ((_param(query, ['obfs']) == 'salamander' && obfsPassword != null) ||
          ports != null)
        'finalmask': {
          'udp': [
            if (_param(query, ['obfs']) == 'salamander' && obfsPassword != null)
              {
                'type': 'salamander',
                'settings': {'password': obfsPassword},
              },
            if (ports != null)
              {
                'type': 'udphop',
                'settings': {
                  'mode': 'intervalLocal',
                  'interval': '30',
                  'remotePorts': ports,
                },
              },
          ],
        },
    },
  };
}

Map<String, dynamic>? _tuic(Uri uri) {
  final colon = uri.userInfo.indexOf(':');
  final port = _port(uri.port);
  if (colon <= 0 || uri.host.isEmpty || port == null) {
    return null;
  }
  final id = Uri.decodeComponent(uri.userInfo.substring(0, colon));
  final password = Uri.decodeComponent(uri.userInfo.substring(colon + 1));
  final query = uri.queryParameters;
  final congestion = _param(query, ['congestion_control', 'congestionControl']);
  return {
    'tag': _name(uri).isEmpty
        ? _defaultName('tuic', uri.host, port)
        : _name(uri),
    'protocol': 'tuic',
    'settings': {
      'address': uri.host,
      'port': port,
      'id': id,
      'password': password,
      'congestionControl':
          const {'cubic', 'new_reno', 'bbr'}.contains(congestion)
          ? congestion
          : 'cubic',
      'udpStream': _param(query, ['udp_relay_mode', 'udpRelayMode']) == 'quic',
    },
    'streamSettings': {
      'network': 'tuic',
      'security': 'tls',
      'tlsSettings': {
        'serverName': _param(query, ['sni']) ?? uri.host,
        'alpn': _list(_param(query, ['alpn'])) ?? ['h3'],
        if (_truthy(
          _param(query, ['allow_insecure', 'allowInsecure', 'insecure']),
        ))
          'allowInsecure': true,
      },
    },
  };
}

Map<String, dynamic>? _anytls(Uri uri) {
  final password = Uri.decodeComponent(uri.userInfo);
  final port = _port(uri.hasPort ? uri.port : 443);
  if (password.isEmpty || uri.host.isEmpty || port == null) {
    return null;
  }
  final query = uri.queryParameters;
  return {
    'tag': _name(uri).isEmpty
        ? _defaultName('anytls', uri.host, port)
        : _name(uri),
    'protocol': 'anytls',
    'settings': {'address': uri.host, 'port': port, 'password': password},
    'streamSettings': {
      'network': 'tcp',
      'security': 'tls',
      'tlsSettings': {
        'serverName': _param(query, ['sni']) ?? uri.host,
        if (_truthy(_param(query, ['insecure', 'allowInsecure'])))
          'allowInsecure': true,
      },
    },
  };
}

/// Tags double as the names the user sees and as Xray's routing keys, so they
/// must be unique and must not start with the character reserved for the
/// app's own outbounds.
List<Map<String, dynamic>> _uniqueTags(List<Map<String, dynamic>> nodes) {
  final seen = <String, int>{};
  final result = <Map<String, dynamic>>[];
  for (final node in nodes) {
    var tag = '${node['tag'] ?? ''}'
        .trim()
        .replaceFirst(RegExp(r'^@+'), '')
        .trim();
    if (tag.isEmpty) {
      tag = '${node['protocol']}';
    }
    final count = (seen[tag] ?? 0) + 1;
    seen[tag] = count;
    result.add({...node, 'tag': count == 1 ? tag : '$tag ($count)'});
  }
  return result;
}
