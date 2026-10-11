import 'package:fl_clash/common/node_form.dart';
import 'package:fl_clash/common/subscription.dart';
import 'package:flutter_test/flutter_test.dart';

const _uuid = 'b831381d-6324-4d53-ad4f-8cda48b30811';

Map<String, String> _values(
  NodeKind kind, [
  Map<String, String> more = const {},
]) {
  return {
    ...nodeDefaults(kind),
    'address': 'node.example.com',
    'port': '443',
    ...more,
  };
}

Map<String, dynamic> _outbound(NodeKind kind, Map<String, String> values) {
  final outbound = buildNodeOutbound(kind, values);
  expect(outbound, isNotNull, reason: '$kind did not build from $values');
  return outbound!;
}

Map _settings(Map<String, dynamic> outbound) => outbound['settings'] as Map;

Map _stream(Map<String, dynamic> outbound) =>
    (outbound['streamSettings'] ?? const {}) as Map;

void main() {
  group('defaults and problems', () {
    test('every kind starts with its own choices selected', () {
      expect(nodeDefaults(NodeKind.shadowsocks)['method'], 'aes-256-gcm');
      expect(nodeDefaults(NodeKind.vless)['security'], 'tls');
      expect(nodeDefaults(NodeKind.tuic)['congestion'], 'bbr');
      expect(nodeDefaults(NodeKind.vmess)['tls'], 'false');
    });

    test('the first missing required field is named', () {
      expect(
        nodeFormProblem(NodeKind.trojan, nodeDefaults(NodeKind.trojan)),
        'address',
      );
      expect(
        nodeFormProblem(NodeKind.trojan, {
          ...nodeDefaults(NodeKind.trojan),
          'address': 'a.com',
          'port': '443',
        }),
        'password',
      );
    });

    test('a port outside 1-65535 is a problem', () {
      for (final port in ['0', '65536', 'abc', '-1']) {
        expect(
          nodeFormProblem(
            NodeKind.shadowsocks,
            _values(NodeKind.shadowsocks, {'password': 'pw', 'port': port}),
          ),
          'port',
          reason: port,
        );
      }
      expect(
        nodeFormProblem(
          NodeKind.shadowsocks,
          _values(NodeKind.shadowsocks, {'password': 'pw', 'port': '65535'}),
        ),
        isNull,
      );
    });

    test('a field that is hidden is not required', () {
      final reality = _values(NodeKind.vless, {
        'uuid': _uuid,
        'security': 'reality',
      });
      expect(nodeFormProblem(NodeKind.vless, reality), 'publicKey');
      final tls = _values(NodeKind.vless, {'uuid': _uuid, 'security': 'tls'});
      expect(nodeFormProblem(NodeKind.vless, tls), isNull);
    });

    test('nothing builds while the form is incomplete', () {
      expect(
        buildNodeLink(NodeKind.anytls, nodeDefaults(NodeKind.anytls)),
        isNull,
      );
    });
  });

  group('each protocol builds the outbound the subscription reader would', () {
    test('shadowsocks', () {
      final outbound = _outbound(
        NodeKind.shadowsocks,
        _values(NodeKind.shadowsocks, {
          'password': 'p@ss:w/rd',
          'method': 'chacha20-poly1305',
          'remark': 'My SS',
        }),
      );

      expect(outbound['protocol'], 'shadowsocks');
      expect(outbound['tag'], 'My SS');
      expect(_settings(outbound), {
        'address': 'node.example.com',
        'port': 443,
        'method': 'chacha20-poly1305',
        'password': 'p@ss:w/rd',
      });
    });

    test('vmess over websocket with tls', () {
      final outbound = _outbound(
        NodeKind.vmess,
        _values(NodeKind.vmess, {
          'uuid': _uuid,
          'network': 'ws',
          'path': '/ws',
          'host': 'cdn.example.com',
          'tls': 'true',
          'sni': 'sni.example.com',
          'remark': 'vm',
        }),
      );

      expect(outbound['protocol'], 'vmess');
      expect(outbound['tag'], 'vm');
      expect(_settings(outbound)['id'], _uuid);
      final stream = _stream(outbound);
      expect(stream['network'], 'ws');
      expect((stream['wsSettings'] as Map)['path'], '/ws');
      expect(stream['security'], 'tls');
      expect((stream['tlsSettings'] as Map)['serverName'], 'sni.example.com');
    });

    test('vmess over grpc keeps the service name', () {
      final outbound = _outbound(
        NodeKind.vmess,
        _values(NodeKind.vmess, {
          'uuid': _uuid,
          'network': 'grpc',
          'serviceName': 'svc',
          'tls': 'true',
        }),
      );

      expect((_stream(outbound)['grpcSettings'] as Map)['serviceName'], 'svc');
    });

    test('vless with tls and a flow', () {
      final outbound = _outbound(
        NodeKind.vless,
        _values(NodeKind.vless, {
          'uuid': _uuid,
          'flow': 'xtls-rprx-vision',
          'sni': 'sni.example.com',
          'allowInsecure': 'true',
        }),
      );

      expect(outbound['protocol'], 'vless');
      expect(_settings(outbound)['flow'], 'xtls-rprx-vision');
      final tls = _stream(outbound)['tlsSettings'] as Map;
      expect(tls['serverName'], 'sni.example.com');
      expect(tls['allowInsecure'], true);
    });

    test('vless with reality', () {
      final outbound = _outbound(
        NodeKind.vless,
        _values(NodeKind.vless, {
          'uuid': _uuid,
          'security': 'reality',
          'sni': 'www.microsoft.com',
          'publicKey': 'AQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHyA',
          'shortId': '6ba85179e30d4fc2',
        }),
      );

      final reality = _stream(outbound)['realitySettings'] as Map;
      expect(_stream(outbound)['security'], 'reality');
      expect(reality['serverName'], 'www.microsoft.com');
      expect(reality['shortId'], '6ba85179e30d4fc2');
      expect(reality['fingerprint'], 'chrome');
    });

    test('vless without any security is refused for a public address', () {
      expect(
        buildNodeOutbound(
          NodeKind.vless,
          _values(NodeKind.vless, {'uuid': _uuid, 'security': 'none'}),
        ),
        isNull,
      );
    });

    test('trojan over websocket', () {
      final outbound = _outbound(
        NodeKind.trojan,
        _values(NodeKind.trojan, {
          'password': 'secret',
          'network': 'ws',
          'path': '/tj',
        }),
      );

      expect(outbound['protocol'], 'trojan');
      expect(_settings(outbound)['password'], 'secret');
      expect(_stream(outbound)['network'], 'ws');
      expect(_stream(outbound)['security'], 'tls');
    });

    test('hysteria asks for its speeds and masks with xplus', () {
      final outbound = _outbound(
        NodeKind.hysteria,
        _values(NodeKind.hysteria, {
          'password': 'auth',
          'uploadSpeed': '30',
          'downloadSpeed': '80',
          'obfsPassword': 'mask',
          'sni': 'sni.example.com',
        }),
      );

      expect(outbound['protocol'], 'hysteria');
      expect(_settings(outbound), {
        'address': 'node.example.com',
        'port': 443,
        'auth': 'auth',
        'up': '30mbps',
        'down': '80mbps',
        'obfs': 'xplus',
        'obfsPassword': 'mask',
        'serverName': 'sni.example.com',
      });
      expect(outbound.containsKey('streamSettings'), isFalse);
    });

    test('hysteria without a usable speed is not complete', () {
      for (final speed in ['', '0', 'fast']) {
        expect(
          nodeFormProblem(
            NodeKind.hysteria,
            _values(NodeKind.hysteria, {
              'password': 'pw',
              'uploadSpeed': speed,
            }),
          ),
          'uploadSpeed',
        );
      }
    });

    test('hysteria2 with an obfuscation password', () {
      final outbound = _outbound(
        NodeKind.hysteria2,
        _values(NodeKind.hysteria2, {
          'password': 'auth',
          'obfsPassword': 'mask',
          'allowInsecure': 'true',
        }),
      );

      expect(outbound['protocol'], 'hysteria2');
      final stream = _stream(outbound);
      expect((stream['hysteria2Settings'] as Map)['auth'], 'auth');
      expect((stream['tlsSettings'] as Map)['allowInsecure'], true);
      expect(stream['finalmask'], isNotNull);
    });

    test('tuic with a congestion control', () {
      final outbound = _outbound(
        NodeKind.tuic,
        _values(NodeKind.tuic, {
          'uuid': _uuid,
          'password': 'pw',
          'congestion': 'cubic',
        }),
      );

      expect(outbound['protocol'], 'tuic');
      expect(_settings(outbound)['id'], _uuid);
      expect(_settings(outbound)['password'], 'pw');
      expect(_settings(outbound)['congestionControl'], 'cubic');
    });

    test('anytls', () {
      final outbound = _outbound(
        NodeKind.anytls,
        _values(NodeKind.anytls, {'password': 'pw', 'sni': 'a.example.com'}),
      );

      expect(outbound['protocol'], 'anytls');
      expect(
        (_stream(outbound)['tlsSettings'] as Map)['serverName'],
        'a.example.com',
      );
    });

    test('socks5 with a login', () {
      final outbound = _outbound(
        NodeKind.socks,
        _values(NodeKind.socks, {
          'username': 'user',
          'password': 'pw',
          'port': '1080',
        }),
      );

      expect(outbound['protocol'], 'socks');
      expect(_settings(outbound), {
        'address': 'node.example.com',
        'port': 1080,
        'user': 'user',
        'pass': 'pw',
      });
      expect(outbound.containsKey('streamSettings'), isFalse);
    });

    test('socks5 with no login leaves the credentials out', () {
      final outbound = _outbound(NodeKind.socks, _values(NodeKind.socks));

      expect(_settings(outbound).containsKey('user'), isFalse);
      expect(_settings(outbound).containsKey('pass'), isFalse);
    });

    test('http over tls is https', () {
      final outbound = _outbound(
        NodeKind.http,
        _values(NodeKind.http, {
          'tls': 'true',
          'sni': 'h.example.com',
          'remark': 'secure',
        }),
      );

      expect(outbound['protocol'], 'http');
      expect(outbound['tag'], 'secure');
      expect(_stream(outbound)['security'], 'tls');
      expect(
        (_stream(outbound)['tlsSettings'] as Map)['serverName'],
        'h.example.com',
      );
    });

    test('mieru names the Core values for its choices', () {
      final outbound = _outbound(
        NodeKind.mieru,
        _values(NodeKind.mieru, {
          'username': 'user',
          'password': 'pw',
          'transport': 'UDP',
          'multiplexing': 'high',
          'handshake': 'no-wait',
        }),
      );

      expect(outbound['protocol'], 'mieru');
      expect(_settings(outbound), {
        'address': 'node.example.com',
        'port': 443,
        'username': 'user',
        'password': 'pw',
        'transport': 'UDP',
        'multiplexing': 'MULTIPLEXING_HIGH',
        'handshakeMode': 'HANDSHAKE_NO_WAIT',
      });
    });

    test('mieru needs a username as well as a password', () {
      expect(
        nodeFormProblem(
          NodeKind.mieru,
          _values(NodeKind.mieru, {'password': 'pw'}),
        ),
        'username',
      );
    });

    test('a node with no remark gets its protocol and address as a name', () {
      final outbound = _outbound(
        NodeKind.socks,
        _values(NodeKind.socks, {'port': '1080'}),
      );

      expect(outbound['tag'], 'socks-node.example.com:1080');
    });

    test('the node list reads the transport of a mieru node', () {
      final outbound = _outbound(
        NodeKind.mieru,
        _values(NodeKind.mieru, {
          'username': 'u',
          'password': 'p',
          'transport': 'UDP',
        }),
      );

      expect(nodeToProxy(outbound).network, 'udp');
      expect(nodeToProxy(outbound).type, 'mieru');
    });

    test('an IPv6 address is bracketed and survives', () {
      final outbound = _outbound(
        NodeKind.shadowsocks,
        _values(NodeKind.shadowsocks, {
          'address': '2001:db8::1',
          'password': 'pw',
        }),
      );

      expect(_settings(outbound)['address'], '2001:db8::1');
    });

    test('a node with no remark gets a name from its address', () {
      final outbound = _outbound(
        NodeKind.trojan,
        _values(NodeKind.trojan, {'password': 'pw'}),
      );

      expect(outbound['tag'], contains('node.example.com'));
    });
  });

  group('nodeFormOf', () {
    Map<String, String> sample(NodeKind kind) {
      final more = switch (kind) {
        NodeKind.shadowsocks => {'password': 'pw', 'remark': 'ss node'},
        NodeKind.vmess => {
          'uuid': _uuid,
          'network': 'ws',
          'path': '/ws',
          'host': 'cdn.example.com',
          'tls': 'true',
          'sni': 'node.example.com',
          'remark': 'vm',
        },
        NodeKind.vless => {
          'uuid': _uuid,
          'security': 'reality',
          'flow': 'xtls-rprx-vision',
          'publicKey': 'AQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHyA',
          'shortId': '6ba85179',
          'sni': 'www.microsoft.com',
          'remark': 'vl',
        },
        NodeKind.trojan => {
          'password': 'pw',
          'network': 'grpc',
          'serviceName': 'svc',
          'sni': 'node.example.com',
          'allowInsecure': 'true',
        },
        NodeKind.hysteria => {
          'password': 'auth',
          'obfsPassword': 'mask',
          'uploadSpeed': '50',
          'downloadSpeed': '200',
        },
        NodeKind.hysteria2 => {
          'password': 'auth',
          'obfsPassword': 'mask',
          'sni': 'node.example.com',
        },
        NodeKind.tuic => {
          'uuid': _uuid,
          'password': 'pw',
          'congestion': 'bbr',
          'sni': 'node.example.com',
        },
        NodeKind.anytls => {'password': 'pw', 'sni': 'node.example.com'},
        NodeKind.socks || NodeKind.http => {
          'username': 'u',
          'password': 'p',
          'tls': 'true',
          'sni': 'node.example.com',
        },
        NodeKind.mieru => {
          'username': 'u',
          'password': 'p',
          'transport': 'UDP',
          'multiplexing': 'high',
          'handshake': 'no-wait',
        },
      };
      return _values(kind, more);
    }

    for (final kind in NodeKind.values) {
      test('${kind.name} gives back the values it was built from', () {
        final values = sample(kind);
        final form = nodeFormOf(_outbound(kind, values));

        expect(form, isNotNull);
        expect(form!.kind, kind);
        for (final field in nodeFields(kind)) {
          if (!field.visible(values)) continue;
          // A node without a remark is named from its address.
          if (field.key == 'remark' && (values['remark'] ?? '').isEmpty) {
            continue;
          }
          expect(
            form.values[field.key],
            values[field.key] ?? field.initial,
            reason: field.key,
          );
        }
      });
    }

    test('a node with a setting the form has no field for is not editable', () {
      final outbound = _outbound(NodeKind.vless, sample(NodeKind.vless))
        ..['streamSettings'] = {
          ..._stream(_outbound(NodeKind.vless, sample(NodeKind.vless))),
          'sockopt': {'tcpFastOpen': true},
        };

      expect(nodeFormOf(outbound), isNull);
    });

    test('a protocol the form does not know is not editable', () {
      expect(
        nodeFormOf({'tag': 'x', 'protocol': 'wireguard', 'settings': {}}),
        isNull,
      );
    });
  });

  group('region', () {
    test('the country the user chose is kept beside the outbound', () {
      final outbound = _outbound(
        NodeKind.trojan,
        _values(NodeKind.trojan, {'password': 'pw', 'region': 'jp'}),
      );

      expect(outbound['region'], 'JP');
    });

    test('no country leaves the outbound without the key', () {
      final outbound = _outbound(
        NodeKind.trojan,
        _values(NodeKind.trojan, {'password': 'pw'}),
      );

      expect(outbound.containsKey('region'), isFalse);
    });

    test('it reads back into the form and the node list', () {
      final outbound = _outbound(
        NodeKind.shadowsocks,
        _values(NodeKind.shadowsocks, {'password': 'pw', 'region': 'DE'}),
      );

      expect(nodeFormOf(outbound)!.values['region'], 'DE');
      expect(nodeToProxy(outbound).region, 'DE');
    });

    test('a node with none is shown without one', () {
      final outbound = _outbound(
        NodeKind.shadowsocks,
        _values(NodeKind.shadowsocks, {'password': 'pw'}),
      );

      expect(nodeFormOf(outbound)!.values['region'], '');
      expect(nodeToProxy(outbound).region, isNull);
    });

    test('changing the protocol keeps it', () {
      final values = nodeValuesFor(
        NodeKind.vless,
        _values(NodeKind.shadowsocks, {'region': 'US'}),
      );

      expect(values['region'], 'US');
    });
  });

  group('nodeValuesFor', () {
    test('keeps what means the same and defaults the rest', () {
      final values = nodeValuesFor(NodeKind.trojan, {
        ..._values(NodeKind.vless, {'uuid': _uuid, 'remark': 'keep'}),
        'security': 'reality',
      });

      expect(values['address'], 'node.example.com');
      expect(values['remark'], 'keep');
      expect(values['password'], '');
      expect(values.containsKey('security'), isFalse);
    });
  });
}
