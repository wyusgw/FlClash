// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../core_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Proxy {

 String get name; String get type; String? get now; String? get network; String? get address;/// The country the user placed the node in; null leaves it to its name.
 String? get region;
/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyCopyWith<Proxy> get copyWith => _$ProxyCopyWithImpl<Proxy>(this as Proxy, _$identity);

  /// Serializes this Proxy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Proxy;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Proxy&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.now, _this.now) || other.now == _this.now)&&(identical(other.network, _this.network) || other.network == _this.network)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.region, _this.region) || other.region == _this.region));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Proxy;
  return Object.hash(runtimeType,_this.name,_this.type,_this.now,_this.network,_this.address,_this.region);
}

@override
String toString() {
  final _this = this as Proxy;
  return 'Proxy(name: ${_this.name}, type: ${_this.type}, now: ${_this.now}, network: ${_this.network}, address: ${_this.address}, region: ${_this.region})';
}


}

/// @nodoc
abstract mixin class $ProxyCopyWith<$Res>  {
  factory $ProxyCopyWith(Proxy value, $Res Function(Proxy) _then) = _$ProxyCopyWithImpl;
@useResult
$Res call({
 String name, String type, String? now, String? network, String? address, String? region
});




}
/// @nodoc
class _$ProxyCopyWithImpl<$Res>
    implements $ProxyCopyWith<$Res> {
  _$ProxyCopyWithImpl(this._self, this._then);

  final Proxy _self;
  final $Res Function(Proxy) _then;

/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? now = freezed,Object? network = freezed,Object? address = freezed,Object? region = freezed,}) {
  return _then(Proxy(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Proxy].
extension ProxyPatterns on Proxy {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Proxy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Proxy() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Proxy value)  $default,){
final _that = this;
switch (_that) {
case _Proxy():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Proxy value)?  $default,){
final _that = this;
switch (_that) {
case _Proxy() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String type,  String? now,  String? network,  String? address,  String? region)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Proxy() when $default != null:
return $default(_that.name,_that.type,_that.now,_that.network,_that.address,_that.region);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String type,  String? now,  String? network,  String? address,  String? region)  $default,) {final _that = this;
switch (_that) {
case _Proxy():
return $default(_that.name,_that.type,_that.now,_that.network,_that.address,_that.region);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String type,  String? now,  String? network,  String? address,  String? region)?  $default,) {final _that = this;
switch (_that) {
case _Proxy() when $default != null:
return $default(_that.name,_that.type,_that.now,_that.network,_that.address,_that.region);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Proxy implements Proxy {
  const _Proxy({required this.name, required this.type, this.now, this.network, this.address, this.region});
  factory _Proxy.fromJson(Map<String, dynamic> json) => _$ProxyFromJson(json);

@override final  String name;
@override final  String type;
@override final  String? now;
@override final  String? network;
@override final  String? address;
/// The country the user placed the node in; null leaves it to its name.
@override final  String? region;

/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxyCopyWith<_Proxy> get copyWith => __$ProxyCopyWithImpl<_Proxy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProxyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Proxy&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.now, now) || other.now == now)&&(identical(other.network, network) || other.network == network)&&(identical(other.address, address) || other.address == address)&&(identical(other.region, region) || other.region == region));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,type,now,network,address,region);
}

@override
String toString() {
    return 'Proxy(name: $name, type: $type, now: $now, network: $network, address: $address, region: $region)';
}


}

