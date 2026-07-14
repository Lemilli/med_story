// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medical_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MedicalEvent {

 String get id;@JsonKey(name: 'event_type') MedicalEventType get eventType; String get title; String get description;@JsonKey(name: 'event_date') String get eventDate;@JsonKey(name: 'event_end_date') String? get eventEndDate; Map<String, dynamic> get attributes; EventSource get source;@JsonKey(name: 'source_document_id') String? get sourceDocumentId;@JsonKey(name: 'source_text') String? get sourceText;@JsonKey(name: 'source_asset_count') int get sourceAssetCount;@JsonKey(name: 'pending_revision') EventRevision? get pendingRevision; double? get confidence; List<String> get tags;@JsonKey(name: 'subject_id') String get subjectId;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of MedicalEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicalEventCopyWith<MedicalEvent> get copyWith => _$MedicalEventCopyWithImpl<MedicalEvent>(this as MedicalEvent, _$identity);

  /// Serializes this MedicalEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicalEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.eventEndDate, eventEndDate) || other.eventEndDate == eventEndDate)&&const DeepCollectionEquality().equals(other.attributes, attributes)&&(identical(other.source, source) || other.source == source)&&(identical(other.sourceDocumentId, sourceDocumentId) || other.sourceDocumentId == sourceDocumentId)&&(identical(other.sourceText, sourceText) || other.sourceText == sourceText)&&(identical(other.sourceAssetCount, sourceAssetCount) || other.sourceAssetCount == sourceAssetCount)&&(identical(other.pendingRevision, pendingRevision) || other.pendingRevision == pendingRevision)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventType,title,description,eventDate,eventEndDate,const DeepCollectionEquality().hash(attributes),source,sourceDocumentId,sourceText,sourceAssetCount,pendingRevision,confidence,const DeepCollectionEquality().hash(tags),subjectId,createdAt,updatedAt);

@override
String toString() {
  return 'MedicalEvent(id: $id, eventType: $eventType, title: $title, description: $description, eventDate: $eventDate, eventEndDate: $eventEndDate, attributes: $attributes, source: $source, sourceDocumentId: $sourceDocumentId, sourceText: $sourceText, sourceAssetCount: $sourceAssetCount, pendingRevision: $pendingRevision, confidence: $confidence, tags: $tags, subjectId: $subjectId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MedicalEventCopyWith<$Res>  {
  factory $MedicalEventCopyWith(MedicalEvent value, $Res Function(MedicalEvent) _then) = _$MedicalEventCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'event_type') MedicalEventType eventType, String title, String description,@JsonKey(name: 'event_date') String eventDate,@JsonKey(name: 'event_end_date') String? eventEndDate, Map<String, dynamic> attributes, EventSource source,@JsonKey(name: 'source_document_id') String? sourceDocumentId,@JsonKey(name: 'source_text') String? sourceText,@JsonKey(name: 'source_asset_count') int sourceAssetCount,@JsonKey(name: 'pending_revision') EventRevision? pendingRevision, double? confidence, List<String> tags,@JsonKey(name: 'subject_id') String subjectId,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});


$EventRevisionCopyWith<$Res>? get pendingRevision;

}
/// @nodoc
class _$MedicalEventCopyWithImpl<$Res>
    implements $MedicalEventCopyWith<$Res> {
  _$MedicalEventCopyWithImpl(this._self, this._then);

  final MedicalEvent _self;
  final $Res Function(MedicalEvent) _then;

/// Create a copy of MedicalEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventType = null,Object? title = null,Object? description = null,Object? eventDate = null,Object? eventEndDate = freezed,Object? attributes = null,Object? source = null,Object? sourceDocumentId = freezed,Object? sourceText = freezed,Object? sourceAssetCount = null,Object? pendingRevision = freezed,Object? confidence = freezed,Object? tags = null,Object? subjectId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as MedicalEventType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,eventDate: null == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as String,eventEndDate: freezed == eventEndDate ? _self.eventEndDate : eventEndDate // ignore: cast_nullable_to_non_nullable
as String?,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as EventSource,sourceDocumentId: freezed == sourceDocumentId ? _self.sourceDocumentId : sourceDocumentId // ignore: cast_nullable_to_non_nullable
as String?,sourceText: freezed == sourceText ? _self.sourceText : sourceText // ignore: cast_nullable_to_non_nullable
as String?,sourceAssetCount: null == sourceAssetCount ? _self.sourceAssetCount : sourceAssetCount // ignore: cast_nullable_to_non_nullable
as int,pendingRevision: freezed == pendingRevision ? _self.pendingRevision : pendingRevision // ignore: cast_nullable_to_non_nullable
as EventRevision?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of MedicalEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventRevisionCopyWith<$Res>? get pendingRevision {
    if (_self.pendingRevision == null) {
    return null;
  }

  return $EventRevisionCopyWith<$Res>(_self.pendingRevision!, (value) {
    return _then(_self.copyWith(pendingRevision: value));
  });
}
}


