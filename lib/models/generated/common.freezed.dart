// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../common.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NavigationItem {

 Glyph get glyph; PageLabel get label; WidgetBuilder get builder; bool get keep; String? get path; List<NavigationItemMode> get modes;
/// Create a copy of NavigationItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavigationItemCopyWith<NavigationItem> get copyWith => _$NavigationItemCopyWithImpl<NavigationItem>(this as NavigationItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NavigationItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationItem&&(identical(other.glyph, _this.glyph) || other.glyph == _this.glyph)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.builder, _this.builder) || other.builder == _this.builder)&&(identical(other.keep, _this.keep) || other.keep == _this.keep)&&(identical(other.path, _this.path) || other.path == _this.path)&&const DeepCollectionEquality().equals(other.modes, _this.modes));
}


@override
int get hashCode {
  final _this = this as NavigationItem;
  return Object.hash(runtimeType,_this.glyph,_this.label,_this.builder,_this.keep,_this.path,const DeepCollectionEquality().hash(_this.modes));
}

@override
String toString() {
  final _this = this as NavigationItem;
  return 'NavigationItem(glyph: ${_this.glyph}, label: ${_this.label}, builder: ${_this.builder}, keep: ${_this.keep}, path: ${_this.path}, modes: ${_this.modes})';
}


}

/// @nodoc
abstract mixin class $NavigationItemCopyWith<$Res>  {
  factory $NavigationItemCopyWith(NavigationItem value, $Res Function(NavigationItem) _then) = _$NavigationItemCopyWithImpl;
@useResult
$Res call({
 Glyph glyph, PageLabel label, WidgetBuilder builder, bool keep, String? path, List<NavigationItemMode> modes
});




}
/// @nodoc
class _$NavigationItemCopyWithImpl<$Res>
    implements $NavigationItemCopyWith<$Res> {
  _$NavigationItemCopyWithImpl(this._self, this._then);

  final NavigationItem _self;
  final $Res Function(NavigationItem) _then;

/// Create a copy of NavigationItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? glyph = null,Object? label = null,Object? builder = null,Object? keep = null,Object? path = freezed,Object? modes = null,}) {
  return _then(NavigationItem(
glyph: null == glyph ? _self.glyph : glyph // ignore: cast_nullable_to_non_nullable
as Glyph,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as PageLabel,builder: null == builder ? _self.builder : builder // ignore: cast_nullable_to_non_nullable
as WidgetBuilder,keep: null == keep ? _self.keep : keep // ignore: cast_nullable_to_non_nullable
as bool,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,modes: null == modes ? _self.modes : modes // ignore: cast_nullable_to_non_nullable
as List<NavigationItemMode>,
  ));
}

}


/// Adds pattern-matching-related methods to [NavigationItem].
extension NavigationItemPatterns on NavigationItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NavigationItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NavigationItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NavigationItem value)  $default,){
final _that = this;
switch (_that) {
case _NavigationItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NavigationItem value)?  $default,){
final _that = this;
switch (_that) {
case _NavigationItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Glyph glyph,  PageLabel label,  WidgetBuilder builder,  bool keep,  String? path,  List<NavigationItemMode> modes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NavigationItem() when $default != null:
return $default(_that.glyph,_that.label,_that.builder,_that.keep,_that.path,_that.modes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Glyph glyph,  PageLabel label,  WidgetBuilder builder,  bool keep,  String? path,  List<NavigationItemMode> modes)  $default,) {final _that = this;
switch (_that) {
case _NavigationItem():
return $default(_that.glyph,_that.label,_that.builder,_that.keep,_that.path,_that.modes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Glyph glyph,  PageLabel label,  WidgetBuilder builder,  bool keep,  String? path,  List<NavigationItemMode> modes)?  $default,) {final _that = this;
switch (_that) {
case _NavigationItem() when $default != null:
return $default(_that.glyph,_that.label,_that.builder,_that.keep,_that.path,_that.modes);case _:
  return null;

}
}

}

/// @nodoc


class _NavigationItem implements NavigationItem {
  const _NavigationItem({required this.glyph, required this.label, required this.builder, this.keep = true, this.path,  List<NavigationItemMode> modes = const [NavigationItemMode.mobile, NavigationItemMode.desktop]}): _modes = modes;
  

@override final  Glyph glyph;
@override final  PageLabel label;
@override final  WidgetBuilder builder;
@override@JsonKey() final  bool keep;
@override final  String? path;
 final  List<NavigationItemMode> _modes;
@override@JsonKey() List<NavigationItemMode> get modes {
  if (_modes is EqualUnmodifiableListView) return _modes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modes);
}


/// Create a copy of NavigationItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavigationItemCopyWith<_NavigationItem> get copyWith => __$NavigationItemCopyWithImpl<_NavigationItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavigationItem&&(identical(other.glyph, glyph) || other.glyph == glyph)&&(identical(other.label, label) || other.label == label)&&(identical(other.builder, builder) || other.builder == builder)&&(identical(other.keep, keep) || other.keep == keep)&&(identical(other.path, path) || other.path == path)&&const DeepCollectionEquality().equals(other.modes, _modes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,glyph,label,builder,keep,path,const DeepCollectionEquality().hash(_modes));
}

@override
String toString() {
    return 'NavigationItem(glyph: $glyph, label: $label, builder: $builder, keep: $keep, path: $path, modes: $modes)';
}


}

/// @nodoc
abstract mixin class _$NavigationItemCopyWith<$Res> implements $NavigationItemCopyWith<$Res> {
  factory _$NavigationItemCopyWith(_NavigationItem value, $Res Function(_NavigationItem) _then) = __$NavigationItemCopyWithImpl;
@override @useResult
$Res call({
 Glyph glyph, PageLabel label, WidgetBuilder builder, bool keep, String? path, List<NavigationItemMode> modes
});




}
/// @nodoc
class __$NavigationItemCopyWithImpl<$Res>
    implements _$NavigationItemCopyWith<$Res> {
  __$NavigationItemCopyWithImpl(this._self, this._then);

  final _NavigationItem _self;
  final $Res Function(_NavigationItem) _then;

/// Create a copy of NavigationItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? glyph = null,Object? label = null,Object? builder = null,Object? keep = null,Object? path = freezed,Object? modes = null,}) {
  return _then(_NavigationItem(
glyph: null == glyph ? _self.glyph : glyph // ignore: cast_nullable_to_non_nullable
as Glyph,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as PageLabel,builder: null == builder ? _self.builder : builder // ignore: cast_nullable_to_non_nullable
as WidgetBuilder,keep: null == keep ? _self.keep : keep // ignore: cast_nullable_to_non_nullable
as bool,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,modes: null == modes ? _self._modes : modes // ignore: cast_nullable_to_non_nullable
as List<NavigationItemMode>,
  ));
}


}


/// @nodoc
mixin _$Package {

 String get packageName; String get label; bool get system; bool get internet; int get lastUpdateTime;
/// Create a copy of Package
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackageCopyWith<Package> get copyWith => _$PackageCopyWithImpl<Package>(this as Package, _$identity);

  /// Serializes this Package to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Package;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Package&&(identical(other.packageName, _this.packageName) || other.packageName == _this.packageName)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.system, _this.system) || other.system == _this.system)&&(identical(other.internet, _this.internet) || other.internet == _this.internet)&&(identical(other.lastUpdateTime, _this.lastUpdateTime) || other.lastUpdateTime == _this.lastUpdateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Package;
  return Object.hash(runtimeType,_this.packageName,_this.label,_this.system,_this.internet,_this.lastUpdateTime);
}

@override
String toString() {
  final _this = this as Package;
  return 'Package(packageName: ${_this.packageName}, label: ${_this.label}, system: ${_this.system}, internet: ${_this.internet}, lastUpdateTime: ${_this.lastUpdateTime})';
}


}