/// @nodoc
abstract mixin class _$ProxyCopyWith<$Res> implements $ProxyCopyWith<$Res> {
  factory _$ProxyCopyWith(_Proxy value, $Res Function(_Proxy) _then) = __$ProxyCopyWithImpl;
@override @useResult
$Res call({
 String name, String type, String? now, String? network, String? address, String? region
});




}
/// @nodoc
class __$ProxyCopyWithImpl<$Res>
    implements _$ProxyCopyWith<$Res> {
  __$ProxyCopyWithImpl(this._self, this._then);

  final _Proxy _self;
  final $Res Function(_Proxy) _then;

/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? now = freezed,Object? network = freezed,Object? address = freezed,Object? region = freezed,}) {
  return _then(_Proxy(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String?,network: freezed == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Tun {

 bool get enable; String get device;@JsonKey(name: 'auto-route') bool get autoRoute; TunStack get stack;@JsonKey(name: 'dns-hijack') List<String> get dnsHijack;@JsonKey(name: 'route-address') List<String> get routeAddress;
/// Create a copy of Tun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TunCopyWith<Tun> get copyWith => _$TunCopyWithImpl<Tun>(this as Tun, _$identity);

  /// Serializes this Tun to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Tun;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tun&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.device, _this.device) || other.device == _this.device)&&(identical(other.autoRoute, _this.autoRoute) || other.autoRoute == _this.autoRoute)&&(identical(other.stack, _this.stack) || other.stack == _this.stack)&&const DeepCollectionEquality().equals(other.dnsHijack, _this.dnsHijack)&&const DeepCollectionEquality().equals(other.routeAddress, _this.routeAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Tun;
  return Object.hash(runtimeType,_this.enable,_this.device,_this.autoRoute,_this.stack,const DeepCollectionEquality().hash(_this.dnsHijack),const DeepCollectionEquality().hash(_this.routeAddress));
}

@override
String toString() {
  final _this = this as Tun;
  return 'Tun(enable: ${_this.enable}, device: ${_this.device}, autoRoute: ${_this.autoRoute}, stack: ${_this.stack}, dnsHijack: ${_this.dnsHijack}, routeAddress: ${_this.routeAddress})';
}


}

/// @nodoc
abstract mixin class $TunCopyWith<$Res>  {
  factory $TunCopyWith(Tun value, $Res Function(Tun) _then) = _$TunCopyWithImpl;
@useResult
$Res call({
 bool enable, String device,@JsonKey(name: 'auto-route') bool autoRoute, TunStack stack,@JsonKey(name: 'dns-hijack') List<String> dnsHijack,@JsonKey(name: 'route-address') List<String> routeAddress
});




}
/// @nodoc
class _$TunCopyWithImpl<$Res>
    implements $TunCopyWith<$Res> {
  _$TunCopyWithImpl(this._self, this._then);

  final Tun _self;
  final $Res Function(Tun) _then;

/// Create a copy of Tun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? device = null,Object? autoRoute = null,Object? stack = null,Object? dnsHijack = null,Object? routeAddress = null,}) {
  return _then(Tun(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as String,autoRoute: null == autoRoute ? _self.autoRoute : autoRoute // ignore: cast_nullable_to_non_nullable
as bool,stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as TunStack,dnsHijack: null == dnsHijack ? _self.dnsHijack : dnsHijack // ignore: cast_nullable_to_non_nullable
as List<String>,routeAddress: null == routeAddress ? _self.routeAddress : routeAddress // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Tun].
extension TunPatterns on Tun {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tun() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tun value)  $default,){
final _that = this;
switch (_that) {
case _Tun():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tun value)?  $default,){
final _that = this;
switch (_that) {
case _Tun() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  String device, @JsonKey(name: 'auto-route')  bool autoRoute,  TunStack stack, @JsonKey(name: 'dns-hijack')  List<String> dnsHijack, @JsonKey(name: 'route-address')  List<String> routeAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tun() when $default != null:
return $default(_that.enable,_that.device,_that.autoRoute,_that.stack,_that.dnsHijack,_that.routeAddress);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  String device, @JsonKey(name: 'auto-route')  bool autoRoute,  TunStack stack, @JsonKey(name: 'dns-hijack')  List<String> dnsHijack, @JsonKey(name: 'route-address')  List<String> routeAddress)  $default,) {final _that = this;
switch (_that) {
case _Tun():
return $default(_that.enable,_that.device,_that.autoRoute,_that.stack,_that.dnsHijack,_that.routeAddress);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  String device, @JsonKey(name: 'auto-route')  bool autoRoute,  TunStack stack, @JsonKey(name: 'dns-hijack')  List<String> dnsHijack, @JsonKey(name: 'route-address')  List<String> routeAddress)?  $default,) {final _that = this;
switch (_that) {
case _Tun() when $default != null:
return $default(_that.enable,_that.device,_that.autoRoute,_that.stack,_that.dnsHijack,_that.routeAddress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tun implements Tun {
  const _Tun({this.enable = false, this.device = appName, @JsonKey(name: 'auto-route') this.autoRoute = false, this.stack = TunStack.mips, @JsonKey(name: 'dns-hijack')  List<String> dnsHijack = const ['any:53'], @JsonKey(name: 'route-address')  List<String> routeAddress = const []}): _dnsHijack = dnsHijack,_routeAddress = routeAddress;
  factory _Tun.fromJson(Map<String, dynamic> json) => _$TunFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  String device;
@override@JsonKey(name: 'auto-route') final  bool autoRoute;
@override@JsonKey() final  TunStack stack;
 final  List<String> _dnsHijack;
@override@JsonKey(name: 'dns-hijack') List<String> get dnsHijack {
  if (_dnsHijack is EqualUnmodifiableListView) return _dnsHijack;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dnsHijack);
}

 final  List<String> _routeAddress;
@override@JsonKey(name: 'route-address') List<String> get routeAddress {
  if (_routeAddress is EqualUnmodifiableListView) return _routeAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routeAddress);
}


/// Create a copy of Tun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TunCopyWith<_Tun> get copyWith => __$TunCopyWithImpl<_Tun>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TunToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tun&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.device, device) || other.device == device)&&(identical(other.autoRoute, autoRoute) || other.autoRoute == autoRoute)&&(identical(other.stack, stack) || other.stack == stack)&&const DeepCollectionEquality().equals(other.dnsHijack, _dnsHijack)&&const DeepCollectionEquality().equals(other.routeAddress, _routeAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,device,autoRoute,stack,const DeepCollectionEquality().hash(_dnsHijack),const DeepCollectionEquality().hash(_routeAddress));
}

@override
String toString() {
    return 'Tun(enable: $enable, device: $device, autoRoute: $autoRoute, stack: $stack, dnsHijack: $dnsHijack, routeAddress: $routeAddress)';
}


}

/// @nodoc
abstract mixin class _$TunCopyWith<$Res> implements $TunCopyWith<$Res> {
  factory _$TunCopyWith(_Tun value, $Res Function(_Tun) _then) = __$TunCopyWithImpl;
@override @useResult
$Res call({
 bool enable, String device,@JsonKey(name: 'auto-route') bool autoRoute, TunStack stack,@JsonKey(name: 'dns-hijack') List<String> dnsHijack,@JsonKey(name: 'route-address') List<String> routeAddress
});




}
/// @nodoc
class __$TunCopyWithImpl<$Res>
    implements _$TunCopyWith<$Res> {
  __$TunCopyWithImpl(this._self, this._then);

  final _Tun _self;
  final $Res Function(_Tun) _then;

/// Create a copy of Tun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? device = null,Object? autoRoute = null,Object? stack = null,Object? dnsHijack = null,Object? routeAddress = null,}) {
  return _then(_Tun(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as String,autoRoute: null == autoRoute ? _self.autoRoute : autoRoute // ignore: cast_nullable_to_non_nullable
as bool,stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as TunStack,dnsHijack: null == dnsHijack ? _self._dnsHijack : dnsHijack // ignore: cast_nullable_to_non_nullable
as List<String>,routeAddress: null == routeAddress ? _self._routeAddress : routeAddress // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$CoreConfig {

@JsonKey(name: 'mixed-port') int get mixedPort; Mode get mode;@JsonKey(name: 'allow-lan') bool get allowLan;@JsonKey(name: 'log-level') LogLevel get logLevel; bool get ipv6;@JsonKey(fromJson: Tun.safeFormJson) Tun get tun;@JsonKey(name: 'proxy-dns', fromJson: _proxyDnsFromJson) List<String> get proxyDns;@JsonKey(name: 'direct-dns', fromJson: _directDnsFromJson) List<String> get directDns;@JsonKey(name: 'dns-manual') bool? get dnsManual;
/// Create a copy of CoreConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreConfigCopyWith<CoreConfig> get copyWith => _$CoreConfigCopyWithImpl<CoreConfig>(this as CoreConfig, _$identity);

  /// Serializes this CoreConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CoreConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreConfig&&(identical(other.mixedPort, _this.mixedPort) || other.mixedPort == _this.mixedPort)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.allowLan, _this.allowLan) || other.allowLan == _this.allowLan)&&(identical(other.logLevel, _this.logLevel) || other.logLevel == _this.logLevel)&&(identical(other.ipv6, _this.ipv6) || other.ipv6 == _this.ipv6)&&(identical(other.tun, _this.tun) || other.tun == _this.tun)&&const DeepCollectionEquality().equals(other.proxyDns, _this.proxyDns)&&const DeepCollectionEquality().equals(other.directDns, _this.directDns)&&(identical(other.dnsManual, _this.dnsManual) || other.dnsManual == _this.dnsManual));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CoreConfig;
  return Object.hash(runtimeType,_this.mixedPort,_this.mode,_this.allowLan,_this.logLevel,_this.ipv6,_this.tun,const DeepCollectionEquality().hash(_this.proxyDns),const DeepCollectionEquality().hash(_this.directDns),_this.dnsManual);
}

@override
String toString() {
  final _this = this as CoreConfig;
  return 'CoreConfig(mixedPort: ${_this.mixedPort}, mode: ${_this.mode}, allowLan: ${_this.allowLan}, logLevel: ${_this.logLevel}, ipv6: ${_this.ipv6}, tun: ${_this.tun}, proxyDns: ${_this.proxyDns}, directDns: ${_this.directDns}, dnsManual: ${_this.dnsManual})';
}


}

/// @nodoc
abstract mixin class $CoreConfigCopyWith<$Res>  {
  factory $CoreConfigCopyWith(CoreConfig value, $Res Function(CoreConfig) _then) = _$CoreConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'mixed-port') int mixedPort, Mode mode,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(fromJson: Tun.safeFormJson) Tun tun,@JsonKey(name: 'proxy-dns', fromJson: _proxyDnsFromJson) List<String> proxyDns,@JsonKey(name: 'direct-dns', fromJson: _directDnsFromJson) List<String> directDns,@JsonKey(name: 'dns-manual') bool? dnsManual
});


$TunCopyWith<$Res> get tun;

}
/// @nodoc
class _$CoreConfigCopyWithImpl<$Res>
    implements $CoreConfigCopyWith<$Res> {
  _$CoreConfigCopyWithImpl(this._self, this._then);

  final CoreConfig _self;
  final $Res Function(CoreConfig) _then;

/// Create a copy of CoreConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mixedPort = null,Object? mode = null,Object? allowLan = null,Object? logLevel = null,Object? ipv6 = null,Object? tun = null,Object? proxyDns = null,Object? directDns = null,Object? dnsManual = freezed,}) {
  return _then(CoreConfig(
mixedPort: null == mixedPort ? _self.mixedPort : mixedPort // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,allowLan: null == allowLan ? _self.allowLan : allowLan // ignore: cast_nullable_to_non_nullable
as bool,logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as Tun,proxyDns: null == proxyDns ? _self.proxyDns : proxyDns // ignore: cast_nullable_to_non_nullable
as List<String>,directDns: null == directDns ? _self.directDns : directDns // ignore: cast_nullable_to_non_nullable
as List<String>,dnsManual: freezed == dnsManual ? _self.dnsManual : dnsManual // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}
/// Create a copy of CoreConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunCopyWith<$Res> get tun {
  
  return $TunCopyWith<$Res>(_self.tun, (value) {
    return _then(_self.copyWith(tun: value));
  });
}
}


/// Adds pattern-matching-related methods to [CoreConfig].
extension CoreConfigPatterns on CoreConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreConfig value)  $default,){
final _that = this;
switch (_that) {
case _CoreConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreConfig value)?  $default,){
final _that = this;
switch (_that) {
case _CoreConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'mixed-port')  int mixedPort,  Mode mode, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(fromJson: Tun.safeFormJson)  Tun tun, @JsonKey(name: 'proxy-dns', fromJson: _proxyDnsFromJson)  List<String> proxyDns, @JsonKey(name: 'direct-dns', fromJson: _directDnsFromJson)  List<String> directDns, @JsonKey(name: 'dns-manual')  bool? dnsManual)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreConfig() when $default != null:
return $default(_that.mixedPort,_that.mode,_that.allowLan,_that.logLevel,_that.ipv6,_that.tun,_that.proxyDns,_that.directDns,_that.dnsManual);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'mixed-port')  int mixedPort,  Mode mode, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(fromJson: Tun.safeFormJson)  Tun tun, @JsonKey(name: 'proxy-dns', fromJson: _proxyDnsFromJson)  List<String> proxyDns, @JsonKey(name: 'direct-dns', fromJson: _directDnsFromJson)  List<String> directDns, @JsonKey(name: 'dns-manual')  bool? dnsManual)  $default,) {final _that = this;
switch (_that) {
case _CoreConfig():
return $default(_that.mixedPort,_that.mode,_that.allowLan,_that.logLevel,_that.ipv6,_that.tun,_that.proxyDns,_that.directDns,_that.dnsManual);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'mixed-port')  int mixedPort,  Mode mode, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(fromJson: Tun.safeFormJson)  Tun tun, @JsonKey(name: 'proxy-dns', fromJson: _proxyDnsFromJson)  List<String> proxyDns, @JsonKey(name: 'direct-dns', fromJson: _directDnsFromJson)  List<String> directDns, @JsonKey(name: 'dns-manual')  bool? dnsManual)?  $default,) {final _that = this;
switch (_that) {
case _CoreConfig() when $default != null:
return $default(_that.mixedPort,_that.mode,_that.allowLan,_that.logLevel,_that.ipv6,_that.tun,_that.proxyDns,_that.directDns,_that.dnsManual);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoreConfig implements CoreConfig {
  const _CoreConfig({@JsonKey(name: 'mixed-port') this.mixedPort = defaultMixedPort, this.mode = Mode.rule, @JsonKey(name: 'allow-lan') this.allowLan = false, @JsonKey(name: 'log-level') this.logLevel = LogLevel.error, this.ipv6 = false, @JsonKey(fromJson: Tun.safeFormJson) this.tun = defaultTun, @JsonKey(name: 'proxy-dns', fromJson: _proxyDnsFromJson)  List<String> proxyDns = defaultProxyDnsServers, @JsonKey(name: 'direct-dns', fromJson: _directDnsFromJson)  List<String> directDns = defaultDirectDnsServers, @JsonKey(name: 'dns-manual') this.dnsManual}): _proxyDns = proxyDns,_directDns = directDns;
  factory _CoreConfig.fromJson(Map<String, dynamic> json) => _$CoreConfigFromJson(json);

@override@JsonKey(name: 'mixed-port') final  int mixedPort;
@override@JsonKey() final  Mode mode;
@override@JsonKey(name: 'allow-lan') final  bool allowLan;
@override@JsonKey(name: 'log-level') final  LogLevel logLevel;
@override@JsonKey() final  bool ipv6;
@override@JsonKey(fromJson: Tun.safeFormJson) final  Tun tun;
 final  List<String> _proxyDns;
@override@JsonKey(name: 'proxy-dns', fromJson: _proxyDnsFromJson) List<String> get proxyDns {
  if (_proxyDns is EqualUnmodifiableListView) return _proxyDns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxyDns);
}

 final  List<String> _directDns;
@override@JsonKey(name: 'direct-dns', fromJson: _directDnsFromJson) List<String> get directDns {
  if (_directDns is EqualUnmodifiableListView) return _directDns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_directDns);
}

@override@JsonKey(name: 'dns-manual') final  bool? dnsManual;

/// Create a copy of CoreConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreConfigCopyWith<_CoreConfig> get copyWith => __$CoreConfigCopyWithImpl<_CoreConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoreConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreConfig&&(identical(other.mixedPort, mixedPort) || other.mixedPort == mixedPort)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.allowLan, allowLan) || other.allowLan == allowLan)&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.tun, tun) || other.tun == tun)&&const DeepCollectionEquality().equals(other.proxyDns, _proxyDns)&&const DeepCollectionEquality().equals(other.directDns, _directDns)&&(identical(other.dnsManual, dnsManual) || other.dnsManual == dnsManual));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,mixedPort,mode,allowLan,logLevel,ipv6,tun,const DeepCollectionEquality().hash(_proxyDns),const DeepCollectionEquality().hash(_directDns),dnsManual);
}

