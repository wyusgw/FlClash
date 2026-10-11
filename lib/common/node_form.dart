import 'dart:convert';

import 'subscription.dart';

/// The protocols a server can be typed in for.
enum NodeKind {
  shadowsocks,
  vmess,
  vless,
  socks,
  http,
  trojan,
  hysteria,
  hysteria2,
  tuic,
  anytls,
  mieru,
}

enum NodeFieldType { text, secret, number, choice, toggle }

/// One input of a server form. A field is shown only while [when] accepts the
/// values entered so far.
class NodeField {
  const NodeField(
    this.key,
    this.type, {
    this.required = false,
    this.options = const [],
    this.initial = '',
    this.when,
  });

  final String key;
  final NodeFieldType type;
  final bool required;
  final List<String> options;
  final String initial;
  final bool Function(Map<String, String> values)? when;

  bool visible(Map<String, String> values) => when?.call(values) ?? true;
}

const shadowsocksMethods = [
  'aes-256-gcm',
  'aes-128-gcm',
  'chacha20-poly1305',
  'xchacha20-poly1305',
  '2022-blake3-aes-128-gcm',
  '2022-blake3-aes-256-gcm',
  '2022-blake3-chacha20-poly1305',
];

const _networks = ['tcp', 'ws', 'grpc'];
const _fingerprints = ['chrome', 'firefox', 'safari', 'ios', 'android', 'edge'];

bool _ws(Map<String, String> v) => v['network'] == 'ws';
bool _grpc(Map<String, String> v) => v['network'] == 'grpc';
bool _tls(Map<String, String> v) => v['tls'] == 'true';
bool _secured(Map<String, String> v) => v['security'] != 'none';
bool _vlessTls(Map<String, String> v) => v['security'] == 'tls';
bool _reality(Map<String, String> v) => v['security'] == 'reality';

const _address = NodeField('address', NodeFieldType.text, required: true);
const _port = NodeField('port', NodeFieldType.number, required: true);
const _remark = NodeField('remark', NodeFieldType.text);
const _sni = NodeField('sni', NodeFieldType.text);
const _insecure = NodeField('allowInsecure', NodeFieldType.toggle);

List<NodeField> _transport() => const [
  NodeField(
    'network',
    NodeFieldType.choice,
    options: _networks,
    initial: 'tcp',
  ),
  NodeField('path', NodeFieldType.text, when: _ws),
  NodeField('host', NodeFieldType.text, when: _ws),
  NodeField('serviceName', NodeFieldType.text, when: _grpc),
];

const _mieruMultiplexing = ['off', 'low', 'middle', 'high'];
const _mieruHandshakes = ['standard', 'no-wait'];

