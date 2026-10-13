import 'dart:convert';

/// The share link of [outbound], the form `parseShareLink` reads back, or null
/// when its protocol or transport has no link form.
String? nodeShareLink(Map<String, dynamic> outbound) {
  final tag = '${outbound['tag'] ?? ''}';
  final settings = _settings(outbound);
  final stream = _map(outbound['streamSettings']);
  final address = '${settings['address'] ?? ''}';
  final port = settings['port'];
  if (address.isEmpty || port == null) return null;
  return switch ('${outbound['protocol']}') {
    'vmess' => _vmess(tag, settings, stream),
    'vless' => _uriLink('vless', '${settings['id'] ?? ''}', settings, stream, {
      'encryption': '${settings['encryption'] ?? 'none'}',
      'flow': ?_text(settings['flow']),
    }, tag),
    'trojan' => _uriLink(
      'trojan',
      '${settings['password'] ?? ''}',
      settings,
      stream,
      {},
      tag,
    ),
    'shadowsocks' => _shadowsocks(tag, settings),
    'hysteria2' => _hysteria2(tag, settings, stream),
    'hysteria' => _hysteria(tag, settings),
    'tuic' => _tuic(tag, settings, stream),
    'anytls' => _anytls(tag, settings, stream),
    _ => null,
  };
}