@override
String toString() {
    return 'CoreConfig(mixedPort: $mixedPort, mode: $mode, allowLan: $allowLan, logLevel: $logLevel, ipv6: $ipv6, tun: $tun, proxyDns: $proxyDns, directDns: $directDns, dnsManual: $dnsManual)';
}


}

/// @nodoc
abstract mixin class _$CoreConfigCopyWith<$Res> implements $CoreConfigCopyWith<$Res> {
  factory _$CoreConfigCopyWith(_CoreConfig value, $Res Function(_CoreConfig) _then) = __$CoreConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'mixed-port') int mixedPort, Mode mode,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(fromJson: Tun.safeFormJson) Tun tun,@JsonKey(name: 'proxy-dns', fromJson: _proxyDnsFromJson) List<String> proxyDns,@JsonKey(name: 'direct-dns', fromJson: _directDnsFromJson) List<String> directDns,@JsonKey(name: 'dns-manual') bool? dnsManual
});


@override $TunCopyWith<$Res> get tun;

}
/// @nodoc
class __$CoreConfigCopyWithImpl<$Res>
    implements _$CoreConfigCopyWith<$Res> {
  __$CoreConfigCopyWithImpl(this._self, this._then);

  final _CoreConfig _self;
  final $Res Function(_CoreConfig) _then;

/// Create a copy of CoreConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mixedPort = null,Object? mode = null,Object? allowLan = null,Object? logLevel = null,Object? ipv6 = null,Object? tun = null,Object? proxyDns = null,Object? directDns = null,Object? dnsManual = freezed,}) {
  return _then(_CoreConfig(
mixedPort: null == mixedPort ? _self.mixedPort : mixedPort // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,allowLan: null == allowLan ? _self.allowLan : allowLan // ignore: cast_nullable_to_non_nullable
as bool,logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as Tun,proxyDns: null == proxyDns ? _self._proxyDns : proxyDns // ignore: cast_nullable_to_non_nullable
as List<String>,directDns: null == directDns ? _self._directDns : directDns // ignore: cast_nullable_to_non_nullable
as List<String>,dnsManual: freezed == dnsManual ? _self.dnsManual : dnsManual // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of CoreConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunCopyWith<$Res> get tun {
  
  return $TunCopyWith<$Res>(_self.tun, (value) {
    return _then(_self.copyWith(tun: value));
  });
}
}

// dart format on
