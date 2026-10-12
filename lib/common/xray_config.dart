import 'dart:convert';

import 'package:fl_clash/common/string.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

import 'xray_rules.dart';

/// Tags of the outbounds the app adds beside the user's nodes. The leading
/// character is reserved: node tags never start with it, so no selector that
/// names a node by prefix can pick one of these up.
const directOutboundTag = '@direct';
const blockOutboundTag = '@block';
const dnsOutboundTag = '@dns';

/// The key the chosen node is stored under: the node list is the only list the
/// app shows, and Xray has no group to select from, so the choice is a rule.
const nodeGroupName = 'nodes';

const mixedInboundTag = 'mixed-in';
const tunInboundTag = 'tun-in';

const _tunGateway = '172.19.0.1/30';

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

/// The node the proxy rules send traffic to: the chosen one while it is still
/// in the subscription, otherwise the first.
String? _proxiedNode(MakeRealProfileState state) {
  final tags = [for (final node in state.outbounds) '${node['tag']}'];
  final chosen = state.selectedNode;
  if (chosen != null && tags.contains(chosen)) return chosen;
  return tags.firstOrNull;
}

/// A rule from the user's rule set, pointed at the app's own outbounds.
Map<String, dynamic> _userRule(
  Map<String, dynamic> rule,
  Map<String, dynamic> proxyTarget,
) {
  final target = switch (rulePolicyOf(rule)) {
    RulePolicy.direct => {'outboundTag': directOutboundTag},
    RulePolicy.block => {'outboundTag': blockOutboundTag},
    RulePolicy.proxy => proxyTarget,
  };
  return {...rule, ...target}..remove('balancerTag');
}

Map<String, dynamic> _routing(MakeRealProfileState state) {
  final config = state.coreConfig;
  final node = _proxiedNode(state);
  final proxyTarget = {'outboundTag': node ?? directOutboundTag};
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
      final userRules = state.rules.isEmpty ? builtInRules : state.rules;
      rules.addAll([
        for (final rule in userRules) _userRule(rule, proxyTarget),
        {'network': 'tcp,udp', ...proxyTarget},
      ]);
  }
  return {'domainStrategy': 'IpIfNonMatch', 'rules': rules};
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
  final config = state.coreConfig;
  return {
    'log': {'loglevel': _logLevelName(config.logLevel), 'access': 'none'},
    'inbounds': _inbounds(state),
    'outbounds': [
      for (final node in state.outbounds) {...node}..remove('region'),
      {'tag': directOutboundTag, 'protocol': 'freedom'},
      {'tag': blockOutboundTag, 'protocol': 'blackhole'},
      {'tag': dnsOutboundTag, 'protocol': 'dns'},
    ],
    'routing': _routing(state),
    'dns': _dns(config),
  };
}

({String json, String md5}) encodeXrayConfig(MakeRealProfileState state) {
  final encoded = json.encode(buildXrayConfig(state));
  return (json: encoded, md5: encoded.toMd5());
}
