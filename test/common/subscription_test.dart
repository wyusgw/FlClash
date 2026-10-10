import 'dart:convert';

import 'package:fl_clash/common/subscription.dart';
import 'package:flutter_test/flutter_test.dart';

const _vmessJson =
    '{"v":"2","ps":"vm-ws","add":"vm.example.com","port":"443",'
    '"id":"b831381d-6324-4d53-ad4f-8cda48b30811","aid":"0","scy":"auto",'
    '"net":"ws","type":"none","host":"vm.example.com","path":"/ws",'
    '"tls":"tls","sni":"vm.example.com"}';

final _vmess = 'vmess://${base64.encode(utf8.encode(_vmessJson))}';

const _uuid = 'b831381d-6324-4d53-ad4f-8cda48b30811';
const _publicKey = 'AQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHyA';

const _vless =
    'vless://$_uuid@vl.example.com:443?type=tcp&security=reality'
    '&encryption=none&flow=xtls-rprx-vision&sni=www.microsoft.com&fp=chrome'
    '&pbk=$_publicKey&sid=6ba85179e30d4fc2&spx=%2F#vless-reality';

const _trojan =
    'trojan://pass@tj.example.com:443?security=tls&sni=tj.example.com'
    '&type=ws&path=%2Ftj#trojan-ws';

const _ss = 'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ@1.2.3.4:8388#ss-sip002';
const _ssLegacy =
    'ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpwd0A1LjYuNy44Ojg0NDM=#ss-legacy';

const _hysteria =
    'hysteria2://auth@hy.example.com:443?sni=hy.example.com'
    '&obfs=salamander&obfs-password=obfs#hy2';

const _tuic =
    'tuic://$_uuid:pw@tu.example.com:443?congestion_control=bbr&alpn=h3'
    '&sni=tu.example.com#tuic';

const _anytls = 'anytls://pw@at.example.com:443?sni=at.example.com#anytls';

Map<String, dynamic> _node(String link) {
  final nodes = parseSubscription(link);
  expect(nodes, hasLength(1), reason: link);
  return nodes.single;
}

