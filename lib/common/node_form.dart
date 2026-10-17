import 'dart:convert';

import 'share_link.dart';
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

/// Where a field is shown: on the server's own page, or on the page of its
/// transport or of its TLS, each opened from a row of the server's page.
enum NodeFieldGroup { main, transport, tls }

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
    this.group = NodeFieldGroup.main,
  });

  final String key;
  final NodeFieldType type;
  final bool required;
  final List<String> options;
  final String initial;
  final bool Function(Map<String, String> values)? when;
  final NodeFieldGroup group;

  bool visible(Map<String, String> values) => when?.call(values) ?? true;
}

/// The choice that leaves a setting to the Core.
const nodeDefaultChoice = 'default';

const shadowsocksMethods = [
  'aes-256-gcm',
  'aes-128-gcm',
  'chacha20-poly1305',
  'xchacha20-poly1305',
  '2022-blake3-aes-128-gcm',
  '2022-blake3-aes-256-gcm',
  '2022-blake3-chacha20-poly1305',
];

const _networks = ['raw', 'xhttp', 'kcp', 'grpc', 'ws', 'httpupgrade'];
const _xhttpModes = ['auto', 'packet-up', 'stream-up', 'stream-one'];

/// The uTLS fingerprints the Core knows by name, its own aliases first.
const _fingerprints = [
  nodeDefaultChoice,
  'chrome',
  'firefox',
  'safari',
  'ios',
  'android',
  'edge',
  '360',
  'qq',
  'random',
  'randomized',
  'randomizednoalpn',
  'hellochrome_120',
  'hellochrome_131',
  'hellochrome_133',
  'hellofirefox_120',
  'hellofirefox_148',
  'hellosafari_26_3',
  'helloios_14',
  'helloedge_106',
];

String _network(Map<String, String> v) => v['network'] ?? 'raw';
bool _rawHttp(Map<String, String> v) =>
    _network(v) == 'raw' && v['headerType'] == 'http';
bool _hasPath(Map<String, String> v) =>
    _rawHttp(v) || const {'ws', 'httpupgrade', 'xhttp'}.contains(_network(v));

/// Kinds that always speak TLS keep no `security` value.
String _security(Map<String, String> v) => v['security'] ?? 'tls';
bool _tls(Map<String, String> v) => _security(v) == 'tls';
bool _reality(Map<String, String> v) => _security(v) == 'reality';
bool _secured(Map<String, String> v) => _security(v) != 'none';
bool _noFlow(Map<String, String> v) => (v['flow'] ?? 'none') == 'none';

const _address = NodeField('address', NodeFieldType.text, required: true);
const _port = NodeField('port', NodeFieldType.number, required: true);
const _remark = NodeField('remark', NodeFieldType.text);
const _mux = NodeField('mux', NodeFieldType.toggle);
const _muxWithoutFlow = NodeField('mux', NodeFieldType.toggle, when: _noFlow);
const _fastOpen = NodeField('tcpFastOpen', NodeFieldType.toggle);
const _dialerProxy = NodeField('dialerProxy', NodeFieldType.choice);

const _transport = [
  NodeField(
    'network',
    NodeFieldType.choice,
    options: _networks,
    initial: 'raw',
    group: NodeFieldGroup.transport,
  ),
  NodeField(
    'headerType',
    NodeFieldType.choice,
    options: ['none', 'http'],
    initial: 'none',
    when: _isRaw,
    group: NodeFieldGroup.transport,
  ),
  NodeField(
    'path',
    NodeFieldType.text,
    when: _hasPath,
    group: NodeFieldGroup.transport,
  ),
  NodeField(
    'host',
    NodeFieldType.text,
    when: _hasPath,
    group: NodeFieldGroup.transport,
  ),
  NodeField(
    'mode',
    NodeFieldType.choice,
    options: _xhttpModes,
    initial: 'auto',
    when: _isXhttp,
    group: NodeFieldGroup.transport,
  ),
  NodeField(
    'serviceName',
    NodeFieldType.text,
    when: _isGrpc,
    group: NodeFieldGroup.transport,
  ),
  NodeField(
    'multiMode',
    NodeFieldType.toggle,
    when: _isGrpc,
    group: NodeFieldGroup.transport,
  ),
];

