import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/node_form.dart';
import 'package:fl_clash/common/subscription.dart';
import 'package:fl_clash/common/xray_config.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _uuid = 'b831381d-6324-4d53-ad4f-8cda48b30811';
const _publicKey = 'AQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHyA';

final _subscription = [
  'vmess://${base64.encode(utf8.encode('{"v":"2","ps":"vm-ws","add":"vm.example.com","port":"443","id":"$_uuid","aid":"0","scy":"auto","net":"ws","type":"none","host":"vm.example.com","path":"/ws","tls":"tls","sni":"vm.example.com"}'))}',
  'vless://$_uuid@vl.example.com:443?type=tcp&security=reality&encryption=none&flow=xtls-rprx-vision&sni=www.microsoft.com&fp=chrome&pbk=$_publicKey&sid=6ba85179e30d4fc2&spx=%2F#vless-reality',
  'trojan://pass@tj.example.com:443?security=tls&sni=tj.example.com&type=ws&path=%2Ftj#trojan-ws',
  'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ@1.2.3.4:8388#ss-sip002',
  'hysteria2://auth@hy.example.com:443?sni=hy.example.com&obfs=salamander&obfs-password=obfs#hy2',
  'tuic://$_uuid:pw@tu.example.com:443?congestion_control=bbr&alpn=h3&sni=tu.example.com#tuic',
  'anytls://pw@at.example.com:443?sni=at.example.com#anytls',
  'mierus://user:pass@mi.example.com?mtu=1400&multiplexing=MULTIPLEXING_HIGH&port=2000-2010&profile=mieru-range&protocol=UDP',
].join('\n');

MakeRealProfileState _state({
  CoreConfig config = const CoreConfig(),
  List<Map<String, dynamic>>? outbounds,
  String? selectedNode,
  List<String> authentication = const [],
  bool tunInbound = false,
  bool safeMode = false,
  List<Map<String, dynamic>> rules = const [],
}) {
  return MakeRealProfileState(
    outbounds: outbounds ?? parseSubscription(_subscription),
    coreConfig: config,
    routeMode: RouteMode.config,
    selectedNode: selectedNode,
    authentication: authentication,
    tunInbound: tunInbound,
    safeMode: safeMode,
    rules: rules,
  );
}

Map<String, dynamic> _routing(Map<String, dynamic> config) =>
    config['routing'] as Map<String, dynamic>;

List<Map<String, dynamic>> _rules(Map<String, dynamic> config) =>
    (_routing(config)['rules'] as List).cast<Map<String, dynamic>>();

Map<String, dynamic> _finalRule(Map<String, dynamic> config) =>
    _rules(config).last;

/// The Go side loads these same files with the real geo data, so a field the
/// engine would refuse fails there. Regenerate them with
/// `UPDATE_XRAY_FIXTURES=1 flutter test test/common/xray_config_test.dart`.
void _expectFixture(String name, Object? value) {
  final file = File('test/fixtures/xray/$name.json');
  final text = '${const JsonEncoder.withIndent('  ').convert(value)}\n';
  if (Platform.environment['UPDATE_XRAY_FIXTURES'] == '1') {
    file.createSync(recursive: true);
    file.writeAsStringSync(text);
  }
  expect(file.readAsStringSync(), text, reason: '$name is out of date');
}

