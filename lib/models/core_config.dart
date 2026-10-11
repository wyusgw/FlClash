import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/core_config.freezed.dart';
part 'generated/core_config.g.dart';

const defaultCoreConfig = CoreConfig();

const defaultTun = Tun();

const defaultMixedPort = 7890;

const defaultProxyDnsServers = ['1.1.1.1', '8.8.8.8'];
const defaultDirectDnsServers = ['223.5.5.5', '119.29.29.29'];

const defaultBypassPrivateRouteAddress = [
  '1.0.0.0/8',
  '2.0.0.0/7',
  '4.0.0.0/6',
  '8.0.0.0/7',
  '11.0.0.0/8',
  '12.0.0.0/6',
  '16.0.0.0/4',
  '32.0.0.0/3',
  '64.0.0.0/3',
  '96.0.0.0/4',
  '112.0.0.0/5',
  '120.0.0.0/6',
  '124.0.0.0/7',
  '126.0.0.0/8',
  '128.0.0.0/3',
  '160.0.0.0/5',
  '168.0.0.0/8',
  '169.0.0.0/9',
  '169.128.0.0/10',
  '169.192.0.0/11',
  '169.224.0.0/12',
  '169.240.0.0/13',
  '169.248.0.0/14',
  '169.252.0.0/15',
  '169.255.0.0/16',
  '170.0.0.0/7',
  '172.0.0.0/12',
  '172.32.0.0/11',
  '172.64.0.0/10',
  '172.128.0.0/9',
  '173.0.0.0/8',
  '174.0.0.0/7',
  '176.0.0.0/4',
  '192.0.0.0/9',
  '192.128.0.0/11',
  '192.160.0.0/13',
  '192.169.0.0/16',
  '192.170.0.0/15',
  '192.172.0.0/14',
  '192.176.0.0/12',
  '192.192.0.0/10',
  '193.0.0.0/8',
  '194.0.0.0/7',
  '196.0.0.0/6',
  '200.0.0.0/5',
  '208.0.0.0/4',
  '240.0.0.0/5',
  '248.0.0.0/6',
  '252.0.0.0/7',
  '254.0.0.0/8',
  '255.0.0.0/9',
  '255.128.0.0/10',
  '255.192.0.0/11',
  '255.224.0.0/12',
  '255.240.0.0/13',
  '255.248.0.0/14',
  '255.252.0.0/15',
  '255.254.0.0/16',
  '255.255.0.0/17',
  '255.255.128.0/18',
  '255.255.192.0/19',
  '255.255.224.0/20',
  '255.255.240.0/21',
  '255.255.248.0/22',
  '255.255.252.0/23',
  '255.255.254.0/24',
  '255.255.255.0/25',
  '255.255.255.128/26',
  '255.255.255.192/27',
  '255.255.255.224/28',
  '255.255.255.240/29',
  '255.255.255.248/30',
  '255.255.255.252/31',
  '255.255.255.254/32',
  '::/1',
  '8000::/2',
  'c000::/3',
  'e000::/4',
  'f000::/5',
  'f800::/6',
  'fe00::/9',
  'fec0::/10',
];

@freezed
abstract class Proxy with _$Proxy {
  const factory Proxy({
    required String name,
    required String type,
    String? now,
    String? network,
    String? address,
  }) = _Proxy;

  factory Proxy.fromJson(Map<String, Object?> json) => _$ProxyFromJson(json);
}

extension ProxyExt on Proxy {
  List<String> get searchFields => [name, type];
}

@freezed
abstract class Tun with _$Tun {
  const factory Tun({
    @Default(false) bool enable,
    @Default(appName) String device,
    @JsonKey(name: 'auto-route') @Default(false) bool autoRoute,
    @Default(TunStack.mips) TunStack stack,
    @JsonKey(name: 'dns-hijack') @Default(['any:53']) List<String> dnsHijack,
    @JsonKey(name: 'route-address') @Default([]) List<String> routeAddress,
  }) = _Tun;

  factory Tun.fromJson(Map<String, Object?> json) => _$TunFromJson(json);

  factory Tun.safeFormJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultTun;
    }
    return decodeOrRestoreDefault(
      'tun config',
      () => Tun.fromJson(json),
      () => defaultTun,
    );
  }
}

extension TunExt on Tun {
  List<String> resolveRouteAddress(RouteMode routeMode) =>
      routeMode == RouteMode.bypassPrivate
      ? defaultBypassPrivateRouteAddress
      : routeAddress;

  Tun getRealTun(RouteMode routeMode) {
    final mRouteAddress = resolveRouteAddress(routeMode);
    return switch (system.isDesktop) {
      true => copyWith(autoRoute: true, routeAddress: []),
      false => copyWith(
        autoRoute: mRouteAddress.isEmpty ? true : false,
        routeAddress: mRouteAddress,
      ),
    };
  }
}

List<String> _servers(Object? value, List<String> fallback) {
  if (value is! List) {
    return fallback;
  }
  final servers = value
      .whereType<String>()
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
  return servers.isEmpty ? fallback : servers;
}

List<String> _proxyDnsFromJson(Object? value) =>
    _servers(value, defaultProxyDnsServers);

List<String> _directDnsFromJson(Object? value) =>
    _servers(value, defaultDirectDnsServers);

/// What the user can set about the proxy engine. The Core is handed a freshly
/// generated config for every change, so each field here ends up in that file.
@freezed
abstract class CoreConfig with _$CoreConfig {
  const factory CoreConfig({
    @Default(defaultMixedPort) @JsonKey(name: 'mixed-port') int mixedPort,
    @Default(Mode.rule) Mode mode,
    @Default(false) @JsonKey(name: 'allow-lan') bool allowLan,
    @Default(LogLevel.error) @JsonKey(name: 'log-level') LogLevel logLevel,
    @Default(false) bool ipv6,
    @Default(defaultTun) @JsonKey(fromJson: Tun.safeFormJson) Tun tun,
    @Default(defaultProxyDnsServers)
    @JsonKey(name: 'proxy-dns', fromJson: _proxyDnsFromJson)
    List<String> proxyDns,
    @Default(defaultDirectDnsServers)
    @JsonKey(name: 'direct-dns', fromJson: _directDnsFromJson)
    List<String> directDns,
  }) = _CoreConfig;

  factory CoreConfig.fromJson(Map<String, Object?> json) =>
      _$CoreConfigFromJson(json);

  factory CoreConfig.safeFormJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultCoreConfig;
    }
    return decodeOrRestoreDefault(
      'core config',
      () => CoreConfig.fromJson(json),
      () => defaultCoreConfig,
    );
  }
}