/// Adds pattern-matching-related methods to [MedicalEvent].
extension MedicalEventPatterns on MedicalEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicalEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicalEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicalEvent value)  $default,){
final _that = this;
switch (_that) {
case _MedicalEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicalEvent value)?  $default,){
final _that = this;
switch (_that) {
case _MedicalEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_type')  MedicalEventType eventType,  String title,  String description, @JsonKey(name: 'event_date')  String eventDate, @JsonKey(name: 'event_end_date')  String? eventEndDate,  Map<String, dynamic> attributes,  EventSource source, @JsonKey(name: 'source_document_id')  String? sourceDocumentId, @JsonKey(name: 'source_text')  String? sourceText, @JsonKey(name: 'source_asset_count')  int sourceAssetCount, @JsonKey(name: 'pending_revision')  EventRevision? pendingRevision,  double? confidence,  List<String> tags, @JsonKey(name: 'subject_id')  String subjectId, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicalEvent() when $default != null:
return $default(_that.id,_that.eventType,_that.title,_that.description,_that.eventDate,_that.eventEndDate,_that.attributes,_that.source,_that.sourceDocumentId,_that.sourceText,_that.sourceAssetCount,_that.pendingRevision,_that.confidence,_that.tags,_that.subjectId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_type')  MedicalEventType eventType,  String title,  String description, @JsonKey(name: 'event_date')  String eventDate, @JsonKey(name: 'event_end_date')  String? eventEndDate,  Map<String, dynamic> attributes,  EventSource source, @JsonKey(name: 'source_document_id')  String? sourceDocumentId, @JsonKey(name: 'source_text')  String? sourceText, @JsonKey(name: 'source_asset_count')  int sourceAssetCount, @JsonKey(name: 'pending_revision')  EventRevision? pendingRevision,  double? confidence,  List<String> tags, @JsonKey(name: 'subject_id')  String subjectId, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MedicalEvent():
return $default(_that.id,_that.eventType,_that.title,_that.description,_that.eventDate,_that.eventEndDate,_that.attributes,_that.source,_that.sourceDocumentId,_that.sourceText,_that.sourceAssetCount,_that.pendingRevision,_that.confidence,_that.tags,_that.subjectId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'event_type')  MedicalEventType eventType,  String title,  String description, @JsonKey(name: 'event_date')  String eventDate, @JsonKey(name: 'event_end_date')  String? eventEndDate,  Map<String, dynamic> attributes,  EventSource source, @JsonKey(name: 'source_document_id')  String? sourceDocumentId, @JsonKey(name: 'source_text')  String? sourceText, @JsonKey(name: 'source_asset_count')  int sourceAssetCount, @JsonKey(name: 'pending_revision')  EventRevision? pendingRevision,  double? confidence,  List<String> tags, @JsonKey(name: 'subject_id')  String subjectId, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MedicalEvent() when $default != null:
return $default(_that.id,_that.eventType,_that.title,_that.description,_that.eventDate,_that.eventEndDate,_that.attributes,_that.source,_that.sourceDocumentId,_that.sourceText,_that.sourceAssetCount,_that.pendingRevision,_that.confidence,_that.tags,_that.subjectId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MedicalEvent implements MedicalEvent {
  const _MedicalEvent({required this.id, @JsonKey(name: 'event_type') required this.eventType, required this.title, this.description = '', @JsonKey(name: 'event_date') required this.eventDate, @JsonKey(name: 'event_end_date') this.eventEndDate, final  Map<String, dynamic> attributes = const <String, dynamic>{}, this.source = EventSource.userManual, @JsonKey(name: 'source_document_id') this.sourceDocumentId, @JsonKey(name: 'source_text') this.sourceText, @JsonKey(name: 'source_asset_count') this.sourceAssetCount = 0, @JsonKey(name: 'pending_revision') this.pendingRevision, this.confidence, final  List<String> tags = const <String>[], @JsonKey(name: 'subject_id') required this.subjectId, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): _attributes = attributes,_tags = tags;
  factory _MedicalEvent.fromJson(Map<String, dynamic> json) => _$MedicalEventFromJson(json);

@override final  String id;
@override@JsonKey(name: 'event_type') final  MedicalEventType eventType;
@override final  String title;
@override@JsonKey() final  String description;
@override@JsonKey(name: 'event_date') final  String eventDate;
@override@JsonKey(name: 'event_end_date') final  String? eventEndDate;
 final  Map<String, dynamic> _attributes;
@override@JsonKey() Map<String, dynamic> get attributes {
  if (_attributes is EqualUnmodifiableMapView) return _attributes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_attributes);
}

@override@JsonKey() final  EventSource source;
@override@JsonKey(name: 'source_document_id') final  String? sourceDocumentId;
@override@JsonKey(name: 'source_text') final  String? sourceText;
@override@JsonKey(name: 'source_asset_count') final  int sourceAssetCount;
@override@JsonKey(name: 'pending_revision') final  EventRevision? pendingRevision;
@override final  double? confidence;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey(name: 'subject_id') final  String subjectId;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of MedicalEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicalEventCopyWith<_MedicalEvent> get copyWith => __$MedicalEventCopyWithImpl<_MedicalEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MedicalEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicalEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.eventEndDate, eventEndDate) || other.eventEndDate == eventEndDate)&&const DeepCollectionEquality().equals(other._attributes, _attributes)&&(identical(other.source, source) || other.source == source)&&(identical(other.sourceDocumentId, sourceDocumentId) || other.sourceDocumentId == sourceDocumentId)&&(identical(other.sourceText, sourceText) || other.sourceText == sourceText)&&(identical(other.sourceAssetCount, sourceAssetCount) || other.sourceAssetCount == sourceAssetCount)&&(identical(other.pendingRevision, pendingRevision) || other.pendingRevision == pendingRevision)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventType,title,description,eventDate,eventEndDate,const DeepCollectionEquality().hash(_attributes),source,sourceDocumentId,sourceText,sourceAssetCount,pendingRevision,confidence,const DeepCollectionEquality().hash(_tags),subjectId,createdAt,updatedAt);

@override
String toString() {
  return 'MedicalEvent(id: $id, eventType: $eventType, title: $title, description: $description, eventDate: $eventDate, eventEndDate: $eventEndDate, attributes: $attributes, source: $source, sourceDocumentId: $sourceDocumentId, sourceText: $sourceText, sourceAssetCount: $sourceAssetCount, pendingRevision: $pendingRevision, confidence: $confidence, tags: $tags, subjectId: $subjectId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MedicalEventCopyWith<$Res> implements $MedicalEventCopyWith<$Res> {
  factory _$MedicalEventCopyWith(_MedicalEvent value, $Res Function(_MedicalEvent) _then) = __$MedicalEventCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'event_type') MedicalEventType eventType, String title, String description,@JsonKey(name: 'event_date') String eventDate,@JsonKey(name: 'event_end_date') String? eventEndDate, Map<String, dynamic> attributes, EventSource source,@JsonKey(name: 'source_document_id') String? sourceDocumentId,@JsonKey(name: 'source_text') String? sourceText,@JsonKey(name: 'source_asset_count') int sourceAssetCount,@JsonKey(name: 'pending_revision') EventRevision? pendingRevision, double? confidence, List<String> tags,@JsonKey(name: 'subject_id') String subjectId,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});


