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
].join('\n');

MakeRealProfileState _state({
  CoreConfig config = const CoreConfig(),
  List<Map<String, dynamic>>? outbounds,
  String? selectedNode,
  List<String> authentication = const [],
  bool tunInbound = false,
  bool safeMode = false,
}) {
  return MakeRealProfileState(
    outbounds: outbounds ?? parseSubscription(_subscription),
    coreConfig: config,
    routeMode: RouteMode.config,
    selectedNode: selectedNode,
    authentication: authentication,
    tunInbound: tunInbound,
    safeMode: safeMode,
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
        'tls': 'true',
        'sni': 'sni.example.com',
        'allowInsecure': 'true',
        'remark': 'https',
      })!,
      buildNodeOutbound(NodeKind.hysteria, {
        ...nodeDefaults(NodeKind.hysteria),
        'address': 'hy1.example.com',
        'port': '8443',
        'password': 'auth',
        'obfsPassword': 'mask',
        'remark': 'hysteria1',
      })!,
    ];

    expect(
      outbounds.map((node) => node['protocol']).toSet(),
      supportedOutboundProtocols,
    );
    _expectFixture('outbounds', {'outbounds': outbounds});
  });

  group('rule mode', () {
    final config = buildXrayConfig(_state());

    test(
      'routes private and Chinese traffic direct and the rest to a node',
      () {
        final rules = _rules(config);

        expect(rules.first, {
          'inboundTag': [tunInboundTag],
          'port': '53',
          'outboundTag': dnsOutboundTag,
        });
        expect(rules.map((rule) => rule['outboundTag']).whereType<String>(), [
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

      expect(tags.skip(7), [
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

  test('dns sends Chinese domains to the direct servers first', () {
    final servers =
        ((buildXrayConfig(_state())['dns'] as Map)['servers'] as List);

    expect((servers.first as Map)['domains'], ['geosite:cn']);
    expect(servers, contains('1.1.1.1'));
    expect(servers.last, 'localhost');
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
}
