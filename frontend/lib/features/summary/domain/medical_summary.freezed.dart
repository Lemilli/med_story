// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medical_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MedicalSummary {

 String get id;@JsonKey(name: 'subject_id') String get subjectId; int get version;@JsonKey(name: 'is_current') bool get isCurrent; Map<String, dynamic> get content;@JsonKey(name: 'narrative_text') String get narrativeText; String get language;@JsonKey(name: 'generated_from_event_count') int get generatedFromEventCount;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of MedicalSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicalSummaryCopyWith<MedicalSummary> get copyWith => _$MedicalSummaryCopyWithImpl<MedicalSummary>(this as MedicalSummary, _$identity);

  /// Serializes this MedicalSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicalSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.version, version) || other.version == version)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&const DeepCollectionEquality().equals(other.content, content)&&(identical(other.narrativeText, narrativeText) || other.narrativeText == narrativeText)&&(identical(other.language, language) || other.language == language)&&(identical(other.generatedFromEventCount, generatedFromEventCount) || other.generatedFromEventCount == generatedFromEventCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subjectId,version,isCurrent,const DeepCollectionEquality().hash(content),narrativeText,language,generatedFromEventCount,createdAt);

@override
String toString() {
  return 'MedicalSummary(id: $id, subjectId: $subjectId, version: $version, isCurrent: $isCurrent, content: $content, narrativeText: $narrativeText, language: $language, generatedFromEventCount: $generatedFromEventCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MedicalSummaryCopyWith<$Res>  {
  factory $MedicalSummaryCopyWith(MedicalSummary value, $Res Function(MedicalSummary) _then) = _$MedicalSummaryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'subject_id') String subjectId, int version,@JsonKey(name: 'is_current') bool isCurrent, Map<String, dynamic> content,@JsonKey(name: 'narrative_text') String narrativeText, String language,@JsonKey(name: 'generated_from_event_count') int generatedFromEventCount,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$MedicalSummaryCopyWithImpl<$Res>
    implements $MedicalSummaryCopyWith<$Res> {
  _$MedicalSummaryCopyWithImpl(this._self, this._then);

  final MedicalSummary _self;
  final $Res Function(MedicalSummary) _then;

/// Create a copy of MedicalSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? subjectId = null,Object? version = null,Object? isCurrent = null,Object? content = null,Object? narrativeText = null,Object? language = null,Object? generatedFromEventCount = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,narrativeText: null == narrativeText ? _self.narrativeText : narrativeText // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,generatedFromEventCount: null == generatedFromEventCount ? _self.generatedFromEventCount : generatedFromEventCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicalSummary].
extension MedicalSummaryPatterns on MedicalSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicalSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicalSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicalSummary value)  $default,){
final _that = this;
switch (_that) {
case _MedicalSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicalSummary value)?  $default,){
final _that = this;
switch (_that) {
case _MedicalSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'subject_id')  String subjectId,  int version, @JsonKey(name: 'is_current')  bool isCurrent,  Map<String, dynamic> content, @JsonKey(name: 'narrative_text')  String narrativeText,  String language, @JsonKey(name: 'generated_from_event_count')  int generatedFromEventCount, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicalSummary() when $default != null:
return $default(_that.id,_that.subjectId,_that.version,_that.isCurrent,_that.content,_that.narrativeText,_that.language,_that.generatedFromEventCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'subject_id')  String subjectId,  int version, @JsonKey(name: 'is_current')  bool isCurrent,  Map<String, dynamic> content, @JsonKey(name: 'narrative_text')  String narrativeText,  String language, @JsonKey(name: 'generated_from_event_count')  int generatedFromEventCount, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _MedicalSummary():
return $default(_that.id,_that.subjectId,_that.version,_that.isCurrent,_that.content,_that.narrativeText,_that.language,_that.generatedFromEventCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'subject_id')  String subjectId,  int version, @JsonKey(name: 'is_current')  bool isCurrent,  Map<String, dynamic> content, @JsonKey(name: 'narrative_text')  String narrativeText,  String language, @JsonKey(name: 'generated_from_event_count')  int generatedFromEventCount, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MedicalSummary() when $default != null:
return $default(_that.id,_that.subjectId,_that.version,_that.isCurrent,_that.content,_that.narrativeText,_that.language,_that.generatedFromEventCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MedicalSummary implements MedicalSummary {
  const _MedicalSummary({required this.id, @JsonKey(name: 'subject_id') required this.subjectId, required this.version, @JsonKey(name: 'is_current') this.isCurrent = false, final  Map<String, dynamic> content = const <String, dynamic>{}, @JsonKey(name: 'narrative_text') this.narrativeText = '', this.language = '', @JsonKey(name: 'generated_from_event_count') this.generatedFromEventCount = 0, @JsonKey(name: 'created_at') this.createdAt}): _content = content;
  factory _MedicalSummary.fromJson(Map<String, dynamic> json) => _$MedicalSummaryFromJson(json);

@override final  String id;
@override@JsonKey(name: 'subject_id') final  String subjectId;
@override final  int version;
@override@JsonKey(name: 'is_current') final  bool isCurrent;
 final  Map<String, dynamic> _content;
@override@JsonKey() Map<String, dynamic> get content {
  if (_content is EqualUnmodifiableMapView) return _content;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_content);
}

@override@JsonKey(name: 'narrative_text') final  String narrativeText;
@override@JsonKey() final  String language;
@override@JsonKey(name: 'generated_from_event_count') final  int generatedFromEventCount;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of MedicalSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicalSummaryCopyWith<_MedicalSummary> get copyWith => __$MedicalSummaryCopyWithImpl<_MedicalSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MedicalSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicalSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.version, version) || other.version == version)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&const DeepCollectionEquality().equals(other._content, _content)&&(identical(other.narrativeText, narrativeText) || other.narrativeText == narrativeText)&&(identical(other.language, language) || other.language == language)&&(identical(other.generatedFromEventCount, generatedFromEventCount) || other.generatedFromEventCount == generatedFromEventCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subjectId,version,isCurrent,const DeepCollectionEquality().hash(_content),narrativeText,language,generatedFromEventCount,createdAt);