void main() {
  test('outbounds fixture covers every protocol', () {
    final outbounds = [
      ...parseSubscription(_subscription),
      for (final kind in const [NodeKind.socks, NodeKind.http, NodeKind.mieru])
        buildNodeOutbound(kind, {
          ...nodeDefaults(kind),
          'address': 'proxy.example.com',
          'port': '1080',
          'username': 'user',
          'password': 'pass',
        })!,
      buildNodeOutbound(NodeKind.http, {
        ...nodeDefaults(NodeKind.http),
        'address': 'proxy.example.com',
        'port': '8443',
        'security': 'tls',
        'sni': 'sni.example.com',
        'allowInsecure': 'true',
        'remark': 'https',
      })!,
      buildNodeOutbound(NodeKind.vless, {
        ...nodeDefaults(NodeKind.vless),
        'address': 'vl.example.com',
        'port': '443',
        'uuid': _uuid,
        'network': 'xhttp',
        'path': '/x',
        'mode': 'stream-one',
        'alpn': 'h2,http/1.1',
        'fingerprint': 'hellochrome_131',
        'ech':
            'AEX+DQBBAAAgACB4LaAY9V3ZxwH8+aqH9Vx3tvqiQ5o3qZ9V0bNQZ/8lOgAEAAEAAQASY2xvdWRmbGFyZS1lY2guY29tAAA=',
        'pin': 'AB:${List.filled(31, 'CD').join(':')}',
        'fragment': 'true',
        'mux': 'true',
        'tcpFastOpen': 'true',
        'dialerProxy': 'vm-ws',
        'remark': 'vless-everything',
      })!,
      buildNodeOutbound(NodeKind.trojan, {
        ...nodeDefaults(NodeKind.trojan),
        'address': 'tj.example.com',
        'port': '443',
        'password': 'pw',
        'network': 'grpc',
        'serviceName': 'gs',
        'multiMode': 'true',
        'security': 'reality',
        'publicKey': _publicKey,
        'shortId': '6ba85179e30d4fc2',
        'remark': 'trojan-reality',
      })!,
      buildNodeOutbound(NodeKind.vmess, {
        ...nodeDefaults(NodeKind.vmess),
        'address': 'vm.example.com',
        'port': '443',
        'uuid': _uuid,
        'method': 'zero',
        'network': 'kcp',
        'remark': 'vmess-kcp',
      })!,
      buildNodeOutbound(NodeKind.hysteria2, {
        ...nodeDefaults(NodeKind.hysteria2),
        'address': 'hy.example.com',
        'port': '443',
        'password': 'pw',
        'ports': '20000-30000,443',
        'pin': List.filled(32, 'ab').join(),
        'remark': 'hysteria2-hop',
      })!,
      buildNodeOutbound(NodeKind.tuic, {
        ...nodeDefaults(NodeKind.tuic),
        'address': 'tu.example.com',
        'port': '443',
        'uuid': _uuid,
        'password': 'pw',
        'udpRelay': 'quic',
        'remark': 'tuic-quic',
      })!,
      buildNodeOutbound(NodeKind.anytls, {
        ...nodeDefaults(NodeKind.anytls),
        'address': 'at.example.com',
        'port': '443',
        'password': 'pw',
        'fingerprint': 'firefox',
        'fragment': 'true',
        'tcpFastOpen': 'true',
        'remark': 'anytls-fp',
      })!,
      buildNodeOutbound(NodeKind.socks, {
        ...nodeDefaults(NodeKind.socks),
        'address': 'proxy.example.com',
        'port': '1443',
        'security': 'tls',
        'remark': 'socks-tls',
      })!,
      buildNodeOutbound(NodeKind.hysteria, {
        ...nodeDefaults(NodeKind.hysteria),
        'address': 'hy1.example.com',
        'port': '8443',
        'password': 'auth',
        'obfsPassword': 'mask',
        'remark': 'hysteria1',
        'region': 'JP',
      })!,
    ];

    expect(
      outbounds.map((node) => node['protocol']).toSet(),
      supportedOutboundProtocols,
    );
    _expectFixture('outbounds', {'outbounds': outbounds});
  });

  test('the region a node was placed in never reaches the Core', () {
    final node = buildNodeOutbound(NodeKind.shadowsocks, {
      ...nodeDefaults(NodeKind.shadowsocks),
      'address': 'proxy.example.com',
      'port': '8388',
      'password': 'pw',
      'region': 'JP',
    })!;
    final config = buildXrayConfig(_state(outbounds: [node]));

    expect(node['region'], 'JP');
    expect(
      (config['outbounds'] as List).cast<Map>().first.containsKey('region'),
      isFalse,
    );
  });

  group('rule mode', () {
    final config = buildXrayConfig(_state());

    test(
      'routes private and Chinese traffic direct and the rest to a node',
      () {
        final rules = _rules(config);

        expect(rules[1], {
          'inboundTag': [tunInboundTag],
          'port': '53',
          'outboundTag': dnsOutboundTag,
        });
        expect(rules.map((rule) => rule['outboundTag']).whereType<String>(), [
          directOutboundTag,
          dnsOutboundTag,
          directOutboundTag,
          directOutboundTag,
          directOutboundTag,
          'vm-ws',
        ]);
        expect(_finalRule(config), {
          'network': 'tcp,udp',
          'outboundTag': 'vm-ws',
        });
        _expectFixture('config_rule', config);
      },
    );

    test('has no balancer and no observatory', () {
      expect(_routing(config).containsKey('balancers'), isFalse);
      expect(config.containsKey('observatory'), isFalse);
    });

    test('keeps the nodes and adds the app outbounds after them', () {
      final tags = (config['outbounds'] as List)
          .map((outbound) => (outbound as Map)['tag'])
          .toList();

      expect(tags.skip(8), [
        directOutboundTag,
        blockOutboundTag,
        dnsOutboundTag,
      ]);
    });

    test('listens on loopback only and takes no credentials by default', () {
      final inbound = (config['inbounds'] as List).single as Map;

      expect(inbound['listen'], '127.0.0.1');
      expect(inbound['port'], defaultMixedPort);
      expect(inbound['protocol'], 'mixed');
      expect((inbound['settings'] as Map)['auth'], 'noauth');
    });
  });

  test('global mode sends everything but private addresses to a node', () {
    final config = buildXrayConfig(
      _state(config: const CoreConfig(mode: Mode.global)),
    );

    expect(_finalRule(config)['outboundTag'], 'vm-ws');
    expect(_rules(config).where((rule) => rule.containsKey('domain')), isEmpty);
    _expectFixture('config_global', config);
  });

  test(
    'direct mode routes everything direct and keeps the nodes available',
    () {
      final config = buildXrayConfig(
        _state(config: const CoreConfig(mode: Mode.direct)),
      );

      expect(_finalRule(config), {
        'network': 'tcp,udp',
        'outboundTag': directOutboundTag,
      });
      expect(
        ((config['dns'] as Map)['servers'] as List).whereType<Map>(),
        isEmpty,
      );
      _expectFixture('config_direct', config);
    },
  );

  test('the chosen node takes the proxy rules', () {
    final config = buildXrayConfig(_state(selectedNode: 'trojan-ws'));

    expect(_finalRule(config), {
      'network': 'tcp,udp',
      'outboundTag': 'trojan-ws',
    });
    _expectFixture('config_selected', config);
  });

  test(
    'a chosen node the subscription no longer has falls back to the first',
    () {
      final config = buildXrayConfig(_state(selectedNode: 'gone'));

      expect(_finalRule(config)['outboundTag'], 'vm-ws');
    },
  );

  test('without nodes the proxy rules go direct', () {
    final config = buildXrayConfig(_state(outbounds: const []));

    expect(_finalRule(config), {
      'network': 'tcp,udp',
      'outboundTag': directOutboundTag,
    });
    _expectFixture('config_no_nodes', config);
  });

  test('allow lan, credentials and the tun inbound reach the config', () {
    final config = buildXrayConfig(
      _state(
        config: const CoreConfig(
          allowLan: true,
          ipv6: true,
          tun: Tun(enable: true),
        ),
        authentication: const ['user:pa:ss'],
        tunInbound: true,
      ),
    );

    final inbounds = (config['inbounds'] as List).cast<Map<String, dynamic>>();
    expect(inbounds.map((inbound) => inbound['tag']), [
      mixedInboundTag,
      tunInboundTag,
    ]);
    expect(inbounds.first['listen'], '0.0.0.0');
    expect(inbounds.first['settings'], {
      'udp': true,
      'auth': 'password',
      'accounts': [
        {'user': 'user', 'pass': 'pa:ss'},
      ],
    });
    expect((inbounds.last['settings'] as Map)['autoSystemRoutingTable'], [
      '0.0.0.0/0',
      '::/0',
    ]);
    _expectFixture('config_tun_auth', config);
  });

  test(
    'the tun inbound is left to the Core where the host owns the device',
    () {
      final config = buildXrayConfig(
        _state(config: const CoreConfig(tun: Tun(enable: true))),
      );

      expect(config['inbounds'], hasLength(1));
    },
  );

  test('safe mode never asks for a tun device', () {
    final config = buildXrayConfig(
      _state(
        config: const CoreConfig(tun: Tun(enable: true)),
        tunInbound: true,
        safeMode: true,
      ),
    );

    expect(config['inbounds'], hasLength(1));
  });

  test('the log level maps onto the engine and silent turns logging off', () {
    String level(LogLevel logLevel) =>
        (buildXrayConfig(_state(config: CoreConfig(logLevel: logLevel)))['log']
                as Map)['loglevel']
            as String;

    expect(level(LogLevel.debug), 'debug');
    expect(level(LogLevel.error), 'error');
    expect(level(LogLevel.silent), 'none');
  });

  test('every server form the DNS page takes reaches the engine', () {
    final config = buildXrayConfig(
      _state(
        config: const CoreConfig(
          proxyDns: [
            'https://dns.google/dns-query',
            'h2c://dns.example.com/dns-query',
            'tcp://8.8.8.8:53',
            '9.9.9.9',
            '[2606:4700:4700::1111]:53',
          ],
          directDns: [
            '223.5.5.5:53',
            'https+local://doh.pub/dns-query',
            'tcp+local://119.29.29.29',
            'quic+local://dns.alidns.com',
            'localhost',
          ],
        ),
      ),
    );
    final servers = (config['dns'] as Map)['servers'] as List;

    expect(servers, contains('tcp://8.8.8.8:53'));
    expect(
      servers,
      contains(equals({'address': '2606:4700:4700::1111', 'port': 53})),
    );
    expect(
      servers,
      contains(
        equals({
          'address': '223.5.5.5',
          'port': 53,
          'domains': ['geosite:cn'],
          'skipFallback': true,
        }),
      ),
    );
    _expectFixture('config_dns', config);
  });

  test('dns sends Chinese domains to the direct servers first', () {
    final servers =
        ((buildXrayConfig(_state())['dns'] as Map)['servers'] as List);

    expect(
      servers.whereType<Map>().where((server) => server['tag'] == null).first,
      containsPair('domains', ['geosite:cn']),
    );
    expect(servers, contains('1.1.1.1'));
    expect(servers.last, 'localhost');
  });

  test('the nodes\' own domains are looked up directly', () {
    final config = buildXrayConfig(_state());
    final servers = ((config['dns'] as Map)['servers'] as List);
    final first = servers.first as Map;

    expect(first['address'], defaultDirectDnsServers.first);
    expect(first['domains'], contains('full:vl.example.com'));
    expect(first['domains'], isNot(contains('full:1.2.3.4')));
    expect(_rules(config).first, {
      'inboundTag': [first['tag']],
      'outboundTag': directOutboundTag,
    });
  });

  test('nodes given by IP add no lookup of their own', () {
    final servers =
        ((buildXrayConfig(
                  _state(
                    outbounds: parseSubscription(
                      'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ@1.2.3.4:8388#ss',
                    ),
                  ),
                )['dns']
                as Map)['servers']
            as List);

    expect((servers.first as Map)['domains'], ['geosite:cn']);
  });

  test('nodes are resolved by the Core unless another node dials them', () {
    final direct = parseSubscription(
      'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ@proxy.example.com:8388#ss',
    ).first;
    final chained = buildNodeOutbound(NodeKind.vless, {
      ...nodeDefaults(NodeKind.vless),
      'address': 'vl.example.com',
      'port': '443',
      'uuid': _uuid,
      'dialerProxy': 'ss',
    })!;
    Map sockopt(Map node) => (node['streamSettings'] as Map)['sockopt'] as Map;
    List nodes(CoreConfig config) =>
        buildXrayConfig(
              _state(config: config, outbounds: [direct, chained]),
            )['outbounds']
            as List;

    expect(
      sockopt(nodes(const CoreConfig()).first)['domainStrategy'],
      'UseIPv4',
    );
    expect(
      sockopt(nodes(const CoreConfig(ipv6: true)).first)['domainStrategy'],
      'UseIP',
    );
    expect(sockopt(nodes(const CoreConfig())[1]), {'dialerProxy': 'ss'});
  });

  test('encodeXrayConfig hashes what it encodes', () {
    final first = encodeXrayConfig(_state());
    final second = encodeXrayConfig(_state());
    final other = encodeXrayConfig(
      _state(config: const CoreConfig(mode: Mode.global)),
    );

    expect(first.md5, second.md5);
    expect(first.md5, isNot(other.md5));
    expect(json.decode(first.json), isA<Map<String, dynamic>>());
  });

  group('a rule set in rule mode', () {
    List<Map<String, dynamic>> routingRules(MakeRealProfileState state) {
      final routing = buildXrayConfig(state)['routing'] as Map;
      return (routing['rules'] as List).cast<Map<String, dynamic>>();
    }

    test('replaces the built-in rules and ends with the proxy', () {
      final rules = routingRules(
        _state(
          selectedNode: 'trojan-ws',
          rules: const [
            {
              'domain': ['domain:example.com'],
              'outboundTag': 'direct',
            },
            {
              'ip': ['1.1.1.1/32'],
              'outboundTag': 'block',
            },
            {
              'domain': ['keyword:google'],
              'outboundTag': 'proxy',
              'balancerTag': 'b',
            },
          ],
        ),
      );

      expect(rules.any((rule) => '$rule'.contains('geosite:cn')), isFalse);
      expect(rules[3], {
        'domain': ['domain:example.com'],
        'outboundTag': directOutboundTag,
      });
      expect(rules[4]['outboundTag'], blockOutboundTag);
      expect(rules[5], {
        'domain': ['keyword:google'],
        'outboundTag': 'trojan-ws',
      });
      expect(rules.last, {'network': 'tcp,udp', 'outboundTag': 'trojan-ws'});
    });

    test('is left out in global and direct mode', () {
      for (final mode in [Mode.global, Mode.direct]) {
        final rules = routingRules(
          _state(
            config: CoreConfig(mode: mode),
            rules: const [
              {
                'domain': ['domain:example.com'],
                'outboundTag': 'direct',
              },
            ],
          ),
        );

        expect(
          rules.any((rule) => '$rule'.contains('example.com')),
          isFalse,
          reason: '$mode',
        );
      }
    });

    test('without one the built-in rules apply', () {
      final rules = routingRules(_state());

      expect(rules.any((rule) => '$rule'.contains('geosite:cn')), isTrue);
    });
  });
}