/// @nodoc
abstract mixin class $PackageCopyWith<$Res>  {
  factory $PackageCopyWith(Package value, $Res Function(Package) _then) = _$PackageCopyWithImpl;
@useResult
$Res call({
 String packageName, String label, bool system, bool internet, int lastUpdateTime
});




}
/// @nodoc
class _$PackageCopyWithImpl<$Res>
    implements $PackageCopyWith<$Res> {
  _$PackageCopyWithImpl(this._self, this._then);

  final Package _self;
  final $Res Function(Package) _then;

/// Create a copy of Package
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packageName = null,Object? label = null,Object? system = null,Object? internet = null,Object? lastUpdateTime = null,}) {
  return _then(Package(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,system: null == system ? _self.system : system // ignore: cast_nullable_to_non_nullable
as bool,internet: null == internet ? _self.internet : internet // ignore: cast_nullable_to_non_nullable
as bool,lastUpdateTime: null == lastUpdateTime ? _self.lastUpdateTime : lastUpdateTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Package].
extension PackagePatterns on Package {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Package value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Package() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Package value)  $default,){
final _that = this;
switch (_that) {
case _Package():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Package value)?  $default,){
final _that = this;
switch (_that) {
case _Package() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String packageName,  String label,  bool system,  bool internet,  int lastUpdateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Package() when $default != null:
return $default(_that.packageName,_that.label,_that.system,_that.internet,_that.lastUpdateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String packageName,  String label,  bool system,  bool internet,  int lastUpdateTime)  $default,) {final _that = this;
switch (_that) {
case _Package():
return $default(_that.packageName,_that.label,_that.system,_that.internet,_that.lastUpdateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String packageName,  String label,  bool system,  bool internet,  int lastUpdateTime)?  $default,) {final _that = this;
switch (_that) {
case _Package() when $default != null:
return $default(_that.packageName,_that.label,_that.system,_that.internet,_that.lastUpdateTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Package implements Package {
  const _Package({required this.packageName, required this.label, required this.system, required this.internet, required this.lastUpdateTime});
  factory _Package.fromJson(Map<String, dynamic> json) => _$PackageFromJson(json);

@override final  String packageName;
@override final  String label;
@override final  bool system;
@override final  bool internet;
@override final  int lastUpdateTime;

/// Create a copy of Package
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackageCopyWith<_Package> get copyWith => __$PackageCopyWithImpl<_Package>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Package&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.label, label) || other.label == label)&&(identical(other.system, system) || other.system == system)&&(identical(other.internet, internet) || other.internet == internet)&&(identical(other.lastUpdateTime, lastUpdateTime) || other.lastUpdateTime == lastUpdateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,packageName,label,system,internet,lastUpdateTime);
}

@override
String toString() {
    return 'Package(packageName: $packageName, label: $label, system: $system, internet: $internet, lastUpdateTime: $lastUpdateTime)';
}


}

/// @nodoc
abstract mixin class _$PackageCopyWith<$Res> implements $PackageCopyWith<$Res> {
  factory _$PackageCopyWith(_Package value, $Res Function(_Package) _then) = __$PackageCopyWithImpl;
@override @useResult
$Res call({
 String packageName, String label, bool system, bool internet, int lastUpdateTime
});




}
/// @nodoc
class __$PackageCopyWithImpl<$Res>
    implements _$PackageCopyWith<$Res> {
  __$PackageCopyWithImpl(this._self, this._then);

  final _Package _self;
  final $Res Function(_Package) _then;

/// Create a copy of Package
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageName = null,Object? label = null,Object? system = null,Object? internet = null,Object? lastUpdateTime = null,}) {
  return _then(_Package(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,system: null == system ? _self.system : system // ignore: cast_nullable_to_non_nullable
as bool,internet: null == internet ? _self.internet : internet // ignore: cast_nullable_to_non_nullable
as bool,lastUpdateTime: null == lastUpdateTime ? _self.lastUpdateTime : lastUpdateTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Log {

@JsonKey(name: 'LogLevel') LogLevel get logLevel;@JsonKey(name: 'Payload') String get payload;@JsonKey(fromJson: _logDateTime) String get dateTime;
/// Create a copy of Log
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogCopyWith<Log> get copyWith => _$LogCopyWithImpl<Log>(this as Log, _$identity);

  /// Serializes this Log to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Log;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Log&&(identical(other.logLevel, _this.logLevel) || other.logLevel == _this.logLevel)&&(identical(other.payload, _this.payload) || other.payload == _this.payload)&&(identical(other.dateTime, _this.dateTime) || other.dateTime == _this.dateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Log;
  return Object.hash(runtimeType,_this.logLevel,_this.payload,_this.dateTime);
}

@override
String toString() {
  final _this = this as Log;
  return 'Log(logLevel: ${_this.logLevel}, payload: ${_this.payload}, dateTime: ${_this.dateTime})';
}


}

/// @nodoc
abstract mixin class $LogCopyWith<$Res>  {
  factory $LogCopyWith(Log value, $Res Function(Log) _then) = _$LogCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'LogLevel') LogLevel logLevel,@JsonKey(name: 'Payload') String payload,@JsonKey(fromJson: _logDateTime) String dateTime
});




}
/// @nodoc
class _$LogCopyWithImpl<$Res>
    implements $LogCopyWith<$Res> {
  _$LogCopyWithImpl(this._self, this._then);

  final Log _self;
  final $Res Function(Log) _then;

/// Create a copy of Log
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? logLevel = null,Object? payload = null,Object? dateTime = null,}) {
  return _then(Log(
logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Log].
extension LogPatterns on Log {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Log value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Log() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Log value)  $default,){
final _that = this;
switch (_that) {
case _Log():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Log value)?  $default,){
final _that = this;
switch (_that) {
case _Log() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'LogLevel')  LogLevel logLevel, @JsonKey(name: 'Payload')  String payload, @JsonKey(fromJson: _logDateTime)  String dateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Log() when $default != null:
return $default(_that.logLevel,_that.payload,_that.dateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'LogLevel')  LogLevel logLevel, @JsonKey(name: 'Payload')  String payload, @JsonKey(fromJson: _logDateTime)  String dateTime)  $default,) {final _that = this;
switch (_that) {
case _Log():
return $default(_that.logLevel,_that.payload,_that.dateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'LogLevel')  LogLevel logLevel, @JsonKey(name: 'Payload')  String payload, @JsonKey(fromJson: _logDateTime)  String dateTime)?  $default,) {final _that = this;
switch (_that) {
case _Log() when $default != null:
return $default(_that.logLevel,_that.payload,_that.dateTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Log implements Log {
  const _Log({@JsonKey(name: 'LogLevel') this.logLevel = LogLevel.info, @JsonKey(name: 'Payload') this.payload = '', @JsonKey(fromJson: _logDateTime) required this.dateTime});
  factory _Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);

@override@JsonKey(name: 'LogLevel') final  LogLevel logLevel;
@override@JsonKey(name: 'Payload') final  String payload;
@override@JsonKey(fromJson: _logDateTime) final  String dateTime;

/// Create a copy of Log
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogCopyWith<_Log> get copyWith => __$LogCopyWithImpl<_Log>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Log&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,logLevel,payload,dateTime);
}

@override
String toString() {
    return 'Log(logLevel: $logLevel, payload: $payload, dateTime: $dateTime)';
}


}

/// @nodoc
abstract mixin class _$LogCopyWith<$Res> implements $LogCopyWith<$Res> {
  factory _$LogCopyWith(_Log value, $Res Function(_Log) _then) = __$LogCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'LogLevel') LogLevel logLevel,@JsonKey(name: 'Payload') String payload,@JsonKey(fromJson: _logDateTime) String dateTime
});




}
/// @nodoc
class __$LogCopyWithImpl<$Res>
    implements _$LogCopyWith<$Res> {
  __$LogCopyWithImpl(this._self, this._then);

  final _Log _self;
  final $Res Function(_Log) _then;

/// Create a copy of Log
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? logLevel = null,Object? payload = null,Object? dateTime = null,}) {
  return _then(_Log(
logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$LogsState {

 List<Log> get logs; List<String> get keywords; String get query; bool get autoScrollToEnd;
/// Create a copy of LogsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogsStateCopyWith<LogsState> get copyWith => _$LogsStateCopyWithImpl<LogsState>(this as LogsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LogsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogsState&&const DeepCollectionEquality().equals(other.logs, _this.logs)&&const DeepCollectionEquality().equals(other.keywords, _this.keywords)&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.autoScrollToEnd, _this.autoScrollToEnd) || other.autoScrollToEnd == _this.autoScrollToEnd));
}


@override
int get hashCode {
  final _this = this as LogsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.logs),const DeepCollectionEquality().hash(_this.keywords),_this.query,_this.autoScrollToEnd);
}

@override
String toString() {
  final _this = this as LogsState;
  return 'LogsState(logs: ${_this.logs}, keywords: ${_this.keywords}, query: ${_this.query}, autoScrollToEnd: ${_this.autoScrollToEnd})';
}


}