bool _isRaw(Map<String, String> v) => _network(v) == 'raw';
bool _isXhttp(Map<String, String> v) => _network(v) == 'xhttp';
bool _isGrpc(Map<String, String> v) => _network(v) == 'grpc';

/// The TLS page of a kind: [securities] lists what it may choose from, or is
/// null for a kind that always speaks TLS; the rest says which settings its
/// TLS takes. ECH, uTLS and fragmenting the hello need TLS over TCP.
List<NodeField> _tlsFields({
  List<String>? securities,
  bool overTcp = true,
  bool alpn = true,
  bool pin = true,
}) => [
  if (securities != null)
    NodeField(
      'security',
      NodeFieldType.choice,
      options: securities,
      initial: securities.first,
      group: NodeFieldGroup.tls,
    ),
  const NodeField(
    'allowInsecure',
    NodeFieldType.toggle,
    when: _tls,
    group: NodeFieldGroup.tls,
  ),
  const NodeField(
    'sni',
    NodeFieldType.text,
    when: _secured,
    group: NodeFieldGroup.tls,
  ),
  if (overTcp)
    const NodeField(
      'ech',
      NodeFieldType.text,
      when: _tls,
      group: NodeFieldGroup.tls,
    ),
  if (alpn)
    const NodeField(
      'alpn',
      NodeFieldType.text,
      when: _tls,
      group: NodeFieldGroup.tls,
    ),
  if (securities?.contains('reality') ?? false) ...const [
    NodeField(
      'publicKey',
      NodeFieldType.text,
      required: true,
      when: _reality,
      group: NodeFieldGroup.tls,
    ),
    NodeField(
      'shortId',
      NodeFieldType.text,
      when: _reality,
      group: NodeFieldGroup.tls,
    ),
    NodeField(
      'spiderX',
      NodeFieldType.text,
      when: _reality,
      group: NodeFieldGroup.tls,
    ),
    NodeField(
      'mldsa65Verify',
      NodeFieldType.text,
      when: _reality,
      group: NodeFieldGroup.tls,
    ),
  ],
  if (overTcp) ...const [
    NodeField(
      'fingerprint',
      NodeFieldType.choice,
      options: _fingerprints,
      initial: nodeDefaultChoice,
      when: _secured,
      group: NodeFieldGroup.tls,
    ),
    NodeField(
      'fragment',
      NodeFieldType.toggle,
      when: _secured,
      group: NodeFieldGroup.tls,
    ),
  ],
  if (pin)
    const NodeField(
      'pin',
      NodeFieldType.text,
      when: _tls,
      group: NodeFieldGroup.tls,
    ),
];

const _mieruMultiplexing = [nodeDefaultChoice, 'off', 'low', 'middle', 'high'];
const _mieruHandshakes = [nodeDefaultChoice, 'standard', 'no-wait'];

