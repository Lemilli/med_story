// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimelineFilters {

 Set<MedicalEventType> get types; DateTime? get from; DateTime? get to; String get tag; String get query; bool? get confirmed;
/// Create a copy of TimelineFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineFiltersCopyWith<TimelineFilters> get copyWith => _$TimelineFiltersCopyWithImpl<TimelineFilters>(this as TimelineFilters, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineFilters&&const DeepCollectionEquality().equals(other.types, types)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.query, query) || other.query == query)&&(identical(other.confirmed, confirmed) || other.confirmed == confirmed));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(types),from,to,tag,query,confirmed);

@override
String toString() {
  return 'TimelineFilters(types: $types, from: $from, to: $to, tag: $tag, query: $query, confirmed: $confirmed)';
}


}

/// @nodoc
abstract mixin class $TimelineFiltersCopyWith<$Res>  {
  factory $TimelineFiltersCopyWith(TimelineFilters value, $Res Function(TimelineFilters) _then) = _$TimelineFiltersCopyWithImpl;
@useResult
$Res call({
 Set<MedicalEventType> types, DateTime? from, DateTime? to, String tag, String query, bool? confirmed
});




}
/// @nodoc
class _$TimelineFiltersCopyWithImpl<$Res>
    implements $TimelineFiltersCopyWith<$Res> {
  _$TimelineFiltersCopyWithImpl(this._self, this._then);

  final TimelineFilters _self;
  final $Res Function(TimelineFilters) _then;

/// Create a copy of TimelineFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? types = null,Object? from = freezed,Object? to = freezed,Object? tag = null,Object? query = null,Object? confirmed = freezed,}) {
  return _then(_self.copyWith(
types: null == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as Set<MedicalEventType>,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,confirmed: freezed == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [TimelineFilters].
extension TimelineFiltersPatterns on TimelineFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimelineFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimelineFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimelineFilters value)  $default,){
final _that = this;
switch (_that) {
case _TimelineFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimelineFilters value)?  $default,){
final _that = this;
switch (_that) {
case _TimelineFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<MedicalEventType> types,  DateTime? from,  DateTime? to,  String tag,  String query,  bool? confirmed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimelineFilters() when $default != null:
return $default(_that.types,_that.from,_that.to,_that.tag,_that.query,_that.confirmed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<MedicalEventType> types,  DateTime? from,  DateTime? to,  String tag,  String query,  bool? confirmed)  $default,) {final _that = this;
switch (_that) {
case _TimelineFilters():
return $default(_that.types,_that.from,_that.to,_that.tag,_that.query,_that.confirmed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<MedicalEventType> types,  DateTime? from,  DateTime? to,  String tag,  String query,  bool? confirmed)?  $default,) {final _that = this;
switch (_that) {
case _TimelineFilters() when $default != null:
return $default(_that.types,_that.from,_that.to,_that.tag,_that.query,_that.confirmed);case _:
  return null;

}
}

}

/// @nodoc


class _TimelineFilters implements TimelineFilters {
  const _TimelineFilters({final  Set<MedicalEventType> types = const <MedicalEventType>{}, this.from, this.to, this.tag = '', this.query = '', this.confirmed}): _types = types;
  

 final  Set<MedicalEventType> _types;
@override@JsonKey() Set<MedicalEventType> get types {
  if (_types is EqualUnmodifiableSetView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_types);
}

@override final  DateTime? from;
@override final  DateTime? to;
@override@JsonKey() final  String tag;
@override@JsonKey() final  String query;
@override final  bool? confirmed;

/// Create a copy of TimelineFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimelineFiltersCopyWith<_TimelineFilters> get copyWith => __$TimelineFiltersCopyWithImpl<_TimelineFilters>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimelineFilters&&const DeepCollectionEquality().equals(other._types, _types)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.query, query) || other.query == query)&&(identical(other.confirmed, confirmed) || other.confirmed == confirmed));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_types),from,to,tag,query,confirmed);

@override
String toString() {
  return 'TimelineFilters(types: $types, from: $from, to: $to, tag: $tag, query: $query, confirmed: $confirmed)';
}


}

/// @nodoc
abstract mixin class _$TimelineFiltersCopyWith<$Res> implements $TimelineFiltersCopyWith<$Res> {
  factory _$TimelineFiltersCopyWith(_TimelineFilters value, $Res Function(_TimelineFilters) _then) = __$TimelineFiltersCopyWithImpl;
@override @useResult
$Res call({
 Set<MedicalEventType> types, DateTime? from, DateTime? to, String tag, String query, bool? confirmed
});




}
/// @nodoc
class __$TimelineFiltersCopyWithImpl<$Res>
    implements _$TimelineFiltersCopyWith<$Res> {
  __$TimelineFiltersCopyWithImpl(this._self, this._then);

  final _TimelineFilters _self;
  final $Res Function(_TimelineFilters) _then;

/// Create a copy of TimelineFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? types = null,Object? from = freezed,Object? to = freezed,Object? tag = null,Object? query = null,Object? confirmed = freezed,}) {
  return _then(_TimelineFilters(
types: null == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as Set<MedicalEventType>,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,confirmed: freezed == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
