// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../core_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Proxy _$ProxyFromJson(Map<String, dynamic> json) => _Proxy(
  name: json['name'] as String,
  type: json['type'] as String,
  now: json['now'] as String?,
  network: json['network'] as String?,
  address: json['address'] as String?,
  region: json['region'] as String?,
);

Map<String, dynamic> _$ProxyToJson(_Proxy instance) => <String, dynamic>{
  'name': instance.name,
  'type': instance.type,
  'now': instance.now,
  'network': instance.network,
  'address': instance.address,
  'region': instance.region,
};

_Tun _$TunFromJson(Map<String, dynamic> json) => _Tun(
  enable: json['enable'] as bool? ?? false,
  device: json['device'] as String? ?? appName,
  autoRoute: json['auto-route'] as bool? ?? false,
  stack: $enumDecodeNullable(_$TunStackEnumMap, json['stack']) ?? TunStack.mips,
  dnsHijack:
      (json['dns-hijack'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['any:53'],
  routeAddress:
      (json['route-address'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$TunToJson(_Tun instance) => <String, dynamic>{
  'enable': instance.enable,
  'device': instance.device,
  'auto-route': instance.autoRoute,
  'stack': _$TunStackEnumMap[instance.stack]!,
  'dns-hijack': instance.dnsHijack,
  'route-address': instance.routeAddress,
};

const _$TunStackEnumMap = {
  TunStack.gvisor: 'gvisor',
  TunStack.system: 'system',
  TunStack.mixed: 'mixed',
  TunStack.mips: 'mips',
};

_CoreConfig _$CoreConfigFromJson(Map<String, dynamic> json) => _CoreConfig(
  mixedPort: (json['mixed-port'] as num?)?.toInt() ?? defaultMixedPort,
  mode: $enumDecodeNullable(_$ModeEnumMap, json['mode']) ?? Mode.rule,
  allowLan: json['allow-lan'] as bool? ?? false,
  logLevel:
      $enumDecodeNullable(_$LogLevelEnumMap, json['log-level']) ??
      LogLevel.error,
  ipv6: json['ipv6'] as bool? ?? false,
  tun: json['tun'] == null
      ? defaultTun
      : Tun.safeFormJson(json['tun'] as Map<String, Object?>?),
  proxyDns: json['proxy-dns'] == null
      ? defaultProxyDnsServers
      : _proxyDnsFromJson(json['proxy-dns']),
  directDns: json['direct-dns'] == null
      ? defaultDirectDnsServers
      : _directDnsFromJson(json['direct-dns']),
);

Map<String, dynamic> _$CoreConfigToJson(_CoreConfig instance) =>
    <String, dynamic>{
      'mixed-port': instance.mixedPort,
      'mode': _$ModeEnumMap[instance.mode]!,
      'allow-lan': instance.allowLan,
      'log-level': _$LogLevelEnumMap[instance.logLevel]!,
      'ipv6': instance.ipv6,
      'tun': instance.tun,
      'proxy-dns': instance.proxyDns,
      'direct-dns': instance.directDns,
    };

const _$ModeEnumMap = {
  Mode.rule: 'rule',
  Mode.global: 'global',
  Mode.direct: 'direct',
};

const _$LogLevelEnumMap = {
  LogLevel.debug: 'debug',
  LogLevel.info: 'info',
  LogLevel.warning: 'warning',
  LogLevel.error: 'error',
  LogLevel.silent: 'silent',
};