List<NodeField> nodeFields(NodeKind kind) {
  return switch (kind) {
    NodeKind.socks || NodeKind.http => const [
      _address,
      _port,
      NodeField('username', NodeFieldType.text),
      NodeField('password', NodeFieldType.secret),
      NodeField('tls', NodeFieldType.toggle),
      NodeField('sni', NodeFieldType.text, when: _tls),
      NodeField('allowInsecure', NodeFieldType.toggle, when: _tls),
      _remark,
    ],
    NodeKind.mieru => const [
      _address,
      _port,
      NodeField('username', NodeFieldType.text, required: true),
      NodeField('password', NodeFieldType.secret, required: true),
      NodeField(
        'transport',
        NodeFieldType.choice,
        options: ['TCP', 'UDP'],
        initial: 'TCP',
      ),
      NodeField(
        'multiplexing',
        NodeFieldType.choice,
        options: _mieruMultiplexing,
        initial: 'low',
      ),
      NodeField(
        'handshake',
        NodeFieldType.choice,
        options: _mieruHandshakes,
        initial: 'standard',
      ),
      _remark,
    ],
    NodeKind.shadowsocks => const [
      _address,
      _port,
      NodeField('password', NodeFieldType.secret, required: true),
      NodeField(
        'method',
        NodeFieldType.choice,
        options: shadowsocksMethods,
        initial: 'aes-256-gcm',
      ),
      _remark,
    ],
    NodeKind.vmess => [
      _address,
      _port,
      const NodeField('uuid', NodeFieldType.secret, required: true),
      const NodeField(
        'security',
        NodeFieldType.choice,
        options: ['auto', 'aes-128-gcm', 'chacha20-poly1305'],
        initial: 'auto',
      ),
      ..._transport(),
      const NodeField('tls', NodeFieldType.toggle),
      const NodeField('sni', NodeFieldType.text, when: _tls),
      _remark,
    ],
    NodeKind.vless => [
      _address,
      _port,
      const NodeField('uuid', NodeFieldType.secret, required: true),
      const NodeField(
        'flow',
        NodeFieldType.choice,
        options: ['none', 'xtls-rprx-vision'],
        initial: 'none',
      ),
      ..._transport(),
      const NodeField(
        'security',
        NodeFieldType.choice,
        options: ['tls', 'reality', 'none'],
        initial: 'tls',
      ),
      const NodeField('sni', NodeFieldType.text, when: _secured),
      const NodeField('allowInsecure', NodeFieldType.toggle, when: _vlessTls),
      const NodeField(
        'fingerprint',
        NodeFieldType.choice,
        options: _fingerprints,
        initial: 'chrome',
        when: _reality,
      ),
      const NodeField(
        'publicKey',
        NodeFieldType.text,
        required: true,
        when: _reality,
      ),
      const NodeField('shortId', NodeFieldType.text, when: _reality),
      _remark,
    ],
    NodeKind.trojan => [
      _address,
      _port,
      const NodeField('password', NodeFieldType.secret, required: true),
      ..._transport(),
      _sni,
      _insecure,
      _remark,
    ],
    NodeKind.hysteria => const [
      _address,
      _port,
      NodeField('password', NodeFieldType.secret, required: true),
      NodeField(
        'uploadSpeed',
        NodeFieldType.number,
        required: true,
        initial: '100',
      ),
      NodeField(
        'downloadSpeed',
        NodeFieldType.number,
        required: true,
        initial: '100',
      ),
      _sni,
      _insecure,
      NodeField('obfsPassword', NodeFieldType.secret),
      _remark,
    ],
    NodeKind.hysteria2 => const [
      _address,
      _port,
      NodeField('password', NodeFieldType.secret, required: true),
      _sni,
      _insecure,
      NodeField('obfsPassword', NodeFieldType.secret),
      _remark,
    ],
    NodeKind.tuic => const [
      _address,
      _port,
      NodeField('uuid', NodeFieldType.secret, required: true),
      NodeField('password', NodeFieldType.secret, required: true),
      NodeField(
        'congestion',
        NodeFieldType.choice,
        options: ['bbr', 'cubic', 'new_reno'],
        initial: 'bbr',
      ),
      _sni,
      _insecure,
      _remark,
    ],
    NodeKind.anytls => const [
      _address,
      _port,
      NodeField('password', NodeFieldType.secret, required: true),
      _sni,
      _insecure,
      _remark,
    ],
  };
}

/// What each field holds before anything is typed.
Map<String, String> nodeDefaults(NodeKind kind) => {
  for (final field in nodeFields(kind))
    field.key: field.type == NodeFieldType.toggle
        ? (field.initial.isEmpty ? 'false' : field.initial)
        : field.initial,
};

/// The key of the first visible field that is required and empty, or whose
/// number is not a port; null when the form is complete.
String? nodeFormProblem(NodeKind kind, Map<String, String> values) {
  for (final field in nodeFields(kind)) {
    if (!field.visible(values)) continue;
    final value = (values[field.key] ?? '').trim();
    if (field.required && value.isEmpty) return field.key;
    if (field.key == 'port' && value.isNotEmpty) {
      final port = int.tryParse(value);
      if (port == null || port < 1 || port > 65535) return field.key;
    }
    if (field.key == 'uploadSpeed' || field.key == 'downloadSpeed') {
      final speed = int.tryParse(value);
      if (speed == null || speed < 1) return field.key;
    }
  }
  return null;
}