/// @nodoc
abstract mixin class $LogsStateCopyWith<$Res>  {
  factory $LogsStateCopyWith(LogsState value, $Res Function(LogsState) _then) = _$LogsStateCopyWithImpl;
@useResult
$Res call({
 List<Log> logs, List<String> keywords, String query, bool autoScrollToEnd
});




}
/// @nodoc
class _$LogsStateCopyWithImpl<$Res>
    implements $LogsStateCopyWith<$Res> {
  _$LogsStateCopyWithImpl(this._self, this._then);

  final LogsState _self;
  final $Res Function(LogsState) _then;

/// Create a copy of LogsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? logs = null,Object? keywords = null,Object? query = null,Object? autoScrollToEnd = null,}) {
  return _then(LogsState(
logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as List<Log>,keywords: null == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,autoScrollToEnd: null == autoScrollToEnd ? _self.autoScrollToEnd : autoScrollToEnd // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LogsState].
extension LogsStatePatterns on LogsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogsState value)  $default,){
final _that = this;
switch (_that) {
case _LogsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogsState value)?  $default,){
final _that = this;
switch (_that) {
case _LogsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Log> logs,  List<String> keywords,  String query,  bool autoScrollToEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogsState() when $default != null:
return $default(_that.logs,_that.keywords,_that.query,_that.autoScrollToEnd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Log> logs,  List<String> keywords,  String query,  bool autoScrollToEnd)  $default,) {final _that = this;
switch (_that) {
case _LogsState():
return $default(_that.logs,_that.keywords,_that.query,_that.autoScrollToEnd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Log> logs,  List<String> keywords,  String query,  bool autoScrollToEnd)?  $default,) {final _that = this;
switch (_that) {
case _LogsState() when $default != null:
return $default(_that.logs,_that.keywords,_that.query,_that.autoScrollToEnd);case _:
  return null;

}
}

}

/// @nodoc


class _LogsState implements LogsState {
  const _LogsState({ List<Log> logs = const [],  List<String> keywords = const [], this.query = '', this.autoScrollToEnd = true}): _logs = logs,_keywords = keywords;
  

 final  List<Log> _logs;
@override@JsonKey() List<Log> get logs {
  if (_logs is EqualUnmodifiableListView) return _logs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logs);
}

 final  List<String> _keywords;
@override@JsonKey() List<String> get keywords {
  if (_keywords is EqualUnmodifiableListView) return _keywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keywords);
}

@override@JsonKey() final  String query;
@override@JsonKey() final  bool autoScrollToEnd;

/// Create a copy of LogsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogsStateCopyWith<_LogsState> get copyWith => __$LogsStateCopyWithImpl<_LogsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogsState&&const DeepCollectionEquality().equals(other.logs, _logs)&&const DeepCollectionEquality().equals(other.keywords, _keywords)&&(identical(other.query, query) || other.query == query)&&(identical(other.autoScrollToEnd, autoScrollToEnd) || other.autoScrollToEnd == autoScrollToEnd));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_logs),const DeepCollectionEquality().hash(_keywords),query,autoScrollToEnd);
}

@override
String toString() {
    return 'LogsState(logs: $logs, keywords: $keywords, query: $query, autoScrollToEnd: $autoScrollToEnd)';
}


}