@override
String toString() {
  return 'MedicalSummary(id: $id, subjectId: $subjectId, version: $version, isCurrent: $isCurrent, content: $content, narrativeText: $narrativeText, language: $language, generatedFromEventCount: $generatedFromEventCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MedicalSummaryCopyWith<$Res> implements $MedicalSummaryCopyWith<$Res> {
  factory _$MedicalSummaryCopyWith(_MedicalSummary value, $Res Function(_MedicalSummary) _then) = __$MedicalSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'subject_id') String subjectId, int version,@JsonKey(name: 'is_current') bool isCurrent, Map<String, dynamic> content,@JsonKey(name: 'narrative_text') String narrativeText, String language,@JsonKey(name: 'generated_from_event_count') int generatedFromEventCount,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$MedicalSummaryCopyWithImpl<$Res>
    implements _$MedicalSummaryCopyWith<$Res> {
  __$MedicalSummaryCopyWithImpl(this._self, this._then);

  final _MedicalSummary _self;
  final $Res Function(_MedicalSummary) _then;

/// Create a copy of MedicalSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? subjectId = null,Object? version = null,Object? isCurrent = null,Object? content = null,Object? narrativeText = null,Object? language = null,Object? generatedFromEventCount = null,Object? createdAt = freezed,}) {
  return _then(_MedicalSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,content: null == content ? _self._content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,narrativeText: null == narrativeText ? _self.narrativeText : narrativeText // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,generatedFromEventCount: null == generatedFromEventCount ? _self.generatedFromEventCount : generatedFromEventCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SummaryRegenerateResult {

@JsonKey(name: 'job_id') String get jobId; String get status;
/// Create a copy of SummaryRegenerateResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummaryRegenerateResultCopyWith<SummaryRegenerateResult> get copyWith => _$SummaryRegenerateResultCopyWithImpl<SummaryRegenerateResult>(this as SummaryRegenerateResult, _$identity);

  /// Serializes this SummaryRegenerateResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SummaryRegenerateResult&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,status);

@override
String toString() {
  return 'SummaryRegenerateResult(jobId: $jobId, status: $status)';
}


}

/// @nodoc
abstract mixin class $SummaryRegenerateResultCopyWith<$Res>  {
  factory $SummaryRegenerateResultCopyWith(SummaryRegenerateResult value, $Res Function(SummaryRegenerateResult) _then) = _$SummaryRegenerateResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'job_id') String jobId, String status
});




}
/// @nodoc
class _$SummaryRegenerateResultCopyWithImpl<$Res>
    implements $SummaryRegenerateResultCopyWith<$Res> {
  _$SummaryRegenerateResultCopyWithImpl(this._self, this._then);

  final SummaryRegenerateResult _self;
  final $Res Function(SummaryRegenerateResult) _then;

/// Create a copy of SummaryRegenerateResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobId = null,Object? status = null,}) {
  return _then(_self.copyWith(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SummaryRegenerateResult].
extension SummaryRegenerateResultPatterns on SummaryRegenerateResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SummaryRegenerateResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SummaryRegenerateResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SummaryRegenerateResult value)  $default,){
final _that = this;
switch (_that) {
case _SummaryRegenerateResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SummaryRegenerateResult value)?  $default,){
final _that = this;
switch (_that) {
case _SummaryRegenerateResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'job_id')  String jobId,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SummaryRegenerateResult() when $default != null:
return $default(_that.jobId,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'job_id')  String jobId,  String status)  $default,) {final _that = this;
switch (_that) {
case _SummaryRegenerateResult():
return $default(_that.jobId,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'job_id')  String jobId,  String status)?  $default,) {final _that = this;
switch (_that) {
case _SummaryRegenerateResult() when $default != null:
return $default(_that.jobId,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SummaryRegenerateResult implements SummaryRegenerateResult {
  const _SummaryRegenerateResult({@JsonKey(name: 'job_id') required this.jobId, this.status = ''});
  factory _SummaryRegenerateResult.fromJson(Map<String, dynamic> json) => _$SummaryRegenerateResultFromJson(json);

@override@JsonKey(name: 'job_id') final  String jobId;
@override@JsonKey() final  String status;

/// Create a copy of SummaryRegenerateResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SummaryRegenerateResultCopyWith<_SummaryRegenerateResult> get copyWith => __$SummaryRegenerateResultCopyWithImpl<_SummaryRegenerateResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SummaryRegenerateResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SummaryRegenerateResult&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jobId,status);

@override
String toString() {
  return 'SummaryRegenerateResult(jobId: $jobId, status: $status)';
}


}

/// @nodoc
abstract mixin class _$SummaryRegenerateResultCopyWith<$Res> implements $SummaryRegenerateResultCopyWith<$Res> {
  factory _$SummaryRegenerateResultCopyWith(_SummaryRegenerateResult value, $Res Function(_SummaryRegenerateResult) _then) = __$SummaryRegenerateResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'job_id') String jobId, String status
});




}
/// @nodoc
class __$SummaryRegenerateResultCopyWithImpl<$Res>
    implements _$SummaryRegenerateResultCopyWith<$Res> {
  __$SummaryRegenerateResultCopyWithImpl(this._self, this._then);

  final _SummaryRegenerateResult _self;
  final $Res Function(_SummaryRegenerateResult) _then;

/// Create a copy of SummaryRegenerateResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobId = null,Object? status = null,}) {
  return _then(_SummaryRegenerateResult(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