@override $EventRevisionCopyWith<$Res>? get pendingRevision;

}
/// @nodoc
class __$MedicalEventCopyWithImpl<$Res>
    implements _$MedicalEventCopyWith<$Res> {
  __$MedicalEventCopyWithImpl(this._self, this._then);

  final _MedicalEvent _self;
  final $Res Function(_MedicalEvent) _then;

/// Create a copy of MedicalEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventType = null,Object? title = null,Object? description = null,Object? eventDate = null,Object? eventEndDate = freezed,Object? attributes = null,Object? source = null,Object? sourceDocumentId = freezed,Object? sourceText = freezed,Object? sourceAssetCount = null,Object? pendingRevision = freezed,Object? confidence = freezed,Object? tags = null,Object? subjectId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_MedicalEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as MedicalEventType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,eventDate: null == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as String,eventEndDate: freezed == eventEndDate ? _self.eventEndDate : eventEndDate // ignore: cast_nullable_to_non_nullable
as String?,attributes: null == attributes ? _self._attributes : attributes // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as EventSource,sourceDocumentId: freezed == sourceDocumentId ? _self.sourceDocumentId : sourceDocumentId // ignore: cast_nullable_to_non_nullable
as String?,sourceText: freezed == sourceText ? _self.sourceText : sourceText // ignore: cast_nullable_to_non_nullable
as String?,sourceAssetCount: null == sourceAssetCount ? _self.sourceAssetCount : sourceAssetCount // ignore: cast_nullable_to_non_nullable
as int,pendingRevision: freezed == pendingRevision ? _self.pendingRevision : pendingRevision // ignore: cast_nullable_to_non_nullable
as EventRevision?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of MedicalEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventRevisionCopyWith<$Res>? get pendingRevision {
    if (_self.pendingRevision == null) {
    return null;
  }

  return $EventRevisionCopyWith<$Res>(_self.pendingRevision!, (value) {
    return _then(_self.copyWith(pendingRevision: value));
  });
}
}