List<NodeField> nodeFields(NodeKind kind) {
  return switch (kind) {
    NodeKind.socks || NodeKind.http => [
      _address,
      _port,
      const NodeField('username', NodeFieldType.text),
      const NodeField('password', NodeFieldType.secret),
      ..._tlsFields(securities: const ['none', 'tls']),
      _fastOpen,
      _dialerProxy,
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
      NodeField('mtu', NodeFieldType.number),
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
      _mux,
      _fastOpen,
      _dialerProxy,
      _remark,
    ],
    NodeKind.vmess => [
      _address,
      _port,
      const NodeField('uuid', NodeFieldType.secret, required: true),
      const NodeField(
        'method',
        NodeFieldType.choice,
        options: ['auto', 'aes-128-gcm', 'chacha20-poly1305', 'none', 'zero'],
        initial: 'auto',
      ),
      ..._transport,
      ..._tlsFields(securities: const ['none', 'tls']),
      _mux,
      _fastOpen,
      _dialerProxy,
      _remark,
    ],
    NodeKind.vless => [
      _address,
      _port,
      const NodeField('uuid', NodeFieldType.secret, required: true),
      const NodeField('encryption', NodeFieldType.text),
      const NodeField(
        'flow',
        NodeFieldType.choice,
        options: ['none', 'xtls-rprx-vision'],
        initial: 'none',
      ),
      ..._transport,
      ..._tlsFields(securities: const ['tls', 'reality', 'none']),
      _muxWithoutFlow,
      _fastOpen,
      _dialerProxy,
      _remark,
    ],
    NodeKind.trojan => [
      _address,
      _port,
      const NodeField('password', NodeFieldType.secret, required: true),
      ..._transport,
      ..._tlsFields(securities: const ['tls', 'reality', 'none']),
      _mux,
      _fastOpen,
      _dialerProxy,
      _remark,
    ],
    NodeKind.hysteria => [
      _address,
      _port,
      const NodeField('password', NodeFieldType.secret, required: true),
      const NodeField(
        'uploadSpeed',
        NodeFieldType.number,
        required: true,
        initial: '100',
      ),
      const NodeField(
        'downloadSpeed',
        NodeFieldType.number,
        required: true,
        initial: '100',
      ),
      const NodeField('obfsPassword', NodeFieldType.secret),
      ..._tlsFields(overTcp: false, alpn: false, pin: false),
      _dialerProxy,
      _remark,
    ],
    NodeKind.hysteria2 => [
      _address,
      _port,
      const NodeField('password', NodeFieldType.secret, required: true),
      const NodeField('ports', NodeFieldType.text),
      const NodeField('obfsPassword', NodeFieldType.secret),
      ..._tlsFields(overTcp: false, alpn: false),
      _dialerProxy,
      _remark,
    ],
    NodeKind.tuic => [
      _address,
      _port,
      const NodeField('uuid', NodeFieldType.secret, required: true),
      const NodeField('password', NodeFieldType.secret, required: true),
      const NodeField(
        'congestion',
        NodeFieldType.choice,
        options: ['bbr', 'cubic', 'new_reno'],
        initial: 'bbr',
      ),
      const NodeField(
        'udpRelay',
        NodeFieldType.choice,
        options: ['native', 'quic'],
        initial: 'native',
      ),
      ..._tlsFields(overTcp: false),
      _dialerProxy,
      _remark,
    ],
    NodeKind.anytls => [
      _address,
      _port,
      const NodeField('password', NodeFieldType.secret, required: true),
      ..._tlsFields(),
      _fastOpen,
      _dialerProxy,
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
  if (kind == NodeKind.tuic) 'alpn': 'h3',
  // Empty leaves the country to the server's name.
  'region': '',
};

final _portRanges = RegExp(r'^\d+(-\d+)?(,\d+(-\d+)?)*$');
final _certHash = RegExp(r'^[0-9a-fA-F]{64}$');

/// Certificate hashes as `openssl x509 -fingerprint -sha256` prints them, one
/// or more split by commas; the Core refuses the whole config for a bad one.
bool _validPin(String value) => value
    .split(',')
    .map((hash) => hash.trim().replaceAll(':', ''))
    .where((hash) => hash.isNotEmpty)
    .every(_certHash.hasMatch);

/// An ECH config list in base64, or the DNS server to look it up from.
bool _validEch(String value) {
  if (value.contains('://')) return true;
  try {
    base64.decode(value);
    return true;
  } on FormatException {
    return false;
  }
}

/// The key of the first visible field that is required and empty, or whose
/// number is out of range; null when the form is complete.
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
    if (value.isNotEmpty &&
        switch (field.key) {
          'ports' => !_portRanges.hasMatch(value),
          'pin' => !_validPin(value),
          'ech' => !_validEch(value),
          _ => false,
        }) {
      return field.key;
    }
  }
  // Xray refuses a VLESS server with neither TLS nor encryption unless it is
  // on the local network.
  if (kind == NodeKind.vless &&
      values['security'] == 'none' &&
      _text(values, 'encryption').isEmpty &&
      !isPrivateHost(_text(values, 'address'))) {
    return 'security';
  }
  return null;
}

String _text(Map<String, String> v, String key) => (v[key] ?? '').trim();

String? _nonEmpty(Map<String, String> v, String key) {
  final value = _text(v, key);
  return value.isEmpty ? null : value;
}

bool _on(Map<String, String> v, String key) => v[key] == 'true';

List<String>? _list(Map<String, String> v, String key) {
  final items = _text(
    v,
    key,
  ).split(',').map((item) => item.trim()).where((item) => item.isNotEmpty);
  return items.isEmpty ? null : items.toList();
}