/// What to hand out for [outbound]: its share link, else the outbound itself
/// as JSON, which a subscription or the clipboard import reads back.
String nodeShareText(Map<String, dynamic> outbound) {
  return nodeShareLink(outbound) ??
      const JsonEncoder.withIndent('  ').convert({
        'outbounds': [outbound],
      });
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

String? _text(Object? value) {
  final text = value == null ? '' : '$value';
  return text.isEmpty ? null : text;
}

/// The server fields of an outbound, flat as the app writes them or nested
/// under `vnext` or `servers` as older Xray configs do.
Map<String, dynamic> _settings(Map<String, dynamic> outbound) {
  final settings = _map(outbound['settings']);
  for (final key in ['vnext', 'servers']) {
    final list = settings[key];
    if (list is List && list.isNotEmpty) {
      final server = _map(list.first);
      final users = server['users'];
      return {
        ...settings,
        ...server,
        if (users is List && users.isNotEmpty) ..._map(users.first),
      };
    }
  }
  return settings;
}

String _host(String address) =>
    address.contains(':') && !address.startsWith('[') ? '[$address]' : address;

String _fragment(String tag) =>
    tag.isEmpty ? '' : '#${Uri.encodeComponent(tag)}';

String _query(Map<String, String> query) => query.isEmpty
    ? ''
    : '?${query.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';

/// The transport and security of [stream] as link parameters, or null when
/// the transport has no link form.
Map<String, String>? _transport(Map<String, dynamic> stream) {
  final network = '${stream['network'] ?? 'tcp'}';
  final query = <String, String>{};
  switch (network) {
    case 'tcp' || 'raw':
      final header = _map(
        _map(stream['rawSettings'] ?? stream['tcpSettings'])['header'],
      );
      query['type'] = 'tcp';
      if (header['type'] == 'http') {
        final request = _map(header['request']);
        final path = request['path'];
        final hosts = _map(request['headers'])['Host'];
        query['headerType'] = 'http';
        if (path is List && path.isNotEmpty) query['path'] = '${path.first}';
        if (hosts is List && hosts.isNotEmpty) query['host'] = hosts.join(',');
      }
    case 'ws' || 'httpupgrade' || 'xhttp':
      final options = _map(stream['${network}Settings']);
      query['type'] = network;
      if (_text(options['path']) case final path?) query['path'] = path;
      if (_text(options['host']) case final host?) query['host'] = host;
      if (_text(options['mode']) case final mode?) query['mode'] = mode;
    case 'grpc':
      final options = _map(stream['grpcSettings']);
      query['type'] = 'grpc';
      query['serviceName'] = '${options['serviceName'] ?? ''}';
      if (options['multiMode'] == true) query['mode'] = 'multi';
    default:
      return null;
  }
  switch (stream['security']) {
    case 'tls':
      final tls = _map(stream['tlsSettings']);
      query['security'] = 'tls';
      if (_text(tls['serverName']) case final sni?) query['sni'] = sni;
      if (tls['alpn'] case final List alpn when alpn.isNotEmpty) {
        query['alpn'] = alpn.join(',');
      }
      if (_text(tls['fingerprint']) case final fp?) query['fp'] = fp;
      if (tls['allowInsecure'] == true) query['allowInsecure'] = '1';
    case 'reality':
      final reality = _map(stream['realitySettings']);
      query['security'] = 'reality';
      if (_text(reality['serverName']) case final sni?) query['sni'] = sni;
      query['fp'] = '${reality['fingerprint'] ?? 'chrome'}';
      query['pbk'] = '${reality['publicKey'] ?? ''}';
      if (_text(reality['shortId']) case final sid?) query['sid'] = sid;
      if (_text(reality['spiderX']) case final spx?) query['spx'] = spx;
    default:
      query['security'] = 'none';
  }
  return query;
}

String? _uriLink(
  String scheme,
  String user,
  Map<String, dynamic> settings,
  Map<String, dynamic> stream,
  Map<String, String> extra,
  String tag,
) {
  final transport = _transport(stream);
  if (user.isEmpty || transport == null) return null;
  return '$scheme://${Uri.encodeComponent(user)}@'
      '${_host('${settings['address']}')}:${settings['port']}'
      '${_query({...extra, ...transport})}${_fragment(tag)}';
}

String? _vmess(
  String tag,
  Map<String, dynamic> settings,
  Map<String, dynamic> stream,
) {
  final transport = _transport(stream);
  final id = '${settings['id'] ?? ''}';
  if (transport == null || id.isEmpty) return null;
  final body = {
    'v': '2',
    'ps': tag,
    'add': '${settings['address']}',
    'port': '${settings['port']}',
    'id': id,
    'aid': '0',
    'scy': '${settings['security'] ?? 'auto'}',
    'net': transport['type'],
    'type': transport['headerType'] ?? 'none',
    'host': transport['host'] ?? '',
    'path': transport['path'] ?? transport['serviceName'] ?? '',
    'tls': transport['security'] == 'tls' ? 'tls' : '',
    'sni': transport['sni'] ?? '',
    'alpn': transport['alpn'] ?? '',
    'fp': transport['fp'] ?? '',
    'mode': ?transport['mode'],
  };
  return 'vmess://${base64.encode(utf8.encode(json.encode(body)))}';
}

String? _shadowsocks(String tag, Map<String, dynamic> settings) {
  final method = '${settings['method'] ?? ''}';
  final password = '${settings['password'] ?? ''}';
  if (method.isEmpty || password.isEmpty) return null;
  final userInfo = base64Url
      .encode(utf8.encode('$method:$password'))
      .replaceAll('=', '');
  return 'ss://$userInfo@${_host('${settings['address']}')}:'
      '${settings['port']}${_fragment(tag)}';
}

String? _hysteria2(
  String tag,
  Map<String, dynamic> settings,
  Map<String, dynamic> stream,
) {
  final auth = '${_map(stream['hysteria2Settings'])['auth'] ?? ''}';
  if (auth.isEmpty) return null;
  final tls = _map(stream['tlsSettings']);
  final query = <String, String>{
    'sni': ?_text(tls['serverName']),
    if (tls['allowInsecure'] == true) 'insecure': '1',
  };
  final masks = _map(stream['finalmask'])['udp'];
  for (final mask in masks is List ? masks : const []) {
    final entry = _map(mask);
    final options = _map(entry['settings']);
    if (entry['type'] == 'salamander') {
      query['obfs'] = 'salamander';
      query['obfs-password'] = '${options['password'] ?? ''}';
    } else if (entry['type'] == 'udphop') {
      if (_text(options['remotePorts']) case final ports?) {
        query['mport'] = ports;
      }
    }
  }
  return 'hysteria2://${Uri.encodeComponent(auth)}@'
      '${_host('${settings['address']}')}:${settings['port']}'
      '${_query(query)}${_fragment(tag)}';
}

String? _hysteria(String tag, Map<String, dynamic> settings) {
  final auth = _text(settings['auth']);
  final up = int.tryParse('${settings['up']}'.replaceAll(RegExp(r'\D'), ''));
  final down = int.tryParse(
    '${settings['down']}'.replaceAll(RegExp(r'\D'), ''),
  );
  if (auth == null || up == null || down == null) return null;
  final alpn = settings['alpn'];
  final query = <String, String>{
    'auth': auth,
    'upmbps': '$up',
    'downmbps': '$down',
    'peer': ?_text(settings['serverName']),
    if (settings['allowInsecure'] == true) 'insecure': '1',
    if (alpn is List && alpn.isNotEmpty) 'alpn': '${alpn.first}',
    if (settings['obfs'] == 'xplus') ...{
      'obfs': 'xplus',
      'obfsParam': '${settings['obfsPassword'] ?? ''}',
    },
  };
  return 'hysteria://${_host('${settings['address']}')}:${settings['port']}'
      '${_query(query)}${_fragment(tag)}';
}

String? _tuic(
  String tag,
  Map<String, dynamic> settings,
  Map<String, dynamic> stream,
) {
  final id = '${settings['id'] ?? ''}';
  final password = '${settings['password'] ?? ''}';
  if (id.isEmpty || password.isEmpty) return null;
  final tls = _map(stream['tlsSettings']);
  final alpn = tls['alpn'];
  final query = <String, String>{
    'congestion_control': '${settings['congestionControl'] ?? 'cubic'}',
    if (settings['udpStream'] == true) 'udp_relay_mode': 'quic',
    'sni': ?_text(tls['serverName']),
    if (alpn is List && alpn.isNotEmpty) 'alpn': alpn.join(','),
    if (tls['allowInsecure'] == true) 'allow_insecure': '1',
  };
  return 'tuic://${Uri.encodeComponent(id)}:${Uri.encodeComponent(password)}@'
      '${_host('${settings['address']}')}:${settings['port']}'
      '${_query(query)}${_fragment(tag)}';
}

String? _anytls(
  String tag,
  Map<String, dynamic> settings,
  Map<String, dynamic> stream,
) {
  final password = '${settings['password'] ?? ''}';
  if (password.isEmpty) return null;
  final tls = _map(stream['tlsSettings']);
  final query = <String, String>{
    'sni': ?_text(tls['serverName']),
    if (tls['allowInsecure'] == true) 'insecure': '1',
  };
  return 'anytls://${Uri.encodeComponent(password)}@'
      '${_host('${settings['address']}')}:${settings['port']}'
      '${_query(query)}${_fragment(tag)}';
}
