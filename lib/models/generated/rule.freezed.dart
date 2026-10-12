// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RuleSet {

 int get id; String get label; String? get url; DateTime? get lastUpdateDate; List<Map<String, dynamic>> get rules;
/// Create a copy of RuleSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RuleSetCopyWith<RuleSet> get copyWith => _$RuleSetCopyWithImpl<RuleSet>(this as RuleSet, _$identity);

  /// Serializes this RuleSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RuleSet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RuleSet&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.lastUpdateDate, _this.lastUpdateDate) || other.lastUpdateDate == _this.lastUpdateDate)&&const DeepCollectionEquality().equals(other.rules, _this.rules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RuleSet;
  return Object.hash(runtimeType,_this.id,_this.label,_this.url,_this.lastUpdateDate,const DeepCollectionEquality().hash(_this.rules));
}

@override
String toString() {
  final _this = this as RuleSet;
  return 'RuleSet(id: ${_this.id}, label: ${_this.label}, url: ${_this.url}, lastUpdateDate: ${_this.lastUpdateDate}, rules: ${_this.rules})';
}


}

/// @nodoc
abstract mixin class $RuleSetCopyWith<$Res>  {
  factory $RuleSetCopyWith(RuleSet value, $Res Function(RuleSet) _then) = _$RuleSetCopyWithImpl;
@useResult
$Res call({
 int id, String label, String? url, DateTime? lastUpdateDate, List<Map<String, dynamic>> rules
});




}
/// @nodoc
class _$RuleSetCopyWithImpl<$Res>
    implements $RuleSetCopyWith<$Res> {
  _$RuleSetCopyWithImpl(this._self, this._then);

  final RuleSet _self;
  final $Res Function(RuleSet) _then;

/// Create a copy of RuleSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? url = freezed,Object? lastUpdateDate = freezed,Object? rules = null,}) {
  return _then(RuleSet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,lastUpdateDate: freezed == lastUpdateDate ? _self.lastUpdateDate : lastUpdateDate // ignore: cast_nullable_to_non_nullable
as DateTime?,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

}


/// Adds pattern-matching-related methods to [RuleSet].
extension RuleSetPatterns on RuleSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RuleSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RuleSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RuleSet value)  $default,){
final _that = this;
switch (_that) {
case _RuleSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RuleSet value)?  $default,){
final _that = this;
switch (_that) {
case _RuleSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String label,  String? url,  DateTime? lastUpdateDate,  List<Map<String, dynamic>> rules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RuleSet() when $default != null:
return $default(_that.id,_that.label,_that.url,_that.lastUpdateDate,_that.rules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String label,  String? url,  DateTime? lastUpdateDate,  List<Map<String, dynamic>> rules)  $default,) {final _that = this;
switch (_that) {
case _RuleSet():
return $default(_that.id,_that.label,_that.url,_that.lastUpdateDate,_that.rules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String label,  String? url,  DateTime? lastUpdateDate,  List<Map<String, dynamic>> rules)?  $default,) {final _that = this;
switch (_that) {
case _RuleSet() when $default != null:
return $default(_that.id,_that.label,_that.url,_that.lastUpdateDate,_that.rules);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RuleSet implements RuleSet {
  const _RuleSet({required this.id, this.label = '', this.url, this.lastUpdateDate,  List<Map<String, dynamic>> rules = const []}): _rules = rules;
  factory _RuleSet.fromJson(Map<String, dynamic> json) => _$RuleSetFromJson(json);

@override final  int id;
@override@JsonKey() final  String label;
@override final  String? url;
@override final  DateTime? lastUpdateDate;
 final  List<Map<String, dynamic>> _rules;
@override@JsonKey() List<Map<String, dynamic>> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}


/// Create a copy of RuleSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RuleSetCopyWith<_RuleSet> get copyWith => __$RuleSetCopyWithImpl<_RuleSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RuleSetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RuleSet&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url)&&(identical(other.lastUpdateDate, lastUpdateDate) || other.lastUpdateDate == lastUpdateDate)&&const DeepCollectionEquality().equals(other.rules, _rules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,url,lastUpdateDate,const DeepCollectionEquality().hash(_rules));
}

@override
String toString() {
    return 'RuleSet(id: $id, label: $label, url: $url, lastUpdateDate: $lastUpdateDate, rules: $rules)';
}


}

/// @nodoc
abstract mixin class _$RuleSetCopyWith<$Res> implements $RuleSetCopyWith<$Res> {
  factory _$RuleSetCopyWith(_RuleSet value, $Res Function(_RuleSet) _then) = __$RuleSetCopyWithImpl;
@override @useResult
$Res call({
 int id, String label, String? url, DateTime? lastUpdateDate, List<Map<String, dynamic>> rules
});




}
/// @nodoc
class __$RuleSetCopyWithImpl<$Res>
    implements _$RuleSetCopyWith<$Res> {
  __$RuleSetCopyWithImpl(this._self, this._then);

  final _RuleSet _self;
  final $Res Function(_RuleSet) _then;

/// Create a copy of RuleSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? url = freezed,Object? lastUpdateDate = freezed,Object? rules = null,}) {
  return _then(_RuleSet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,lastUpdateDate: freezed == lastUpdateDate ? _self.lastUpdateDate : lastUpdateDate // ignore: cast_nullable_to_non_nullable
as DateTime?,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}


}

// dart format on