/// Whether [key] is a field [kind] shows for [values] and it is switched on.
bool _active(NodeKind kind, Map<String, String> v, String key) =>
    _on(v, key) &&
    nodeFields(kind).any((field) => field.key == key && field.visible(v));

String? _choice(Map<String, String> v, String key) {
  final value = _text(v, key);
  return value.isEmpty || value == nodeDefaultChoice ? null : value;
}

Map<String, dynamic> _tlsSettings(
  NodeKind kind,
  Map<String, String> v,
  String serverName, {
  List<String>? alpn,
}) {
  final has = {for (final field in nodeFields(kind)) field.key};
  return {
    'serverName': _nonEmpty(v, 'sni') ?? serverName,
    'alpn': ?(has.contains('alpn') ? _list(v, 'alpn') : null) ?? alpn,
    'fingerprint': ?(has.contains('fingerprint')
        ? _choice(v, 'fingerprint')
        : null),
    if (_on(v, 'allowInsecure')) 'allowInsecure': true,
    'echConfigList': ?(has.contains('ech') ? _nonEmpty(v, 'ech') : null),
    'pinnedPeerCertSha256': ?(has.contains('pin') ? _nonEmpty(v, 'pin') : null),
  };
}

/// The transport and security of a VMess, VLESS or Trojan server, in the
/// shape the subscription reader gives its links.
Map<String, dynamic> _stream(NodeKind kind, Map<String, String> v) {
  final address = _text(v, 'address');
  final path = _nonEmpty(v, 'path');
  final host = _nonEmpty(v, 'host');
  final stream = <String, dynamic>{};
  switch (_network(v)) {
    case 'raw':
      if (_rawHttp(v)) {
        stream['network'] = 'raw';
        stream['rawSettings'] = {
          'header': {
            'type': 'http',
            'request': {
              'path': [path ?? '/'],
              if (host != null) 'headers': {'Host': _list(v, 'host')},
            },
          },
        };
      }
    case 'ws' || 'httpupgrade':
      stream['network'] = _network(v);
      stream['${_network(v)}Settings'] = {'path': ?path, 'host': ?host};
    case 'xhttp':
      stream['network'] = 'xhttp';
      stream['xhttpSettings'] = {
        'path': ?path,
        'host': ?host,
        'mode': _nonEmpty(v, 'mode') ?? 'auto',
      };
    case 'grpc':
      stream['network'] = 'grpc';
      stream['grpcSettings'] = {
        'serviceName': _text(v, 'serviceName'),
        'multiMode': _on(v, 'multiMode'),
      };
    case 'kcp':
      stream['network'] = 'kcp';
  }
  final serverName = host ?? address;
  if (_tls(v)) {
    stream['security'] = 'tls';
    stream['tlsSettings'] = _tlsSettings(kind, v, serverName);
  } else if (_reality(v)) {
    stream['security'] = 'reality';
    stream['realitySettings'] = {
      'serverName': _nonEmpty(v, 'sni') ?? serverName,
      'fingerprint': _choice(v, 'fingerprint') ?? 'chrome',
      'publicKey': _text(v, 'publicKey'),
      'shortId': _text(v, 'shortId'),
      'spiderX': _nonEmpty(v, 'spiderX') ?? '/',
      'mldsa65Verify': ?_nonEmpty(v, 'mldsa65Verify'),
    };
  }
  return stream;
}

const _fragmentMask = {
  'type': 'fragment',
  'settings': {'packets': 'tlshello', 'length': '100-200', 'delay': '10-20'},
};

const _muxSettings = {'enabled': true, 'concurrency': 8};

String _protocolOf(NodeKind kind) => switch (kind) {
  NodeKind.socks => 'socks',
  NodeKind.http => 'http',
  NodeKind.shadowsocks => 'shadowsocks',
  NodeKind.vmess => 'vmess',
  NodeKind.vless => 'vless',
  NodeKind.trojan => 'trojan',
  NodeKind.hysteria => 'hysteria',
  NodeKind.hysteria2 => 'hysteria2',
  NodeKind.tuic => 'tuic',
  NodeKind.anytls => 'anytls',
  NodeKind.mieru => 'mieru',
};