/// @nodoc
abstract mixin class _$LogsStateCopyWith<$Res> implements $LogsStateCopyWith<$Res> {
  factory _$LogsStateCopyWith(_LogsState value, $Res Function(_LogsState) _then) = __$LogsStateCopyWithImpl;
@override @useResult
$Res call({
 List<Log> logs, List<String> keywords, String query, bool autoScrollToEnd
});




}
/// @nodoc
class __$LogsStateCopyWithImpl<$Res>
    implements _$LogsStateCopyWith<$Res> {
  __$LogsStateCopyWithImpl(this._self, this._then);

  final _LogsState _self;
  final $Res Function(_LogsState) _then;

/// Create a copy of LogsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? logs = null,Object? keywords = null,Object? query = null,Object? autoScrollToEnd = null,}) {
  return _then(_LogsState(
logs: null == logs ? _self._logs : logs // ignore: cast_nullable_to_non_nullable
as List<Log>,keywords: null == keywords ? _self._keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,autoScrollToEnd: null == autoScrollToEnd ? _self.autoScrollToEnd : autoScrollToEnd // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DAVProps {

 String get uri; String get user;@JsonKey(fromJson: _decodeDavPassword, toJson: _encodeDavPassword) String get password; String get fileName;
/// Create a copy of DAVProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DAVPropsCopyWith<DAVProps> get copyWith => _$DAVPropsCopyWithImpl<DAVProps>(this as DAVProps, _$identity);

  /// Serializes this DAVProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DAVProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DAVProps&&(identical(other.uri, _this.uri) || other.uri == _this.uri)&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DAVProps;
  return Object.hash(runtimeType,_this.uri,_this.user,_this.password,_this.fileName);
}



}

/// @nodoc
abstract mixin class $DAVPropsCopyWith<$Res>  {
  factory $DAVPropsCopyWith(DAVProps value, $Res Function(DAVProps) _then) = _$DAVPropsCopyWithImpl;
@useResult
$Res call({
 String uri, String user,@JsonKey(fromJson: _decodeDavPassword, toJson: _encodeDavPassword) String password, String fileName
});




}
/// @nodoc
class _$DAVPropsCopyWithImpl<$Res>
    implements $DAVPropsCopyWith<$Res> {
  _$DAVPropsCopyWithImpl(this._self, this._then);

  final DAVProps _self;
  final $Res Function(DAVProps) _then;

/// Create a copy of DAVProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uri = null,Object? user = null,Object? password = null,Object? fileName = null,}) {
  return _then(DAVProps(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DAVProps].
extension DAVPropsPatterns on DAVProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DAVProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DAVProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DAVProps value)  $default,){
final _that = this;
switch (_that) {
case _DAVProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DAVProps value)?  $default,){
final _that = this;
switch (_that) {
case _DAVProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uri,  String user, @JsonKey(fromJson: _decodeDavPassword, toJson: _encodeDavPassword)  String password,  String fileName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DAVProps() when $default != null:
return $default(_that.uri,_that.user,_that.password,_that.fileName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uri,  String user, @JsonKey(fromJson: _decodeDavPassword, toJson: _encodeDavPassword)  String password,  String fileName)  $default,) {final _that = this;
switch (_that) {
case _DAVProps():
return $default(_that.uri,_that.user,_that.password,_that.fileName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uri,  String user, @JsonKey(fromJson: _decodeDavPassword, toJson: _encodeDavPassword)  String password,  String fileName)?  $default,) {final _that = this;
switch (_that) {
case _DAVProps() when $default != null:
return $default(_that.uri,_that.user,_that.password,_that.fileName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DAVProps extends DAVProps {
  const _DAVProps({required this.uri, required this.user, @JsonKey(fromJson: _decodeDavPassword, toJson: _encodeDavPassword) this.password = '', this.fileName = defaultDavFileName}): super._();
  factory _DAVProps.fromJson(Map<String, dynamic> json) => _$DAVPropsFromJson(json);

@override final  String uri;
@override final  String user;
@override@JsonKey(fromJson: _decodeDavPassword, toJson: _encodeDavPassword) final  String password;
@override@JsonKey() final  String fileName;

/// Create a copy of DAVProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DAVPropsCopyWith<_DAVProps> get copyWith => __$DAVPropsCopyWithImpl<_DAVProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DAVPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DAVProps&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.user, user) || other.user == user)&&(identical(other.password, password) || other.password == password)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,uri,user,password,fileName);
}



}

/// @nodoc
abstract mixin class _$DAVPropsCopyWith<$Res> implements $DAVPropsCopyWith<$Res> {
  factory _$DAVPropsCopyWith(_DAVProps value, $Res Function(_DAVProps) _then) = __$DAVPropsCopyWithImpl;
@override @useResult
$Res call({
 String uri, String user,@JsonKey(fromJson: _decodeDavPassword, toJson: _encodeDavPassword) String password, String fileName
});




}
/// @nodoc
class __$DAVPropsCopyWithImpl<$Res>
    implements _$DAVPropsCopyWith<$Res> {
  __$DAVPropsCopyWithImpl(this._self, this._then);

  final _DAVProps _self;
  final $Res Function(_DAVProps) _then;

/// Create a copy of DAVProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? user = null,Object? password = null,Object? fileName = null,}) {
  return _then(_DAVProps(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$FileInfo {

 int get size; DateTime? get lastModified;
/// Create a copy of FileInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileInfoCopyWith<FileInfo> get copyWith => _$FileInfoCopyWithImpl<FileInfo>(this as FileInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FileInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileInfo&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.lastModified, _this.lastModified) || other.lastModified == _this.lastModified));
}


@override
int get hashCode {
  final _this = this as FileInfo;
  return Object.hash(runtimeType,_this.size,_this.lastModified);
}

@override
String toString() {
  final _this = this as FileInfo;
  return 'FileInfo(size: ${_this.size}, lastModified: ${_this.lastModified})';
}


}

/// @nodoc
abstract mixin class $FileInfoCopyWith<$Res>  {
  factory $FileInfoCopyWith(FileInfo value, $Res Function(FileInfo) _then) = _$FileInfoCopyWithImpl;
@useResult
$Res call({
 int size, DateTime? lastModified
});




}
/// @nodoc
class _$FileInfoCopyWithImpl<$Res>
    implements $FileInfoCopyWith<$Res> {
  _$FileInfoCopyWithImpl(this._self, this._then);

  final FileInfo _self;
  final $Res Function(FileInfo) _then;

/// Create a copy of FileInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? size = null,Object? lastModified = freezed,}) {
  return _then(FileInfo(
size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,lastModified: freezed == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FileInfo].
extension FileInfoPatterns on FileInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileInfo value)  $default,){
final _that = this;
switch (_that) {
case _FileInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileInfo value)?  $default,){
final _that = this;
switch (_that) {
case _FileInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int size,  DateTime? lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileInfo() when $default != null:
return $default(_that.size,_that.lastModified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int size,  DateTime? lastModified)  $default,) {final _that = this;
switch (_that) {
case _FileInfo():
return $default(_that.size,_that.lastModified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int size,  DateTime? lastModified)?  $default,) {final _that = this;
switch (_that) {
case _FileInfo() when $default != null:
return $default(_that.size,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc


class _FileInfo implements FileInfo {
  const _FileInfo({required this.size, this.lastModified});
  

@override final  int size;
@override final  DateTime? lastModified;

/// Create a copy of FileInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileInfoCopyWith<_FileInfo> get copyWith => __$FileInfoCopyWithImpl<_FileInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileInfo&&(identical(other.size, size) || other.size == size)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}


@override
int get hashCode {
    return Object.hash(runtimeType,size,lastModified);
}

@override
String toString() {
    return 'FileInfo(size: $size, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$FileInfoCopyWith<$Res> implements $FileInfoCopyWith<$Res> {
  factory _$FileInfoCopyWith(_FileInfo value, $Res Function(_FileInfo) _then) = __$FileInfoCopyWithImpl;
@override @useResult
$Res call({
 int size, DateTime? lastModified
});




}
/// @nodoc
class __$FileInfoCopyWithImpl<$Res>
    implements _$FileInfoCopyWith<$Res> {
  __$FileInfoCopyWithImpl(this._self, this._then);

  final _FileInfo _self;
  final $Res Function(_FileInfo) _then;

/// Create a copy of FileInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? size = null,Object? lastModified = freezed,}) {
  return _then(_FileInfo(
size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,lastModified: freezed == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Traffic {

 num get up; num get down;
/// Create a copy of Traffic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrafficCopyWith<Traffic> get copyWith => _$TrafficCopyWithImpl<Traffic>(this as Traffic, _$identity);

  /// Serializes this Traffic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Traffic;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Traffic&&(identical(other.up, _this.up) || other.up == _this.up)&&(identical(other.down, _this.down) || other.down == _this.down));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Traffic;
  return Object.hash(runtimeType,_this.up,_this.down);
}

@override
String toString() {
  final _this = this as Traffic;
  return 'Traffic(up: ${_this.up}, down: ${_this.down})';
}


}

/// @nodoc
abstract mixin class $TrafficCopyWith<$Res>  {
  factory $TrafficCopyWith(Traffic value, $Res Function(Traffic) _then) = _$TrafficCopyWithImpl;
@useResult
$Res call({
 num up, num down
});




}
/// @nodoc
class _$TrafficCopyWithImpl<$Res>
    implements $TrafficCopyWith<$Res> {
  _$TrafficCopyWithImpl(this._self, this._then);

  final Traffic _self;
  final $Res Function(Traffic) _then;

/// Create a copy of Traffic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? up = null,Object? down = null,}) {
  return _then(Traffic(
up: null == up ? _self.up : up // ignore: cast_nullable_to_non_nullable
as num,down: null == down ? _self.down : down // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [Traffic].
extension TrafficPatterns on Traffic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Traffic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Traffic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Traffic value)  $default,){
final _that = this;
switch (_that) {
case _Traffic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Traffic value)?  $default,){
final _that = this;
switch (_that) {
case _Traffic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num up,  num down)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Traffic() when $default != null:
return $default(_that.up,_that.down);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num up,  num down)  $default,) {final _that = this;
switch (_that) {
case _Traffic():
return $default(_that.up,_that.down);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num up,  num down)?  $default,) {final _that = this;
switch (_that) {
case _Traffic() when $default != null:
return $default(_that.up,_that.down);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Traffic implements Traffic {
  const _Traffic({this.up = 0, this.down = 0});
  factory _Traffic.fromJson(Map<String, dynamic> json) => _$TrafficFromJson(json);

@override@JsonKey() final  num up;
@override@JsonKey() final  num down;

/// Create a copy of Traffic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrafficCopyWith<_Traffic> get copyWith => __$TrafficCopyWithImpl<_Traffic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrafficToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Traffic&&(identical(other.up, up) || other.up == up)&&(identical(other.down, down) || other.down == down));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,up,down);
}

@override
String toString() {
    return 'Traffic(up: $up, down: $down)';
}


}

/// @nodoc
abstract mixin class _$TrafficCopyWith<$Res> implements $TrafficCopyWith<$Res> {
  factory _$TrafficCopyWith(_Traffic value, $Res Function(_Traffic) _then) = __$TrafficCopyWithImpl;
@override @useResult
$Res call({
 num up, num down
});




}
/// @nodoc
class __$TrafficCopyWithImpl<$Res>
    implements _$TrafficCopyWith<$Res> {
  __$TrafficCopyWithImpl(this._self, this._then);

  final _Traffic _self;
  final $Res Function(_Traffic) _then;

/// Create a copy of Traffic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? up = null,Object? down = null,}) {
  return _then(_Traffic(
up: null == up ? _self.up : up // ignore: cast_nullable_to_non_nullable
as num,down: null == down ? _self.down : down // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

/// @nodoc
mixin _$TrafficShow {

 String get value; String get unit;
/// Create a copy of TrafficShow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrafficShowCopyWith<TrafficShow> get copyWith => _$TrafficShowCopyWithImpl<TrafficShow>(this as TrafficShow, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TrafficShow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrafficShow&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.unit, _this.unit) || other.unit == _this.unit));
}


@override
int get hashCode {
  final _this = this as TrafficShow;
  return Object.hash(runtimeType,_this.value,_this.unit);
}

@override
String toString() {
  final _this = this as TrafficShow;
  return 'TrafficShow(value: ${_this.value}, unit: ${_this.unit})';
}


}

/// @nodoc
abstract mixin class $TrafficShowCopyWith<$Res>  {
  factory $TrafficShowCopyWith(TrafficShow value, $Res Function(TrafficShow) _then) = _$TrafficShowCopyWithImpl;
@useResult
$Res call({
 String value, String unit
});




}
/// @nodoc
class _$TrafficShowCopyWithImpl<$Res>
    implements $TrafficShowCopyWith<$Res> {
  _$TrafficShowCopyWithImpl(this._self, this._then);

  final TrafficShow _self;
  final $Res Function(TrafficShow) _then;

/// Create a copy of TrafficShow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? unit = null,}) {
  return _then(TrafficShow(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TrafficShow].
extension TrafficShowPatterns on TrafficShow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrafficShow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrafficShow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrafficShow value)  $default,){
final _that = this;
switch (_that) {
case _TrafficShow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrafficShow value)?  $default,){
final _that = this;
switch (_that) {
case _TrafficShow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  String unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrafficShow() when $default != null:
return $default(_that.value,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  String unit)  $default,) {final _that = this;
switch (_that) {
case _TrafficShow():
return $default(_that.value,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  String unit)?  $default,) {final _that = this;
switch (_that) {
case _TrafficShow() when $default != null:
return $default(_that.value,_that.unit);case _:
  return null;

}
}

}

/// @nodoc


class _TrafficShow implements TrafficShow {
  const _TrafficShow({required this.value, required this.unit});
  

@override final  String value;
@override final  String unit;

/// Create a copy of TrafficShow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrafficShowCopyWith<_TrafficShow> get copyWith => __$TrafficShowCopyWithImpl<_TrafficShow>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrafficShow&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit));
}


@override
int get hashCode {
    return Object.hash(runtimeType,value,unit);
}

@override
String toString() {
    return 'TrafficShow(value: $value, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$TrafficShowCopyWith<$Res> implements $TrafficShowCopyWith<$Res> {
  factory _$TrafficShowCopyWith(_TrafficShow value, $Res Function(_TrafficShow) _then) = __$TrafficShowCopyWithImpl;
@override @useResult
$Res call({
 String value, String unit
});




}
/// @nodoc
class __$TrafficShowCopyWithImpl<$Res>
    implements _$TrafficShowCopyWith<$Res> {
  __$TrafficShowCopyWithImpl(this._self, this._then);

  final _TrafficShow _self;
  final $Res Function(_TrafficShow) _then;

/// Create a copy of TrafficShow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? unit = null,}) {
  return _then(_TrafficShow(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Group {

@JsonKey(fromJson: GroupType.parse) GroupType get type; List<Proxy> get all; String? get now; bool? get hidden; String? get testUrl; String get icon; String get name;
/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupCopyWith<Group> get copyWith => _$GroupCopyWithImpl<Group>(this as Group, _$identity);

  /// Serializes this Group to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Group;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Group&&(identical(other.type, _this.type) || other.type == _this.type)&&const DeepCollectionEquality().equals(other.all, _this.all)&&(identical(other.now, _this.now) || other.now == _this.now)&&(identical(other.hidden, _this.hidden) || other.hidden == _this.hidden)&&(identical(other.testUrl, _this.testUrl) || other.testUrl == _this.testUrl)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Group;
  return Object.hash(runtimeType,_this.type,const DeepCollectionEquality().hash(_this.all),_this.now,_this.hidden,_this.testUrl,_this.icon,_this.name);
}

@override
String toString() {
  final _this = this as Group;
  return 'Group(type: ${_this.type}, all: ${_this.all}, now: ${_this.now}, hidden: ${_this.hidden}, testUrl: ${_this.testUrl}, icon: ${_this.icon}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $GroupCopyWith<$Res>  {
  factory $GroupCopyWith(Group value, $Res Function(Group) _then) = _$GroupCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: GroupType.parse) GroupType type, List<Proxy> all, String? now, bool? hidden, String? testUrl, String icon, String name
});




}
/// @nodoc
class _$GroupCopyWithImpl<$Res>
    implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._self, this._then);

  final Group _self;
  final $Res Function(Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? all = null,Object? now = freezed,Object? hidden = freezed,Object? testUrl = freezed,Object? icon = null,Object? name = null,}) {
  return _then(Group(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GroupType,all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as List<Proxy>,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String?,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,testUrl: freezed == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Group].
extension GroupPatterns on Group {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Group value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Group() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Group value)  $default,){
final _that = this;
switch (_that) {
case _Group():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Group value)?  $default,){
final _that = this;
switch (_that) {
case _Group() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: GroupType.parse)  GroupType type,  List<Proxy> all,  String? now,  bool? hidden,  String? testUrl,  String icon,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.type,_that.all,_that.now,_that.hidden,_that.testUrl,_that.icon,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: GroupType.parse)  GroupType type,  List<Proxy> all,  String? now,  bool? hidden,  String? testUrl,  String icon,  String name)  $default,) {final _that = this;
switch (_that) {
case _Group():
return $default(_that.type,_that.all,_that.now,_that.hidden,_that.testUrl,_that.icon,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: GroupType.parse)  GroupType type,  List<Proxy> all,  String? now,  bool? hidden,  String? testUrl,  String icon,  String name)?  $default,) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.type,_that.all,_that.now,_that.hidden,_that.testUrl,_that.icon,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Group implements Group {
  const _Group({@JsonKey(fromJson: GroupType.parse) required this.type,  List<Proxy> all = const [], this.now, this.hidden, this.testUrl, this.icon = '', required this.name}): _all = all;
  factory _Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

@override@JsonKey(fromJson: GroupType.parse) final  GroupType type;
 final  List<Proxy> _all;
@override@JsonKey() List<Proxy> get all {
  if (_all is EqualUnmodifiableListView) return _all;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_all);
}

@override final  String? now;
@override final  bool? hidden;
@override final  String? testUrl;
@override@JsonKey() final  String icon;
@override final  String name;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupCopyWith<_Group> get copyWith => __$GroupCopyWithImpl<_Group>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Group&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.all, _all)&&(identical(other.now, now) || other.now == now)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_all),now,hidden,testUrl,icon,name);
}

@override
String toString() {
    return 'Group(type: $type, all: $all, now: $now, hidden: $hidden, testUrl: $testUrl, icon: $icon, name: $name)';
}


}

/// @nodoc
abstract mixin class _$GroupCopyWith<$Res> implements $GroupCopyWith<$Res> {
  factory _$GroupCopyWith(_Group value, $Res Function(_Group) _then) = __$GroupCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: GroupType.parse) GroupType type, List<Proxy> all, String? now, bool? hidden, String? testUrl, String icon, String name
});




}
/// @nodoc
class __$GroupCopyWithImpl<$Res>
    implements _$GroupCopyWith<$Res> {
  __$GroupCopyWithImpl(this._self, this._then);

  final _Group _self;
  final $Res Function(_Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? all = null,Object? now = freezed,Object? hidden = freezed,Object? testUrl = freezed,Object? icon = null,Object? name = null,}) {
  return _then(_Group(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GroupType,all: null == all ? _self._all : all // ignore: cast_nullable_to_non_nullable
as List<Proxy>,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String?,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,testUrl: freezed == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ColorSchemes {

 ColorScheme? get lightColorScheme; ColorScheme? get darkColorScheme;
/// Create a copy of ColorSchemes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColorSchemesCopyWith<ColorSchemes> get copyWith => _$ColorSchemesCopyWithImpl<ColorSchemes>(this as ColorSchemes, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ColorSchemes;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ColorSchemes&&(identical(other.lightColorScheme, _this.lightColorScheme) || other.lightColorScheme == _this.lightColorScheme)&&(identical(other.darkColorScheme, _this.darkColorScheme) || other.darkColorScheme == _this.darkColorScheme));
}


@override
int get hashCode {
  final _this = this as ColorSchemes;
  return Object.hash(runtimeType,_this.lightColorScheme,_this.darkColorScheme);
}

@override
String toString() {
  final _this = this as ColorSchemes;
  return 'ColorSchemes(lightColorScheme: ${_this.lightColorScheme}, darkColorScheme: ${_this.darkColorScheme})';
}


}

/// @nodoc
abstract mixin class $ColorSchemesCopyWith<$Res>  {
  factory $ColorSchemesCopyWith(ColorSchemes value, $Res Function(ColorSchemes) _then) = _$ColorSchemesCopyWithImpl;
@useResult
$Res call({
 ColorScheme? lightColorScheme, ColorScheme? darkColorScheme
});




}
/// @nodoc
class _$ColorSchemesCopyWithImpl<$Res>
    implements $ColorSchemesCopyWith<$Res> {
  _$ColorSchemesCopyWithImpl(this._self, this._then);

  final ColorSchemes _self;
  final $Res Function(ColorSchemes) _then;

/// Create a copy of ColorSchemes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lightColorScheme = freezed,Object? darkColorScheme = freezed,}) {
  return _then(ColorSchemes(
lightColorScheme: freezed == lightColorScheme ? _self.lightColorScheme : lightColorScheme // ignore: cast_nullable_to_non_nullable
as ColorScheme?,darkColorScheme: freezed == darkColorScheme ? _self.darkColorScheme : darkColorScheme // ignore: cast_nullable_to_non_nullable
as ColorScheme?,
  ));
}

}


/// Adds pattern-matching-related methods to [ColorSchemes].
extension ColorSchemesPatterns on ColorSchemes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ColorSchemes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ColorSchemes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ColorSchemes value)  $default,){
final _that = this;
switch (_that) {
case _ColorSchemes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ColorSchemes value)?  $default,){
final _that = this;
switch (_that) {
case _ColorSchemes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ColorScheme? lightColorScheme,  ColorScheme? darkColorScheme)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ColorSchemes() when $default != null:
return $default(_that.lightColorScheme,_that.darkColorScheme);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ColorScheme? lightColorScheme,  ColorScheme? darkColorScheme)  $default,) {final _that = this;
switch (_that) {
case _ColorSchemes():
return $default(_that.lightColorScheme,_that.darkColorScheme);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ColorScheme? lightColorScheme,  ColorScheme? darkColorScheme)?  $default,) {final _that = this;
switch (_that) {
case _ColorSchemes() when $default != null:
return $default(_that.lightColorScheme,_that.darkColorScheme);case _:
  return null;

}
}

}

/// @nodoc


class _ColorSchemes implements ColorSchemes {
  const _ColorSchemes({this.lightColorScheme, this.darkColorScheme});
  

@override final  ColorScheme? lightColorScheme;
@override final  ColorScheme? darkColorScheme;

/// Create a copy of ColorSchemes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ColorSchemesCopyWith<_ColorSchemes> get copyWith => __$ColorSchemesCopyWithImpl<_ColorSchemes>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ColorSchemes&&(identical(other.lightColorScheme, lightColorScheme) || other.lightColorScheme == lightColorScheme)&&(identical(other.darkColorScheme, darkColorScheme) || other.darkColorScheme == darkColorScheme));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lightColorScheme,darkColorScheme);
}

@override
String toString() {
    return 'ColorSchemes(lightColorScheme: $lightColorScheme, darkColorScheme: $darkColorScheme)';
}


}

/// @nodoc
abstract mixin class _$ColorSchemesCopyWith<$Res> implements $ColorSchemesCopyWith<$Res> {
  factory _$ColorSchemesCopyWith(_ColorSchemes value, $Res Function(_ColorSchemes) _then) = __$ColorSchemesCopyWithImpl;
@override @useResult
$Res call({
 ColorScheme? lightColorScheme, ColorScheme? darkColorScheme
});




}
/// @nodoc
class __$ColorSchemesCopyWithImpl<$Res>
    implements _$ColorSchemesCopyWith<$Res> {
  __$ColorSchemesCopyWithImpl(this._self, this._then);

  final _ColorSchemes _self;
  final $Res Function(_ColorSchemes) _then;

/// Create a copy of ColorSchemes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lightColorScheme = freezed,Object? darkColorScheme = freezed,}) {
  return _then(_ColorSchemes(
lightColorScheme: freezed == lightColorScheme ? _self.lightColorScheme : lightColorScheme // ignore: cast_nullable_to_non_nullable
as ColorScheme?,darkColorScheme: freezed == darkColorScheme ? _self.darkColorScheme : darkColorScheme // ignore: cast_nullable_to_non_nullable
as ColorScheme?,
  ));
}


}

/// @nodoc
mixin _$IpInfo {

 String get ip; String get countryCode;
/// Create a copy of IpInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IpInfoCopyWith<IpInfo> get copyWith => _$IpInfoCopyWithImpl<IpInfo>(this as IpInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as IpInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IpInfo&&(identical(other.ip, _this.ip) || other.ip == _this.ip)&&(identical(other.countryCode, _this.countryCode) || other.countryCode == _this.countryCode));
}


@override
int get hashCode {
  final _this = this as IpInfo;
  return Object.hash(runtimeType,_this.ip,_this.countryCode);
}

@override
String toString() {
  final _this = this as IpInfo;
  return 'IpInfo(ip: ${_this.ip}, countryCode: ${_this.countryCode})';
}


}

/// @nodoc
abstract mixin class $IpInfoCopyWith<$Res>  {
  factory $IpInfoCopyWith(IpInfo value, $Res Function(IpInfo) _then) = _$IpInfoCopyWithImpl;
@useResult
$Res call({
 String ip, String countryCode
});




}
/// @nodoc
class _$IpInfoCopyWithImpl<$Res>
    implements $IpInfoCopyWith<$Res> {
  _$IpInfoCopyWithImpl(this._self, this._then);

  final IpInfo _self;
  final $Res Function(IpInfo) _then;

/// Create a copy of IpInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ip = null,Object? countryCode = null,}) {
  return _then(IpInfo(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IpInfo].
extension IpInfoPatterns on IpInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IpInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IpInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IpInfo value)  $default,){
final _that = this;
switch (_that) {
case _IpInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IpInfo value)?  $default,){
final _that = this;
switch (_that) {
case _IpInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ip,  String countryCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IpInfo() when $default != null:
return $default(_that.ip,_that.countryCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ip,  String countryCode)  $default,) {final _that = this;
switch (_that) {
case _IpInfo():
return $default(_that.ip,_that.countryCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ip,  String countryCode)?  $default,) {final _that = this;
switch (_that) {
case _IpInfo() when $default != null:
return $default(_that.ip,_that.countryCode);case _:
  return null;

}
}

}

/// @nodoc


class _IpInfo implements IpInfo {
  const _IpInfo({required this.ip, required this.countryCode});
  

@override final  String ip;
@override final  String countryCode;

/// Create a copy of IpInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IpInfoCopyWith<_IpInfo> get copyWith => __$IpInfoCopyWithImpl<_IpInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IpInfo&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode));
}


@override
int get hashCode {
    return Object.hash(runtimeType,ip,countryCode);
}

@override
String toString() {
    return 'IpInfo(ip: $ip, countryCode: $countryCode)';
}


}

/// @nodoc
abstract mixin class _$IpInfoCopyWith<$Res> implements $IpInfoCopyWith<$Res> {
  factory _$IpInfoCopyWith(_IpInfo value, $Res Function(_IpInfo) _then) = __$IpInfoCopyWithImpl;
@override @useResult
$Res call({
 String ip, String countryCode
});




}
/// @nodoc
class __$IpInfoCopyWithImpl<$Res>
    implements _$IpInfoCopyWith<$Res> {
  __$IpInfoCopyWithImpl(this._self, this._then);

  final _IpInfo _self;
  final $Res Function(_IpInfo) _then;

/// Create a copy of IpInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? countryCode = null,}) {
  return _then(_IpInfo(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$HotKeyAction {

 HotAction get action; int? get key; Set<KeyboardModifier> get modifiers;
/// Create a copy of HotKeyAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HotKeyActionCopyWith<HotKeyAction> get copyWith => _$HotKeyActionCopyWithImpl<HotKeyAction>(this as HotKeyAction, _$identity);

  /// Serializes this HotKeyAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HotKeyAction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HotKeyAction&&(identical(other.action, _this.action) || other.action == _this.action)&&(identical(other.key, _this.key) || other.key == _this.key)&&const DeepCollectionEquality().equals(other.modifiers, _this.modifiers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HotKeyAction;
  return Object.hash(runtimeType,_this.action,_this.key,const DeepCollectionEquality().hash(_this.modifiers));
}

@override
String toString() {
  final _this = this as HotKeyAction;
  return 'HotKeyAction(action: ${_this.action}, key: ${_this.key}, modifiers: ${_this.modifiers})';
}


}

/// @nodoc
abstract mixin class $HotKeyActionCopyWith<$Res>  {
  factory $HotKeyActionCopyWith(HotKeyAction value, $Res Function(HotKeyAction) _then) = _$HotKeyActionCopyWithImpl;
@useResult
$Res call({
 HotAction action, int? key, Set<KeyboardModifier> modifiers
});




}
/// @nodoc
class _$HotKeyActionCopyWithImpl<$Res>
    implements $HotKeyActionCopyWith<$Res> {
  _$HotKeyActionCopyWithImpl(this._self, this._then);

  final HotKeyAction _self;
  final $Res Function(HotKeyAction) _then;

/// Create a copy of HotKeyAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? action = null,Object? key = freezed,Object? modifiers = null,}) {
  return _then(HotKeyAction(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as HotAction,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as int?,modifiers: null == modifiers ? _self.modifiers : modifiers // ignore: cast_nullable_to_non_nullable
as Set<KeyboardModifier>,
  ));
}

}


/// Adds pattern-matching-related methods to [HotKeyAction].
extension HotKeyActionPatterns on HotKeyAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HotKeyAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HotKeyAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HotKeyAction value)  $default,){
final _that = this;
switch (_that) {
case _HotKeyAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HotKeyAction value)?  $default,){
final _that = this;
switch (_that) {
case _HotKeyAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HotAction action,  int? key,  Set<KeyboardModifier> modifiers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HotKeyAction() when $default != null:
return $default(_that.action,_that.key,_that.modifiers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HotAction action,  int? key,  Set<KeyboardModifier> modifiers)  $default,) {final _that = this;
switch (_that) {
case _HotKeyAction():
return $default(_that.action,_that.key,_that.modifiers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HotAction action,  int? key,  Set<KeyboardModifier> modifiers)?  $default,) {final _that = this;
switch (_that) {
case _HotKeyAction() when $default != null:
return $default(_that.action,_that.key,_that.modifiers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HotKeyAction implements HotKeyAction {
  const _HotKeyAction({required this.action, this.key,  Set<KeyboardModifier> modifiers = const {}}): _modifiers = modifiers;
  factory _HotKeyAction.fromJson(Map<String, dynamic> json) => _$HotKeyActionFromJson(json);

@override final  HotAction action;
@override final  int? key;
 final  Set<KeyboardModifier> _modifiers;
@override@JsonKey() Set<KeyboardModifier> get modifiers {
  if (_modifiers is EqualUnmodifiableSetView) return _modifiers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_modifiers);
}


/// Create a copy of HotKeyAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HotKeyActionCopyWith<_HotKeyAction> get copyWith => __$HotKeyActionCopyWithImpl<_HotKeyAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HotKeyActionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HotKeyAction&&(identical(other.action, action) || other.action == action)&&(identical(other.key, key) || other.key == key)&&const DeepCollectionEquality().equals(other.modifiers, _modifiers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,action,key,const DeepCollectionEquality().hash(_modifiers));
}

@override
String toString() {
    return 'HotKeyAction(action: $action, key: $key, modifiers: $modifiers)';
}


}

/// @nodoc
abstract mixin class _$HotKeyActionCopyWith<$Res> implements $HotKeyActionCopyWith<$Res> {
  factory _$HotKeyActionCopyWith(_HotKeyAction value, $Res Function(_HotKeyAction) _then) = __$HotKeyActionCopyWithImpl;
@override @useResult
$Res call({
 HotAction action, int? key, Set<KeyboardModifier> modifiers
});




}
/// @nodoc
class __$HotKeyActionCopyWithImpl<$Res>
    implements _$HotKeyActionCopyWith<$Res> {
  __$HotKeyActionCopyWithImpl(this._self, this._then);

  final _HotKeyAction _self;
  final $Res Function(_HotKeyAction) _then;

/// Create a copy of HotKeyAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? action = null,Object? key = freezed,Object? modifiers = null,}) {
  return _then(_HotKeyAction(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as HotAction,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as int?,modifiers: null == modifiers ? _self._modifiers : modifiers // ignore: cast_nullable_to_non_nullable
as Set<KeyboardModifier>,
  ));
}


}

/// @nodoc
mixin _$Result<T> {

 T? get data; ResultType get type; String get message;
/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultCopyWith<T, Result<T>> get copyWith => _$ResultCopyWithImpl<T, Result<T>>(this as Result<T>, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Result<T>;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Result<T>&&const DeepCollectionEquality().equals(other.data, _this.data)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as Result<T>;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.data),_this.type,_this.message);
}

@override
String toString() {
  final _this = this as Result<T>;
  return 'Result<$T>(data: ${_this.data}, type: ${_this.type}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $ResultCopyWith<T,$Res>  {
  factory $ResultCopyWith(Result<T> value, $Res Function(Result<T>) _then) = _$ResultCopyWithImpl;
@useResult
$Res call({
 T? data, ResultType type, String message
});




}
/// @nodoc
class _$ResultCopyWithImpl<T,$Res>
    implements $ResultCopyWith<T, $Res> {
  _$ResultCopyWithImpl(this._self, this._then);

  final Result<T> _self;
  final $Res Function(Result<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,Object? type = null,Object? message = null,}) {
  return _then(Result(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ResultType,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Result].
extension ResultPatterns<T> on Result<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Result<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Result() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Result<T> value)  $default,){
final _that = this;
switch (_that) {
case _Result():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Result<T> value)?  $default,){
final _that = this;
switch (_that) {
case _Result() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( T? data,  ResultType type,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Result() when $default != null:
return $default(_that.data,_that.type,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( T? data,  ResultType type,  String message)  $default,) {final _that = this;
switch (_that) {
case _Result():
return $default(_that.data,_that.type,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( T? data,  ResultType type,  String message)?  $default,) {final _that = this;
switch (_that) {
case _Result() when $default != null:
return $default(_that.data,_that.type,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Result<T> implements Result<T> {
  const _Result({required this.data, required this.type, required this.message});
  

@override final  T? data;
@override final  ResultType type;
@override final  String message;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultCopyWith<T, _Result<T>> get copyWith => __$ResultCopyWithImpl<T, _Result<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Result<T>&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.type, type) || other.type == type)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(data),type,message);
}

@override
String toString() {
    return 'Result<$T>(data: $data, type: $type, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ResultCopyWith<T,$Res> implements $ResultCopyWith<T, $Res> {
  factory _$ResultCopyWith(_Result<T> value, $Res Function(_Result<T>) _then) = __$ResultCopyWithImpl;
@override @useResult
$Res call({
 T? data, ResultType type, String message
});




}
/// @nodoc
class __$ResultCopyWithImpl<T,$Res>
    implements _$ResultCopyWith<T, $Res> {
  __$ResultCopyWithImpl(this._self, this._then);

  final _Result<T> _self;
  final $Res Function(_Result<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,Object? type = null,Object? message = null,}) {
  return _then(_Result<T>(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ResultType,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$DelayState {

 int get delay; bool get group;
/// Create a copy of DelayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DelayStateCopyWith<DelayState> get copyWith => _$DelayStateCopyWithImpl<DelayState>(this as DelayState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DelayState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DelayState&&(identical(other.delay, _this.delay) || other.delay == _this.delay)&&(identical(other.group, _this.group) || other.group == _this.group));
}


@override
int get hashCode {
  final _this = this as DelayState;
  return Object.hash(runtimeType,_this.delay,_this.group);
}

@override
String toString() {
  final _this = this as DelayState;
  return 'DelayState(delay: ${_this.delay}, group: ${_this.group})';
}


}

/// @nodoc
abstract mixin class $DelayStateCopyWith<$Res>  {
  factory $DelayStateCopyWith(DelayState value, $Res Function(DelayState) _then) = _$DelayStateCopyWithImpl;
@useResult
$Res call({
 int delay, bool group
});




}
/// @nodoc
class _$DelayStateCopyWithImpl<$Res>
    implements $DelayStateCopyWith<$Res> {
  _$DelayStateCopyWithImpl(this._self, this._then);

  final DelayState _self;
  final $Res Function(DelayState) _then;

/// Create a copy of DelayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? delay = null,Object? group = null,}) {
  return _then(DelayState(
delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DelayState].
extension DelayStatePatterns on DelayState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DelayState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DelayState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DelayState value)  $default,){
final _that = this;
switch (_that) {
case _DelayState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DelayState value)?  $default,){
final _that = this;
switch (_that) {
case _DelayState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int delay,  bool group)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DelayState() when $default != null:
return $default(_that.delay,_that.group);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int delay,  bool group)  $default,) {final _that = this;
switch (_that) {
case _DelayState():
return $default(_that.delay,_that.group);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int delay,  bool group)?  $default,) {final _that = this;
switch (_that) {
case _DelayState() when $default != null:
return $default(_that.delay,_that.group);case _:
  return null;

}
}

}

/// @nodoc


class _DelayState implements DelayState {
  const _DelayState({required this.delay, required this.group});
  

@override final  int delay;
@override final  bool group;

/// Create a copy of DelayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DelayStateCopyWith<_DelayState> get copyWith => __$DelayStateCopyWithImpl<_DelayState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DelayState&&(identical(other.delay, delay) || other.delay == delay)&&(identical(other.group, group) || other.group == group));
}


@override
int get hashCode {
    return Object.hash(runtimeType,delay,group);
}

@override
String toString() {
    return 'DelayState(delay: $delay, group: $group)';
}


}

/// @nodoc
abstract mixin class _$DelayStateCopyWith<$Res> implements $DelayStateCopyWith<$Res> {
  factory _$DelayStateCopyWith(_DelayState value, $Res Function(_DelayState) _then) = __$DelayStateCopyWithImpl;
@override @useResult
$Res call({
 int delay, bool group
});




}
/// @nodoc
class __$DelayStateCopyWithImpl<$Res>
    implements _$DelayStateCopyWith<$Res> {
  __$DelayStateCopyWithImpl(this._self, this._then);

  final _DelayState _self;
  final $Res Function(_DelayState) _then;

/// Create a copy of DelayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? delay = null,Object? group = null,}) {
  return _then(_DelayState(
delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$UpdatingMessage {

 String get label; String get message;
/// Create a copy of UpdatingMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatingMessageCopyWith<UpdatingMessage> get copyWith => _$UpdatingMessageCopyWithImpl<UpdatingMessage>(this as UpdatingMessage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UpdatingMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatingMessage&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as UpdatingMessage;
  return Object.hash(runtimeType,_this.label,_this.message);
}

@override
String toString() {
  final _this = this as UpdatingMessage;
  return 'UpdatingMessage(label: ${_this.label}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $UpdatingMessageCopyWith<$Res>  {
  factory $UpdatingMessageCopyWith(UpdatingMessage value, $Res Function(UpdatingMessage) _then) = _$UpdatingMessageCopyWithImpl;
@useResult
$Res call({
 String label, String message
});




}
/// @nodoc
class _$UpdatingMessageCopyWithImpl<$Res>
    implements $UpdatingMessageCopyWith<$Res> {
  _$UpdatingMessageCopyWithImpl(this._self, this._then);

  final UpdatingMessage _self;
  final $Res Function(UpdatingMessage) _then;

/// Create a copy of UpdatingMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? message = null,}) {
  return _then(UpdatingMessage(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdatingMessage].
extension UpdatingMessagePatterns on UpdatingMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdatingMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdatingMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdatingMessage value)  $default,){
final _that = this;
switch (_that) {
case _UpdatingMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdatingMessage value)?  $default,){
final _that = this;
switch (_that) {
case _UpdatingMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdatingMessage() when $default != null:
return $default(_that.label,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String message)  $default,) {final _that = this;
switch (_that) {
case _UpdatingMessage():
return $default(_that.label,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String message)?  $default,) {final _that = this;
switch (_that) {
case _UpdatingMessage() when $default != null:
return $default(_that.label,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _UpdatingMessage implements UpdatingMessage {
  const _UpdatingMessage({required this.label, required this.message});
  

@override final  String label;
@override final  String message;

/// Create a copy of UpdatingMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatingMessageCopyWith<_UpdatingMessage> get copyWith => __$UpdatingMessageCopyWithImpl<_UpdatingMessage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatingMessage&&(identical(other.label, label) || other.label == label)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,label,message);
}

@override
String toString() {
    return 'UpdatingMessage(label: $label, message: $message)';
}


}

/// @nodoc
abstract mixin class _$UpdatingMessageCopyWith<$Res> implements $UpdatingMessageCopyWith<$Res> {
  factory _$UpdatingMessageCopyWith(_UpdatingMessage value, $Res Function(_UpdatingMessage) _then) = __$UpdatingMessageCopyWithImpl;
@override @useResult
$Res call({
 String label, String message
});




}
/// @nodoc
class __$UpdatingMessageCopyWithImpl<$Res>
    implements _$UpdatingMessageCopyWith<$Res> {
  __$UpdatingMessageCopyWithImpl(this._self, this._then);

  final _UpdatingMessage _self;
  final $Res Function(_UpdatingMessage) _then;

/// Create a copy of UpdatingMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? message = null,}) {
  return _then(_UpdatingMessage(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$IconButtonData {

 Glyph get glyph; VoidCallback? get onPressed; String? get tooltip; bool get isLoading;
/// Create a copy of IconButtonData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IconButtonDataCopyWith<IconButtonData> get copyWith => _$IconButtonDataCopyWithImpl<IconButtonData>(this as IconButtonData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as IconButtonData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IconButtonData&&(identical(other.glyph, _this.glyph) || other.glyph == _this.glyph)&&(identical(other.onPressed, _this.onPressed) || other.onPressed == _this.onPressed)&&(identical(other.tooltip, _this.tooltip) || other.tooltip == _this.tooltip)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading));
}


@override
int get hashCode {
  final _this = this as IconButtonData;
  return Object.hash(runtimeType,_this.glyph,_this.onPressed,_this.tooltip,_this.isLoading);
}

@override
String toString() {
  final _this = this as IconButtonData;
  return 'IconButtonData(glyph: ${_this.glyph}, onPressed: ${_this.onPressed}, tooltip: ${_this.tooltip}, isLoading: ${_this.isLoading})';
}


}

/// @nodoc
abstract mixin class $IconButtonDataCopyWith<$Res>  {
  factory $IconButtonDataCopyWith(IconButtonData value, $Res Function(IconButtonData) _then) = _$IconButtonDataCopyWithImpl;
@useResult
$Res call({
 Glyph glyph, VoidCallback? onPressed, String? tooltip, bool isLoading
});




}
/// @nodoc
class _$IconButtonDataCopyWithImpl<$Res>
    implements $IconButtonDataCopyWith<$Res> {
  _$IconButtonDataCopyWithImpl(this._self, this._then);

  final IconButtonData _self;
  final $Res Function(IconButtonData) _then;

/// Create a copy of IconButtonData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? glyph = null,Object? onPressed = freezed,Object? tooltip = freezed,Object? isLoading = null,}) {
  return _then(IconButtonData(
glyph: null == glyph ? _self.glyph : glyph // ignore: cast_nullable_to_non_nullable
as Glyph,onPressed: freezed == onPressed ? _self.onPressed : onPressed // ignore: cast_nullable_to_non_nullable
as VoidCallback?,tooltip: freezed == tooltip ? _self.tooltip : tooltip // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [IconButtonData].
extension IconButtonDataPatterns on IconButtonData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IconButtonData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IconButtonData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IconButtonData value)  $default,){
final _that = this;
switch (_that) {
case _IconButtonData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IconButtonData value)?  $default,){
final _that = this;
switch (_that) {
case _IconButtonData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Glyph glyph,  VoidCallback? onPressed,  String? tooltip,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IconButtonData() when $default != null:
return $default(_that.glyph,_that.onPressed,_that.tooltip,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Glyph glyph,  VoidCallback? onPressed,  String? tooltip,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _IconButtonData():
return $default(_that.glyph,_that.onPressed,_that.tooltip,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Glyph glyph,  VoidCallback? onPressed,  String? tooltip,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _IconButtonData() when $default != null:
return $default(_that.glyph,_that.onPressed,_that.tooltip,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _IconButtonData implements IconButtonData {
  const _IconButtonData({required this.glyph, required this.onPressed, this.tooltip, this.isLoading = false});
  

@override final  Glyph glyph;
@override final  VoidCallback? onPressed;
@override final  String? tooltip;
@override@JsonKey() final  bool isLoading;

/// Create a copy of IconButtonData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IconButtonDataCopyWith<_IconButtonData> get copyWith => __$IconButtonDataCopyWithImpl<_IconButtonData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IconButtonData&&(identical(other.glyph, glyph) || other.glyph == glyph)&&(identical(other.onPressed, onPressed) || other.onPressed == onPressed)&&(identical(other.tooltip, tooltip) || other.tooltip == tooltip)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode {
    return Object.hash(runtimeType,glyph,onPressed,tooltip,isLoading);
}

@override
String toString() {
    return 'IconButtonData(glyph: $glyph, onPressed: $onPressed, tooltip: $tooltip, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$IconButtonDataCopyWith<$Res> implements $IconButtonDataCopyWith<$Res> {
  factory _$IconButtonDataCopyWith(_IconButtonData value, $Res Function(_IconButtonData) _then) = __$IconButtonDataCopyWithImpl;
@override @useResult
$Res call({
 Glyph glyph, VoidCallback? onPressed, String? tooltip, bool isLoading
});




}
/// @nodoc
class __$IconButtonDataCopyWithImpl<$Res>
    implements _$IconButtonDataCopyWith<$Res> {
  __$IconButtonDataCopyWithImpl(this._self, this._then);

  final _IconButtonData _self;
  final $Res Function(_IconButtonData) _then;

/// Create a copy of IconButtonData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? glyph = null,Object? onPressed = freezed,Object? tooltip = freezed,Object? isLoading = null,}) {
  return _then(_IconButtonData(
glyph: null == glyph ? _self.glyph : glyph // ignore: cast_nullable_to_non_nullable
as Glyph,onPressed: freezed == onPressed ? _self.onPressed : onPressed // ignore: cast_nullable_to_non_nullable
as VoidCallback?,tooltip: freezed == tooltip ? _self.tooltip : tooltip // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