String _text(Map<String, String> v, String key) => (v[key] ?? '').trim();

String? _nonEmpty(Map<String, String> v, String key) {
  final value = _text(v, key);
  return value.isEmpty ? null : value;
}

bool _on(Map<String, String> v, String key) => v[key] == 'true';

String _hostPart(String host) =>
    host.contains(':') && !host.startsWith('[') ? '[$host]' : host;

String _remarkOf(Map<String, String> v) => _text(v, 'remark');

Map<String, String> _tlsQuery(Map<String, String> v, {bool insecure = true}) =>
    {
      'sni': ?_nonEmpty(v, 'sni'),
      if (insecure && _on(v, 'allowInsecure')) 'allowInsecure': '1',
    };

Map<String, String> _transportQuery(Map<String, String> v) {
  final network = _text(v, 'network');
  return {
    if (network.isNotEmpty) 'type': network,
    if (network == 'ws') ...{
      'path': ?_nonEmpty(v, 'path'),
      'host': ?_nonEmpty(v, 'host'),
    },
    if (network == 'grpc') 'serviceName': ?_nonEmpty(v, 'serviceName'),
  };
}

String _uriLink(
  String scheme,
  Map<String, String> v, {
  required String userInfo,
  required Map<String, String> query,
}) {
  return Uri(
    scheme: scheme,
    userInfo: userInfo,
    host: _text(v, 'address'),
    port: int.parse(_text(v, 'port')),
    queryParameters: query.isEmpty ? null : query,
    fragment: _remarkOf(v).isEmpty ? null : _remarkOf(v),
  ).toString();
}

/// The share link the form's values stand for, in the shape the subscription
/// reader understands; null when the values cannot form a link.
String? buildNodeLink(NodeKind kind, Map<String, String> values) {
  if (nodeFormProblem(kind, values) != null) return null;
  final v = values;
  try {
    return switch (kind) {
      NodeKind.socks || NodeKind.http || NodeKind.mieru => null,
      NodeKind.shadowsocks =>
        'ss://${_text(v, 'method')}:${Uri.encodeComponent(_text(v, 'password'))}'
            '@${_hostPart(_text(v, 'address'))}:${_text(v, 'port')}'
            '${_remarkOf(v).isEmpty ? '' : '#${Uri.encodeComponent(_remarkOf(v))}'}',
      NodeKind.vmess =>
        'vmess://${base64.encode(utf8.encode(jsonEncode({'v': '2', 'ps': _remarkOf(v), 'add': _text(v, 'address'), 'port': _text(v, 'port'), 'id': _text(v, 'uuid'), 'scy': _text(v, 'security'), 'net': _text(v, 'network'), 'type': 'none', 'host': _text(v, 'host'), 'path': _text(v, 'network') == 'grpc' ? _text(v, 'serviceName') : _text(v, 'path'), 'tls': _on(v, 'tls') ? 'tls' : '', 'sni': _on(v, 'tls') ? _text(v, 'sni') : ''})))}',
      NodeKind.vless => _uriLink(
        'vless',
        v,
        userInfo: _text(v, 'uuid'),
        query: {
          'encryption': 'none',
          'security': _text(v, 'security'),
          if (_text(v, 'flow') != 'none' && _text(v, 'flow').isNotEmpty)
            'flow': _text(v, 'flow'),
          ..._transportQuery(v),
          if (_secured(v)) ..._tlsQuery(v, insecure: _vlessTls(v)),
          if (_reality(v)) ...{
            'fp': _text(v, 'fingerprint'),
            'pbk': _text(v, 'publicKey'),
            'sid': ?_nonEmpty(v, 'shortId'),
          },
        },
      ),
      NodeKind.trojan => _uriLink(
        'trojan',
        v,
        userInfo: _text(v, 'password'),
        query: {'security': 'tls', ..._transportQuery(v), ..._tlsQuery(v)},
      ),
      NodeKind.hysteria => _uriLink(
        'hysteria',
        v,
        userInfo: '',
        query: {
          'protocol': 'udp',
          'auth': _text(v, 'password'),
          'upmbps': _text(v, 'uploadSpeed'),
          'downmbps': _text(v, 'downloadSpeed'),
          'peer': ?_nonEmpty(v, 'sni'),
          if (_on(v, 'allowInsecure')) 'insecure': '1',
          if (_nonEmpty(v, 'obfsPassword') != null) ...{
            'obfs': 'xplus',
            'obfsParam': _text(v, 'obfsPassword'),
          },
        },
      ),
      NodeKind.hysteria2 => _uriLink(
        'hysteria2',
        v,
        userInfo: _text(v, 'password'),
        query: {
          ..._tlsQuery(v),
          if (_nonEmpty(v, 'obfsPassword') != null) ...{
            'obfs': 'salamander',
            'obfs-password': _text(v, 'obfsPassword'),
          },
        },
      ),
      NodeKind.tuic => _uriLink(
        'tuic',
        v,
        userInfo: '${_text(v, 'uuid')}:${_text(v, 'password')}',
        query: {'congestion_control': _text(v, 'congestion'), ..._tlsQuery(v)},
      ),
      NodeKind.anytls => _uriLink(
        'anytls',
        v,
        userInfo: _text(v, 'password'),
        query: _tlsQuery(v),
      ),
    };
  } on FormatException {
    return null;
  }
}