void main() {
  group('share links', () {
    test('vmess carries its websocket transport and tls', () {
      final node = _node(_vmess);

      expect(node['tag'], 'vm-ws');
      expect(node['protocol'], 'vmess');
      expect(node['settings'], {
        'address': 'vm.example.com',
        'port': 443,
        'id': _uuid,
        'security': 'auto',
      });
      final stream = node['streamSettings'] as Map<String, dynamic>;
      expect(stream['network'], 'ws');
      expect(stream['wsSettings'], {'path': '/ws', 'host': 'vm.example.com'});
      expect(stream['security'], 'tls');
      expect((stream['tlsSettings'] as Map)['serverName'], 'vm.example.com');
    });

    test('vless reality keeps the key, short id and flow', () {
      final node = _node(_vless);

      expect(node['protocol'], 'vless');
      expect(node['settings'], {
        'address': 'vl.example.com',
        'port': 443,
        'id': _uuid,
        'encryption': 'none',
        'flow': 'xtls-rprx-vision',
      });
      final stream = node['streamSettings'] as Map<String, dynamic>;
      expect(stream['security'], 'reality');
      expect(stream['realitySettings'], {
        'serverName': 'www.microsoft.com',
        'fingerprint': 'chrome',
        'publicKey': _publicKey,
        'shortId': '6ba85179e30d4fc2',
        'spiderX': '/',
      });
    });

    test('vless to a public host without tls is dropped', () {
      expect(
        parseSubscription('vless://$_uuid@vl.example.com:443?type=tcp#x'),
        isEmpty,
      );
    });

    test('vless to a private host may go without tls', () {
      final node = _node('vless://$_uuid@192.168.1.5:443?type=tcp#lan');

      expect(node['tag'], 'lan');
      expect(node.containsKey('streamSettings'), isFalse);
    });

    test('vless reality without a public key is dropped', () {
      expect(
        parseSubscription(
          'vless://$_uuid@vl.example.com:443?security=reality&sni=a.com#x',
        ),
        isEmpty,
      );
    });

    test('trojan defaults to tls and reads the websocket path', () {
      final node = _node(_trojan);

      expect(node['protocol'], 'trojan');
      expect((node['settings'] as Map)['password'], 'pass');
      final stream = node['streamSettings'] as Map<String, dynamic>;
      expect(stream['security'], 'tls');
      expect((stream['wsSettings'] as Map)['path'], '/tj');
    });

    test('shadowsocks reads both the SIP002 and the legacy form', () {
      expect(_node(_ss)['settings'], {
        'address': '1.2.3.4',
        'port': 8388,
        'method': 'aes-256-gcm',
        'password': 'password',
      });
      expect(_node(_ssLegacy)['settings'], {
        'address': '5.6.7.8',
        'port': 8443,
        'method': 'chacha20-ietf-poly1305',
        'password': 'pw',
      });
    });

    test('shadowsocks with a plugin or an old cipher is dropped', () {
      expect(
        parseSubscription(
          'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ@1.2.3.4:8388?plugin=obfs-local#p',
        ),
        isEmpty,
      );
      expect(
        parseSubscription(
          'ss://${base64.encode(utf8.encode('rc4-md5:pw'))}@1.2.3.4:8388#old',
        ),
        isEmpty,
      );
    });

    test('hysteria2 puts the auth in the stream settings', () {
      final node = _node(_hysteria);

      expect(node['protocol'], 'hysteria');
      expect(node['settings'], {
        'version': 2,
        'address': 'hy.example.com',
        'port': 443,
      });
      final stream = node['streamSettings'] as Map<String, dynamic>;
      expect(stream['network'], 'hysteria');
      expect(stream['hysteriaSettings'], {'version': 2, 'auth': 'auth'});
      expect(stream['finalmask'], {
        'udp': [
          {
            'type': 'salamander',
            'settings': {'password': 'obfs'},
          },
        ],
      });
    });

    test('hy2 is the same as hysteria2', () {
      expect(
        _node(_hysteria.replaceFirst('hysteria2://', 'hy2://'))['protocol'],
        'hysteria',
      );
    });

    test('tuic keeps the congestion control and the alpn', () {
      final node = _node(_tuic);

      expect(node['settings'], {
        'address': 'tu.example.com',
        'port': 443,
        'id': _uuid,
        'password': 'pw',
        'congestionControl': 'bbr',
        'udpStream': false,
      });
      final stream = node['streamSettings'] as Map<String, dynamic>;
      expect(stream['network'], 'tuic');
      expect((stream['tlsSettings'] as Map)['alpn'], ['h3']);
    });

    test('anytls reads the password and the server name', () {
      final node = _node(_anytls);

      expect(node['protocol'], 'anytls');
      expect((node['settings'] as Map)['password'], 'pw');
      expect(
        ((node['streamSettings'] as Map)['tlsSettings'] as Map)['serverName'],
        'at.example.com',
      );
    });

    test('a link with a bad port is skipped', () {
      expect(parseSubscription('trojan://p@tj.example.com:99999#x'), isEmpty);
    });

    test('an unknown scheme is skipped', () {
      expect(parseSubscription('ftp://example.com/file'), isEmpty);
    });
  });

  group('subscription shapes', () {
    final links = [_vmess, _vless, _trojan, _ss, _hysteria, _tuic, _anytls];

    test('plain lines', () {
      final nodes = parseSubscription(links.join('\n'));

      expect(nodes.map((node) => node['tag']), [
        'vm-ws',
        'vless-reality',
        'trojan-ws',
        'ss-sip002',
        'hy2',
        'tuic',
        'anytls',
      ]);
    });

    test('a base64 blob, padded or not, standard or url-safe', () {
      final blob = utf8.encode(links.join('\n'));
      for (final encoded in [
        base64.encode(blob),
        base64.encode(blob).replaceAll('=', ''),
        base64Url.encode(blob),
        base64Url.encode(blob).replaceAll('=', ''),
      ]) {
        expect(parseSubscription(encoded), hasLength(links.length));
      }
    });

    test('windows line endings and blank lines', () {
      expect(
        parseSubscription('\r\n${links.join('\r\n\r\n')}\r\n'),
        hasLength(links.length),
      );
    });

    test('an Xray config keeps the supported outbounds only', () {
      final nodes = parseSubscription(
        json.encode({
          'outbounds': [
            {'tag': 'a', 'protocol': 'VLESS', 'settings': {}},
            {'tag': 'direct', 'protocol': 'freedom'},
            {'tag': 'b', 'protocol': 'trojan', 'settings': {}},
          ],
        }),
      );

      expect(nodes.map((node) => node['tag']), ['a', 'b']);
      expect(nodes.first['protocol'], 'vless');
    });

    test('empty and unreadable content gives nothing', () {
      expect(parseSubscription(''), isEmpty);
      expect(parseSubscription('   \n'), isEmpty);
      expect(parseSubscription('{not json'), isEmpty);
      expect(parseSubscription('proxies:\n  - name: a'), isEmpty);
    });
  });

  group('tags', () {
    test('duplicates are numbered', () {
      final nodes = parseSubscription([_trojan, _trojan, _trojan].join('\n'));

      expect(nodes.map((node) => node['tag']), [
        'trojan-ws',
        'trojan-ws (2)',
        'trojan-ws (3)',
      ]);
    });

    test(
      'a leading @ is stripped so no tag collides with the app outbounds',
      () {
        final node = _node(
          'trojan://p@tj.example.com:443?security=tls#%40direct',
        );

        expect(node['tag'], 'direct');
      },
    );

    test('a node without a name is named after its protocol and address', () {
      expect(
        _node('trojan://p@tj.example.com:443?security=tls')['tag'],
        'trojan-tj.example.com:443',
      );
    });
  });
}