/// @nodoc
mixin _$EventRevision {

 String get id;@JsonKey(name: 'current_snapshot') Map<String, dynamic> get currentSnapshot;@JsonKey(name: 'suggested_changes') Map<String, dynamic> get suggestedChanges; String get status;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'resolved_at') DateTime? get resolvedAt;
/// Create a copy of EventRevision
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventRevisionCopyWith<EventRevision> get copyWith => _$EventRevisionCopyWithImpl<EventRevision>(this as EventRevision, _$identity);

  /// Serializes this EventRevision to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventRevision&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.currentSnapshot, currentSnapshot)&&const DeepCollectionEquality().equals(other.suggestedChanges, suggestedChanges)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(currentSnapshot),const DeepCollectionEquality().hash(suggestedChanges),status,createdAt,resolvedAt);

@override
String toString() {
  return 'EventRevision(id: $id, currentSnapshot: $currentSnapshot, suggestedChanges: $suggestedChanges, status: $status, createdAt: $createdAt, resolvedAt: $resolvedAt)';
}


}

/// @nodoc
abstract mixin class $EventRevisionCopyWith<$Res>  {
  factory $EventRevisionCopyWith(EventRevision value, $Res Function(EventRevision) _then) = _$EventRevisionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'current_snapshot') Map<String, dynamic> currentSnapshot,@JsonKey(name: 'suggested_changes') Map<String, dynamic> suggestedChanges, String status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'resolved_at') DateTime? resolvedAt
});




}
/// @nodoc
class _$EventRevisionCopyWithImpl<$Res>
    implements $EventRevisionCopyWith<$Res> {
  _$EventRevisionCopyWithImpl(this._self, this._then);

  final EventRevision _self;
  final $Res Function(EventRevision) _then;

/// Create a copy of EventRevision
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? currentSnapshot = null,Object? suggestedChanges = null,Object? status = null,Object? createdAt = freezed,Object? resolvedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,currentSnapshot: null == currentSnapshot ? _self.currentSnapshot : currentSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,suggestedChanges: null == suggestedChanges ? _self.suggestedChanges : suggestedChanges // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventRevision].
extension EventRevisionPatterns on EventRevision {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventRevision value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventRevision() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventRevision value)  $default,){
final _that = this;
switch (_that) {
case _EventRevision():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventRevision value)?  $default,){
final _that = this;
switch (_that) {
case _EventRevision() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'current_snapshot')  Map<String, dynamic> currentSnapshot, @JsonKey(name: 'suggested_changes')  Map<String, dynamic> suggestedChanges,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'resolved_at')  DateTime? resolvedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventRevision() when $default != null:
return $default(_that.id,_that.currentSnapshot,_that.suggestedChanges,_that.status,_that.createdAt,_that.resolvedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'current_snapshot')  Map<String, dynamic> currentSnapshot, @JsonKey(name: 'suggested_changes')  Map<String, dynamic> suggestedChanges,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'resolved_at')  DateTime? resolvedAt)  $default,) {final _that = this;
switch (_that) {
case _EventRevision():
return $default(_that.id,_that.currentSnapshot,_that.suggestedChanges,_that.status,_that.createdAt,_that.resolvedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'current_snapshot')  Map<String, dynamic> currentSnapshot, @JsonKey(name: 'suggested_changes')  Map<String, dynamic> suggestedChanges,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'resolved_at')  DateTime? resolvedAt)?  $default,) {final _that = this;
switch (_that) {
case _EventRevision() when $default != null:
return $default(_that.id,_that.currentSnapshot,_that.suggestedChanges,_that.status,_that.createdAt,_that.resolvedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventRevision implements EventRevision {
  const _EventRevision({required this.id, @JsonKey(name: 'current_snapshot') final  Map<String, dynamic> currentSnapshot = const <String, dynamic>{}, @JsonKey(name: 'suggested_changes') final  Map<String, dynamic> suggestedChanges = const <String, dynamic>{}, this.status = 'pending', @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'resolved_at') this.resolvedAt}): _currentSnapshot = currentSnapshot,_suggestedChanges = suggestedChanges;
  factory _EventRevision.fromJson(Map<String, dynamic> json) => _$EventRevisionFromJson(json);

@override final  String id;
 final  Map<String, dynamic> _currentSnapshot;
@override@JsonKey(name: 'current_snapshot') Map<String, dynamic> get currentSnapshot {
  if (_currentSnapshot is EqualUnmodifiableMapView) return _currentSnapshot;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_currentSnapshot);
}

 final  Map<String, dynamic> _suggestedChanges;
@override@JsonKey(name: 'suggested_changes') Map<String, dynamic> get suggestedChanges {
  if (_suggestedChanges is EqualUnmodifiableMapView) return _suggestedChanges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_suggestedChanges);
}

@override@JsonKey() final  String status;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'resolved_at') final  DateTime? resolvedAt;

