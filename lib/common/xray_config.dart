import 'dart:convert';

import 'package:fl_clash/common/string.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

/// Tags of the outbounds the app adds beside the user's nodes. The leading
/// character is reserved: node tags never start with it, so no selector that
/// names a node by prefix can pick one of these up.
const directOutboundTag = '@direct';
const blockOutboundTag = '@block';
const dnsOutboundTag = '@dns';

/// The balancer every node belongs to, and the group name the UI shows.
const proxyGroupName = 'PROXY';

const mixedInboundTag = 'mixed-in';
const tunInboundTag = 'tun-in';

const _tunGateway = '172.19.0.1/30';
const _probeInterval = '5m';

String _logLevelName(LogLevel level) => switch (level) {
  LogLevel.silent => 'none',
  _ => level.name,
};

String _credentialUser(String credential) =>
    credential.substring(0, credential.indexOf(':'));

String _credentialPass(String credential) =>
    credential.substring(credential.indexOf(':') + 1);

List<Map<String, dynamic>> _inbounds(MakeRealProfileState state) {
  final config = state.coreConfig;
  final sniffing = {
    'enabled': true,
    'destOverride': ['http', 'tls', 'quic'],
    'routeOnly': true,
  };
  return [
    {
      'tag': mixedInboundTag,
      'protocol': 'mixed',
      'listen': config.allowLan ? '0.0.0.0' : '127.0.0.1',
      'port': config.mixedPort,
      'settings': {
        'udp': true,
        'auth': state.authentication.isEmpty ? 'noauth' : 'password',
        if (state.authentication.isNotEmpty)
          'accounts': [
            for (final credential in state.authentication)
              {
                'user': _credentialUser(credential),
                'pass': _credentialPass(credential),
              },
          ],
      },
      'sniffing': sniffing,
    },
    if (state.tunInbound && config.tun.enable && !state.safeMode)
      {
        'tag': tunInboundTag,
        'protocol': 'tun',
        'settings': {
          'mtu': 9000,
          'gateway': [_tunGateway],
          'autoSystemRoutingTable': ['0.0.0.0/0', if (config.ipv6) '::/0'],
          'autoOutboundsInterface': 'auto',
        },
        'sniffing': sniffing,
      },
  ];
}

Map<String, dynamic> _routing(MakeRealProfileState state, bool hasNodes) {
  final config = state.coreConfig;
  final proxyTarget = hasNodes
      ? {'balancerTag': proxyGroupName}
      : {'outboundTag': directOutboundTag};
  final rules = <Map<String, dynamic>>[
    {
      'inboundTag': [tunInboundTag],
      'port': '53',
      'outboundTag': dnsOutboundTag,
    },
    {
      'ip': ['geoip:private'],
      'outboundTag': directOutboundTag,
    },
  ];
  switch (config.mode) {
    case Mode.direct:
      rules.add({'network': 'tcp,udp', 'outboundTag': directOutboundTag});
    case Mode.global:
      rules.add({'network': 'tcp,udp', ...proxyTarget});
    case Mode.rule:
      rules.addAll([
        {
          'domain': ['geosite:cn'],
          'outboundTag': directOutboundTag,
        },
        {
          'ip': ['geoip:cn'],
          'outboundTag': directOutboundTag,
        },
        {'network': 'tcp,udp', ...proxyTarget},
      ]);
  }
  return {
    'domainStrategy': 'IpIfNonMatch',
    'rules': rules,
    if (hasNodes)
      'balancers': [
        {
          'tag': proxyGroupName,
          'selector': [for (final node in state.outbounds) node['tag']],
          'strategy': {'type': config.autoSelect ? 'leastPing' : 'random'},
          // A fallback is resolved through the observatory, which only exists
          // when the nodes are probed.
          if (config.autoSelect) 'fallbackTag': directOutboundTag,
        },
      ],
  };
}

Map<String, dynamic> _dns(CoreConfig config) {
  final direct = [
    for (final server in config.directDns)
      {
        'address': server,
        'domains': ['geosite:cn'],
        'skipFallback': true,
      },
  ];
  return {
    'servers': config.mode == Mode.direct
        ? [...config.directDns, 'localhost']
        : [...direct, ...config.proxyDns, 'localhost'],
    'queryStrategy': config.ipv6 ? 'UseIP' : 'UseIPv4',
  };
}

/// The Xray config the Core is asked to run: the user's nodes, the app's own
/// outbounds, and inbounds, routing and DNS derived from [state].
Map<String, dynamic> buildXrayConfig(MakeRealProfileState state) {
  final hasNodes = state.outbounds.isNotEmpty;
  final config = state.coreConfig;
  return {
    'log': {'loglevel': _logLevelName(config.logLevel), 'access': 'none'},
    'inbounds': _inbounds(state),
    'outbounds': [
      ...state.outbounds,
      {'tag': directOutboundTag, 'protocol': 'freedom'},
      {'tag': blockOutboundTag, 'protocol': 'blackhole'},
      {'tag': dnsOutboundTag, 'protocol': 'dns'},
    ],
    'routing': _routing(state, hasNodes),
    'dns': _dns(config),
    if (hasNodes && config.autoSelect)
      'observatory': {
        'subjectSelector': [for (final node in state.outbounds) node['tag']],
        'probeURL': state.testUrl,
        'probeInterval': _probeInterval,
        'enableConcurrency': true,
      },
  };
}

({String json, String md5}) encodeXrayConfig(MakeRealProfileState state) {
  final encoded = json.encode(buildXrayConfig(state));
  return (json: encoded, md5: encoded.toMd5());
}