Map<String, dynamic> _directOutbound(NodeKind kind, Map<String, String> v) {
  final host = _text(v, 'address');
  final port = int.parse(_text(v, 'port'));
  final protocol = switch (kind) {
    NodeKind.socks => 'socks',
    NodeKind.http => 'http',
    _ => 'mieru',
  };
  final tag = _remarkOf(v).isEmpty ? '$protocol-$host:$port' : _remarkOf(v);
  if (kind == NodeKind.mieru) {
    return {
      'tag': tag,
      'protocol': protocol,
      'settings': {
        'address': host,
        'port': port,
        'username': _text(v, 'username'),
        'password': _text(v, 'password'),
        'transport': _text(v, 'transport'),
        'multiplexing':
            'MULTIPLEXING_${_text(v, 'multiplexing').toUpperCase()}',
        'handshakeMode':
            'HANDSHAKE_${_text(v, 'handshake').toUpperCase().replaceAll('-', '_')}',
      },
    };
  }
  return {
    'tag': tag,
    'protocol': protocol,
    'settings': {
      'address': host,
      'port': port,
      if (_nonEmpty(v, 'username') != null) 'user': _text(v, 'username'),
      if (_nonEmpty(v, 'password') != null) 'pass': _text(v, 'password'),
    },
    if (_on(v, 'tls'))
      'streamSettings': {
        'network': 'tcp',
        'security': 'tls',
        'tlsSettings': {
          'serverName': _nonEmpty(v, 'sni') ?? host,
          if (_on(v, 'allowInsecure')) 'allowInsecure': true,
        },
      },
  };
}

/// The outbound the form's values make, or null when they make none.
Map<String, dynamic>? buildNodeOutbound(
  NodeKind kind,
  Map<String, String> values,
) {
  if (nodeFormProblem(kind, values) != null) return null;
  if (kind == NodeKind.socks ||
      kind == NodeKind.http ||
      kind == NodeKind.mieru) {
    return _directOutbound(kind, values);
  }
  final link = buildNodeLink(kind, values);
  return link == null ? null : parseShareLink(link);
}