/// Create a copy of EventRevision
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventRevisionCopyWith<_EventRevision> get copyWith => __$EventRevisionCopyWithImpl<_EventRevision>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventRevisionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventRevision&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._currentSnapshot, _currentSnapshot)&&const DeepCollectionEquality().equals(other._suggestedChanges, _suggestedChanges)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_currentSnapshot),const DeepCollectionEquality().hash(_suggestedChanges),status,createdAt,resolvedAt);

@override
String toString() {
  return 'EventRevision(id: $id, currentSnapshot: $currentSnapshot, suggestedChanges: $suggestedChanges, status: $status, createdAt: $createdAt, resolvedAt: $resolvedAt)';
}


}

/// @nodoc
abstract mixin class _$EventRevisionCopyWith<$Res> implements $EventRevisionCopyWith<$Res> {
  factory _$EventRevisionCopyWith(_EventRevision value, $Res Function(_EventRevision) _then) = __$EventRevisionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'current_snapshot') Map<String, dynamic> currentSnapshot,@JsonKey(name: 'suggested_changes') Map<String, dynamic> suggestedChanges, String status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'resolved_at') DateTime? resolvedAt
});




}
/// @nodoc
class __$EventRevisionCopyWithImpl<$Res>
    implements _$EventRevisionCopyWith<$Res> {
  __$EventRevisionCopyWithImpl(this._self, this._then);

  final _EventRevision _self;
  final $Res Function(_EventRevision) _then;

/// Create a copy of EventRevision
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? currentSnapshot = null,Object? suggestedChanges = null,Object? status = null,Object? createdAt = freezed,Object? resolvedAt = freezed,}) {
  return _then(_EventRevision(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,currentSnapshot: null == currentSnapshot ? _self._currentSnapshot : currentSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,suggestedChanges: null == suggestedChanges ? _self._suggestedChanges : suggestedChanges // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