Map<String, dynamic> _outbound(NodeKind kind, Map<String, String> v) {
  final address = _text(v, 'address');
  final port = int.parse(_text(v, 'port'));
  final protocol = _protocolOf(kind);
  final remark = _text(v, 'remark');
  final prefix = kind == NodeKind.shadowsocks ? 'ss' : protocol;
  Map<String, dynamic> node(
    Map<String, dynamic> settings, [
    Map<String, dynamic> stream = const {},
  ]) => {
    'tag': remark.isEmpty ? '$prefix-$address:$port' : remark,
    'protocol': protocol,
    'settings': {'address': address, 'port': port, ...settings},
    if (stream.isNotEmpty) 'streamSettings': stream,
  };

  switch (kind) {
    case NodeKind.socks || NodeKind.http:
      return node(
        {'user': ?_nonEmpty(v, 'username'), 'pass': ?_nonEmpty(v, 'password')},
        {
          if (_tls(v)) ...{
            'network': 'tcp',
            'security': 'tls',
            'tlsSettings': _tlsSettings(kind, v, address),
          },
        },
      );
    case NodeKind.mieru:
      final multiplexing = _choice(v, 'multiplexing');
      final handshake = _choice(v, 'handshake');
      final mtu = int.tryParse(_text(v, 'mtu'));
      return node({
        'username': _text(v, 'username'),
        'password': _text(v, 'password'),
        'transport': _text(v, 'transport'),
        if (multiplexing != null)
          'multiplexing': 'MULTIPLEXING_${multiplexing.toUpperCase()}',
        if (handshake != null)
          'handshakeMode':
              'HANDSHAKE_${handshake.toUpperCase().replaceAll('-', '_')}',
        if (mtu != null && mtu > 0) 'mtu': mtu,
      });
    case NodeKind.shadowsocks:
      return node({
        'method': _text(v, 'method'),
        'password': _text(v, 'password'),
      });
    case NodeKind.vmess:
      return node({
        'id': _text(v, 'uuid'),
        'security': _text(v, 'method'),
      }, _stream(kind, v));
    case NodeKind.vless:
      return node({
        'id': _text(v, 'uuid'),
        'encryption': _nonEmpty(v, 'encryption') ?? 'none',
        if (!_noFlow(v)) 'flow': _text(v, 'flow'),
      }, _stream(kind, v));
    case NodeKind.trojan:
      return node({'password': _text(v, 'password')}, _stream(kind, v));
    case NodeKind.hysteria:
      final obfs = _nonEmpty(v, 'obfsPassword');
      return node({
        'auth': _text(v, 'password'),
        'up': '${_text(v, 'uploadSpeed')}mbps',
        'down': '${_text(v, 'downloadSpeed')}mbps',
        if (obfs != null) ...{'obfs': 'xplus', 'obfsPassword': obfs},
        'serverName': ?_nonEmpty(v, 'sni'),
        if (_on(v, 'allowInsecure')) 'allowInsecure': true,
      });
    case NodeKind.hysteria2:
      final obfs = _nonEmpty(v, 'obfsPassword');
      final ports = _nonEmpty(v, 'ports');
      return node(
        {'version': 2},
        {
          'network': 'hysteria2',
          'security': 'tls',
          'tlsSettings': _tlsSettings(kind, v, address, alpn: const ['h3']),
          'hysteria2Settings': {'version': 2, 'auth': _text(v, 'password')},
          if (obfs != null || ports != null)
            'finalmask': {
              'udp': [
                if (obfs != null)
                  {
                    'type': 'salamander',
                    'settings': {'password': obfs},
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
      );
    case NodeKind.tuic:
      return node(
        {
          'id': _text(v, 'uuid'),
          'password': _text(v, 'password'),
          'congestionControl': _text(v, 'congestion'),
          'udpStream': v['udpRelay'] == 'quic',
        },
        {
          'network': 'tuic',
          'security': 'tls',
          'tlsSettings': _tlsSettings(kind, v, address, alpn: const ['h3']),
        },
      );
    case NodeKind.anytls:
      return node(
        {'password': _text(v, 'password')},
        {
          'network': 'tcp',
          'security': 'tls',
          'tlsSettings': _tlsSettings(kind, v, address),
        },
      );
  }
}

/// [outbound] with the settings no share link carries: how its sockets are
/// opened, the node they are opened through, and the multiplexing on top.
Map<String, dynamic> _withExtras(
  NodeKind kind,
  Map<String, String> v,
  Map<String, dynamic> outbound,
) {
  final dialerProxy = nodeFields(kind).any((f) => f.key == 'dialerProxy')
      ? _nonEmpty(v, 'dialerProxy')
      : null;
  final sockopt = {
    if (_active(kind, v, 'tcpFastOpen')) 'tcpFastOpen': true,
    'dialerProxy': ?dialerProxy,
  };
  final fragment = _active(kind, v, 'fragment');
  if (sockopt.isEmpty && !fragment && !_active(kind, v, 'mux')) {
    return outbound;
  }
  final stream = {...?outbound['streamSettings'] as Map<String, dynamic>?};
  if (sockopt.isNotEmpty) stream['sockopt'] = sockopt;
  if (fragment) {
    stream['finalmask'] = {
      'tcp': [_fragmentMask],
    };
  }
  return {
    ...outbound,
    if (stream.isNotEmpty) 'streamSettings': stream,
    if (_active(kind, v, 'mux')) 'mux': _muxSettings,
  };
}

/// The share link the form's values stand for; null when the values cannot
/// form a node or its protocol has no link.
String? buildNodeLink(NodeKind kind, Map<String, String> values) {
  final outbound = buildNodeOutbound(kind, values);
  return outbound == null ? null : nodeShareLink(outbound);
}

/// The outbound the form's values make, or null when they make none.
Map<String, dynamic>? buildNodeOutbound(
  NodeKind kind,
  Map<String, String> values,
) {
  if (nodeFormProblem(kind, values) != null) return null;
  return _withRegion(
    _withExtras(kind, values, _outbound(kind, values)),
    values,
  );
}

/// The country the user placed the server in is kept beside the outbound, not
/// in it: the Core never sees it.
Map<String, dynamic> _withRegion(
  Map<String, dynamic> outbound,
  Map<String, String> values,
) {
  final region = _text(values, 'region').toUpperCase();
  return region.isEmpty ? outbound : {...outbound, 'region': region};
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

String _str(Object? value) => value == null ? '' : '$value';

String _join(Object? value) => value is List ? value.join(',') : _str(value);

bool _sameJson(Object? a, Object? b) {
  if (a is Map && b is Map) {
    return a.length == b.length &&
        a.keys.every((key) => b.containsKey(key) && _sameJson(a[key], b[key]));
  }
  if (a is List && b is List) {
    return a.length == b.length &&
        List.generate(a.length, (i) => _sameJson(a[i], b[i])).every((x) => x);
  }
  return a == b;
}

NodeKind? _kindOfProtocol(String protocol) => switch (protocol) {
  'shadowsocks' => NodeKind.shadowsocks,
  'vmess' => NodeKind.vmess,
  'vless' => NodeKind.vless,
  'socks' => NodeKind.socks,
  'http' => NodeKind.http,
  'trojan' => NodeKind.trojan,
  'hysteria' => NodeKind.hysteria,
  'hysteria2' => NodeKind.hysteria2,
  'tuic' => NodeKind.tuic,
  'anytls' => NodeKind.anytls,
  'mieru' => NodeKind.mieru,
  _ => null,
};

Map<String, String> _tlsValues(Map<String, dynamic> tls) => {
  'sni': _str(tls['serverName']),
  'alpn': _join(tls['alpn']),
  'fingerprint': tls['fingerprint'] == null
      ? nodeDefaultChoice
      : _str(tls['fingerprint']),
  'allowInsecure': '${tls['allowInsecure'] == true}',
  'ech': _str(tls['echConfigList']),
  'pin': _str(tls['pinnedPeerCertSha256']),
};

Map<String, String> _streamValues(Map<String, dynamic> stream) {
  final network = _str(stream['network']);
  final header = _map(_map(stream['rawSettings'])['header']);
  final request = _map(header['request']);
  final options = _map(stream['${network}Settings']);
  final grpc = _map(stream['grpcSettings']);
  final reality = _map(stream['realitySettings']);
  final security = _str(stream['security']);
  final rawPath = request['path'];
  return {
    'network': network.isEmpty || network == 'tcp' ? 'raw' : network,
    'headerType': header['type'] == 'http' ? 'http' : 'none',
    'path': header['type'] == 'http'
        ? (rawPath is List && rawPath.isNotEmpty ? _str(rawPath.first) : '')
        : _str(options['path']),
    'host': header['type'] == 'http'
        ? _join(_map(request['headers'])['Host'])
        : _str(options['host']),
    'mode': _str(options['mode']),
    'serviceName': _str(grpc['serviceName']),
    'multiMode': '${grpc['multiMode'] == true}',
    'security': security.isEmpty ? 'none' : security,
    ..._tlsValues(_map(stream['tlsSettings'])),
    if (security == 'reality') ...{
      'sni': _str(reality['serverName']),
      'fingerprint': _str(reality['fingerprint']),
      'publicKey': _str(reality['publicKey']),
      'shortId': _str(reality['shortId']),
      'spiderX': reality['spiderX'] == '/' ? '' : _str(reality['spiderX']),
      'mldsa65Verify': _str(reality['mldsa65Verify']),
    },
  };
}

/// What the extras of [_withExtras] read back as.
Map<String, String> _extraValues(Map<String, dynamic> outbound) {
  final stream = _map(outbound['streamSettings']);
  final sockopt = _map(stream['sockopt']);
  final tcpMasks = _map(stream['finalmask'])['tcp'];
  return {
    'tcpFastOpen': '${sockopt['tcpFastOpen'] == true}',
    'dialerProxy': _str(sockopt['dialerProxy']),
    'fragment':
        '${tcpMasks is List && tcpMasks.any((mask) => _map(mask)['type'] == 'fragment')}',
    'mux': '${_map(outbound['mux'])['enabled'] == true}',
  };
}

Map<String, String> _valuesOf(NodeKind kind, Map<String, dynamic> outbound) {
  final settings = _map(outbound['settings']);
  final stream = _map(outbound['streamSettings']);
  final tls = _tlsValues(_map(stream['tlsSettings']));
  final common = {
    'address': _str(settings['address']),
    'port': _str(settings['port']),
    'remark': _str(outbound['tag']),
    'region': _str(outbound['region']),
    ..._extraValues(outbound),
  };
  switch (kind) {
    case NodeKind.shadowsocks:
      return {
        ...common,
        'password': _str(settings['password']),
        'method': _str(settings['method']),
      };
    case NodeKind.vmess:
      return {
        ...common,
        ..._streamValues(stream),
        'uuid': _str(settings['id']),
        'method': _str(settings['security']),
      };
    case NodeKind.vless:
      final encryption = _str(settings['encryption']);
      return {
        ...common,
        ..._streamValues(stream),
        'uuid': _str(settings['id']),
        'encryption': encryption == 'none' ? '' : encryption,
        'flow': settings['flow'] == null ? 'none' : _str(settings['flow']),
      };
    case NodeKind.trojan:
      return {
        ...common,
        ..._streamValues(stream),
        'password': _str(settings['password']),
      };
    case NodeKind.hysteria:
      String mbps(Object? value) => _str(value).replaceAll('mbps', '');
      return {
        ...common,
        'password': _str(settings['auth']),
        'uploadSpeed': mbps(settings['up']),
        'downloadSpeed': mbps(settings['down']),
        'sni': _str(settings['serverName']),
        'allowInsecure': '${settings['allowInsecure'] == true}',
        'obfsPassword': _str(settings['obfsPassword']),
      };
    case NodeKind.hysteria2:
      final udp = _map(stream['finalmask'])['udp'];
      Map<String, dynamic> mask(String type) {
        final masks = udp is List
            ? udp.map(_map)
            : const <Map<String, dynamic>>[];
        return _map(
          masks.where((m) => m['type'] == type).firstOrNull?['settings'],
        );
      }

      return {
        ...common,
        ...tls,
        'password': _str(_map(stream['hysteria2Settings'])['auth']),
        'ports': _str(mask('udphop')['remotePorts']),
        'obfsPassword': _str(mask('salamander')['password']),
      };
    case NodeKind.tuic:
      return {
        ...common,
        ...tls,
        'uuid': _str(settings['id']),
        'password': _str(settings['password']),
        'congestion': _str(settings['congestionControl']),
        'udpRelay': settings['udpStream'] == true ? 'quic' : 'native',
      };
    case NodeKind.anytls:
      return {...common, ...tls, 'password': _str(settings['password'])};
    case NodeKind.socks || NodeKind.http:
      return {
        ...common,
        ...tls,
        'username': _str(settings['user']),
        'password': _str(settings['pass']),
        'security': stream['security'] == 'tls' ? 'tls' : 'none',
      };
    case NodeKind.mieru:
      String level(Object? value, String prefix) => value == null
          ? nodeDefaultChoice
          : _str(
              value,
            ).replaceFirst(prefix, '').toLowerCase().replaceAll('_', '-');
      return {
        ...common,
        'username': _str(settings['username']),
        'password': _str(settings['password']),
        'transport': _str(settings['transport']),
        'multiplexing': level(settings['multiplexing'], 'MULTIPLEXING_'),
        'handshake': level(settings['handshakeMode'], 'HANDSHAKE_'),
        'mtu': _str(settings['mtu']),
      };
  }
}

/// The form an [outbound] fills in, or null when the form cannot hold it
/// exactly: whatever the form would build in its place must equal it, so that
/// an edit never drops a setting the form has no field for.
({NodeKind kind, Map<String, String> values})? nodeFormOf(
  Map<String, dynamic> outbound,
) {
  final kind = _kindOfProtocol(_str(outbound['protocol']));
  if (kind == null) return null;
  final values = {...nodeDefaults(kind), ..._valuesOf(kind, outbound)}
    ..removeWhere((key, _) => !nodeDefaults(kind).containsKey(key));
  final rebuilt = buildNodeOutbound(kind, values);
  if (rebuilt == null) return null;
  final original = {...outbound}..remove('tag');
  if (!_sameJson(original, {...rebuilt}..remove('tag'))) return null;
  return (kind: kind, values: values);
}

const _portableFields = {
  'address',
  'port',
  'remark',
  'region',
  'password',
  'uuid',
  'username',
  'network',
  'headerType',
  'path',
  'host',
  'mode',
  'serviceName',
  'multiMode',
  'sni',
  'allowInsecure',
  'alpn',
  'ech',
  'pin',
  'fingerprint',
  'fragment',
  'obfsPassword',
  'mux',
  'tcpFastOpen',
  'dialerProxy',
};

/// The values a server of [kind] starts with when it takes over [from] from
/// another kind: what means the same in both is kept, the rest is default.
Map<String, String> nodeValuesFor(NodeKind kind, Map<String, String> from) {
  final defaults = nodeDefaults(kind);
  return {
    for (final entry in defaults.entries)
      entry.key: _portableFields.contains(entry.key) && from[entry.key] != null
          ? from[entry.key]!
          : entry.value,
  };
}

/// The settings map that holds the server of [settings]: itself when flat, as
/// the app writes it, or the first of `vnext` or `servers` of older configs.
Map<String, dynamic>? _endpointHolder(Map<String, dynamic> settings) {
  for (final key in ['vnext', 'servers']) {
    final list = settings[key];
    if (list is List && list.isNotEmpty && list.first is Map) {
      return (list.first as Map).cast<String, dynamic>();
    }
  }
  return settings.containsKey('address') ? settings : null;
}

/// Where the server of [outbound] is, or null when it names none, as with a
/// protocol whose servers sit elsewhere.
({String address, String port})? nodeEndpointOf(Map<String, dynamic> outbound) {
  final holder = _endpointHolder(_map(outbound['settings']));
  if (holder == null) return null;
  return (address: _str(holder['address']), port: _str(holder['port']));
}

/// [outbound] with its name, address and port replaced and every other
/// setting kept as it was.
Map<String, dynamic> withNodeEndpoint(
  Map<String, dynamic> outbound, {
  required String name,
  String? address,
  int? port,
}) {
  final copy = (jsonDecode(jsonEncode(outbound)) as Map)
      .cast<String, dynamic>();
  copy['tag'] = name;
  final settings = copy['settings'];
  final holder = settings is Map
      ? _endpointHolder(settings.cast<String, dynamic>())
      : null;
  if (holder != null) {
    if (address != null) holder['address'] = address;
    if (port != null) holder['port'] = port;
  }
  return copy;
}
