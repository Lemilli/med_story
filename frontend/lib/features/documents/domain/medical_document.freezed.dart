// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medical_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MedicalDocument {

 String get id; String get title;@JsonKey(name: 'doc_type') DocumentType get docType;@JsonKey(name: 'mime_type') String get mimeType;@JsonKey(name: 'local_uri_hint') String get localUriHint;@JsonKey(name: 'size_bytes') int get sizeBytes; DocumentStatus get status;@JsonKey(name: 'subject_id') String? get subjectId;@JsonKey(name: 'document_date') String? get documentDate; String get language;@JsonKey(name: 'local_only') bool get localOnly;@JsonKey(name: 'extracted_text_available') bool get extractedTextAvailable;@JsonKey(name: 'event_count') int get eventCount;@JsonKey(name: 'error_message') String get errorMessage;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of MedicalDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicalDocumentCopyWith<MedicalDocument> get copyWith => _$MedicalDocumentCopyWithImpl<MedicalDocument>(this as MedicalDocument, _$identity);

  /// Serializes this MedicalDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicalDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.docType, docType) || other.docType == docType)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.localUriHint, localUriHint) || other.localUriHint == localUriHint)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.status, status) || other.status == status)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.documentDate, documentDate) || other.documentDate == documentDate)&&(identical(other.language, language) || other.language == language)&&(identical(other.localOnly, localOnly) || other.localOnly == localOnly)&&(identical(other.extractedTextAvailable, extractedTextAvailable) || other.extractedTextAvailable == extractedTextAvailable)&&(identical(other.eventCount, eventCount) || other.eventCount == eventCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,docType,mimeType,localUriHint,sizeBytes,status,subjectId,documentDate,language,localOnly,extractedTextAvailable,eventCount,errorMessage,createdAt,updatedAt);

@override
String toString() {
  return 'MedicalDocument(id: $id, title: $title, docType: $docType, mimeType: $mimeType, localUriHint: $localUriHint, sizeBytes: $sizeBytes, status: $status, subjectId: $subjectId, documentDate: $documentDate, language: $language, localOnly: $localOnly, extractedTextAvailable: $extractedTextAvailable, eventCount: $eventCount, errorMessage: $errorMessage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MedicalDocumentCopyWith<$Res>  {
  factory $MedicalDocumentCopyWith(MedicalDocument value, $Res Function(MedicalDocument) _then) = _$MedicalDocumentCopyWithImpl;
@useResult
$Res call({
 String id, String title,@JsonKey(name: 'doc_type') DocumentType docType,@JsonKey(name: 'mime_type') String mimeType,@JsonKey(name: 'local_uri_hint') String localUriHint,@JsonKey(name: 'size_bytes') int sizeBytes, DocumentStatus status,@JsonKey(name: 'subject_id') String? subjectId,@JsonKey(name: 'document_date') String? documentDate, String language,@JsonKey(name: 'local_only') bool localOnly,@JsonKey(name: 'extracted_text_available') bool extractedTextAvailable,@JsonKey(name: 'event_count') int eventCount,@JsonKey(name: 'error_message') String errorMessage,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$MedicalDocumentCopyWithImpl<$Res>
    implements $MedicalDocumentCopyWith<$Res> {
  _$MedicalDocumentCopyWithImpl(this._self, this._then);

  final MedicalDocument _self;
  final $Res Function(MedicalDocument) _then;

/// Create a copy of MedicalDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? docType = null,Object? mimeType = null,Object? localUriHint = null,Object? sizeBytes = null,Object? status = null,Object? subjectId = freezed,Object? documentDate = freezed,Object? language = null,Object? localOnly = null,Object? extractedTextAvailable = null,Object? eventCount = null,Object? errorMessage = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,docType: null == docType ? _self.docType : docType // ignore: cast_nullable_to_non_nullable
as DocumentType,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,localUriHint: null == localUriHint ? _self.localUriHint : localUriHint // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,subjectId: freezed == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String?,documentDate: freezed == documentDate ? _self.documentDate : documentDate // ignore: cast_nullable_to_non_nullable
as String?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,localOnly: null == localOnly ? _self.localOnly : localOnly // ignore: cast_nullable_to_non_nullable
as bool,extractedTextAvailable: null == extractedTextAvailable ? _self.extractedTextAvailable : extractedTextAvailable // ignore: cast_nullable_to_non_nullable
as bool,eventCount: null == eventCount ? _self.eventCount : eventCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicalDocument].
extension MedicalDocumentPatterns on MedicalDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicalDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicalDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicalDocument value)  $default,){
final _that = this;
switch (_that) {
case _MedicalDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicalDocument value)?  $default,){
final _that = this;
switch (_that) {
case _MedicalDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'doc_type')  DocumentType docType, @JsonKey(name: 'mime_type')  String mimeType, @JsonKey(name: 'local_uri_hint')  String localUriHint, @JsonKey(name: 'size_bytes')  int sizeBytes,  DocumentStatus status, @JsonKey(name: 'subject_id')  String? subjectId, @JsonKey(name: 'document_date')  String? documentDate,  String language, @JsonKey(name: 'local_only')  bool localOnly, @JsonKey(name: 'extracted_text_available')  bool extractedTextAvailable, @JsonKey(name: 'event_count')  int eventCount, @JsonKey(name: 'error_message')  String errorMessage, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicalDocument() when $default != null:
return $default(_that.id,_that.title,_that.docType,_that.mimeType,_that.localUriHint,_that.sizeBytes,_that.status,_that.subjectId,_that.documentDate,_that.language,_that.localOnly,_that.extractedTextAvailable,_that.eventCount,_that.errorMessage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'doc_type')  DocumentType docType, @JsonKey(name: 'mime_type')  String mimeType, @JsonKey(name: 'local_uri_hint')  String localUriHint, @JsonKey(name: 'size_bytes')  int sizeBytes,  DocumentStatus status, @JsonKey(name: 'subject_id')  String? subjectId, @JsonKey(name: 'document_date')  String? documentDate,  String language, @JsonKey(name: 'local_only')  bool localOnly, @JsonKey(name: 'extracted_text_available')  bool extractedTextAvailable, @JsonKey(name: 'event_count')  int eventCount, @JsonKey(name: 'error_message')  String errorMessage, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MedicalDocument():
return $default(_that.id,_that.title,_that.docType,_that.mimeType,_that.localUriHint,_that.sizeBytes,_that.status,_that.subjectId,_that.documentDate,_that.language,_that.localOnly,_that.extractedTextAvailable,_that.eventCount,_that.errorMessage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title, @JsonKey(name: 'doc_type')  DocumentType docType, @JsonKey(name: 'mime_type')  String mimeType, @JsonKey(name: 'local_uri_hint')  String localUriHint, @JsonKey(name: 'size_bytes')  int sizeBytes,  DocumentStatus status, @JsonKey(name: 'subject_id')  String? subjectId, @JsonKey(name: 'document_date')  String? documentDate,  String language, @JsonKey(name: 'local_only')  bool localOnly, @JsonKey(name: 'extracted_text_available')  bool extractedTextAvailable, @JsonKey(name: 'event_count')  int eventCount, @JsonKey(name: 'error_message')  String errorMessage, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MedicalDocument() when $default != null:
return $default(_that.id,_that.title,_that.docType,_that.mimeType,_that.localUriHint,_that.sizeBytes,_that.status,_that.subjectId,_that.documentDate,_that.language,_that.localOnly,_that.extractedTextAvailable,_that.eventCount,_that.errorMessage,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MedicalDocument implements MedicalDocument {
  const _MedicalDocument({required this.id, this.title = '', @JsonKey(name: 'doc_type') this.docType = DocumentType.other, @JsonKey(name: 'mime_type') this.mimeType = '', @JsonKey(name: 'local_uri_hint') this.localUriHint = '', @JsonKey(name: 'size_bytes') this.sizeBytes = 0, this.status = DocumentStatus.pendingIngest, @JsonKey(name: 'subject_id') this.subjectId, @JsonKey(name: 'document_date') this.documentDate, this.language = '', @JsonKey(name: 'local_only') this.localOnly = true, @JsonKey(name: 'extracted_text_available') this.extractedTextAvailable = false, @JsonKey(name: 'event_count') this.eventCount = 0, @JsonKey(name: 'error_message') this.errorMessage = '', @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _MedicalDocument.fromJson(Map<String, dynamic> json) => _$MedicalDocumentFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override@JsonKey(name: 'doc_type') final  DocumentType docType;
@override@JsonKey(name: 'mime_type') final  String mimeType;
@override@JsonKey(name: 'local_uri_hint') final  String localUriHint;
@override@JsonKey(name: 'size_bytes') final  int sizeBytes;
@override@JsonKey() final  DocumentStatus status;
@override@JsonKey(name: 'subject_id') final  String? subjectId;
@override@JsonKey(name: 'document_date') final  String? documentDate;
@override@JsonKey() final  String language;
@override@JsonKey(name: 'local_only') final  bool localOnly;
@override@JsonKey(name: 'extracted_text_available') final  bool extractedTextAvailable;
@override@JsonKey(name: 'event_count') final  int eventCount;
@override@JsonKey(name: 'error_message') final  String errorMessage;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of MedicalDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicalDocumentCopyWith<_MedicalDocument> get copyWith => __$MedicalDocumentCopyWithImpl<_MedicalDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MedicalDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicalDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.docType, docType) || other.docType == docType)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.localUriHint, localUriHint) || other.localUriHint == localUriHint)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.status, status) || other.status == status)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.documentDate, documentDate) || other.documentDate == documentDate)&&(identical(other.language, language) || other.language == language)&&(identical(other.localOnly, localOnly) || other.localOnly == localOnly)&&(identical(other.extractedTextAvailable, extractedTextAvailable) || other.extractedTextAvailable == extractedTextAvailable)&&(identical(other.eventCount, eventCount) || other.eventCount == eventCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,docType,mimeType,localUriHint,sizeBytes,status,subjectId,documentDate,language,localOnly,extractedTextAvailable,eventCount,errorMessage,createdAt,updatedAt);

@override
String toString() {
  return 'MedicalDocument(id: $id, title: $title, docType: $docType, mimeType: $mimeType, localUriHint: $localUriHint, sizeBytes: $sizeBytes, status: $status, subjectId: $subjectId, documentDate: $documentDate, language: $language, localOnly: $localOnly, extractedTextAvailable: $extractedTextAvailable, eventCount: $eventCount, errorMessage: $errorMessage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MedicalDocumentCopyWith<$Res> implements $MedicalDocumentCopyWith<$Res> {
  factory _$MedicalDocumentCopyWith(_MedicalDocument value, $Res Function(_MedicalDocument) _then) = __$MedicalDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String title,@JsonKey(name: 'doc_type') DocumentType docType,@JsonKey(name: 'mime_type') String mimeType,@JsonKey(name: 'local_uri_hint') String localUriHint,@JsonKey(name: 'size_bytes') int sizeBytes, DocumentStatus status,@JsonKey(name: 'subject_id') String? subjectId,@JsonKey(name: 'document_date') String? documentDate, String language,@JsonKey(name: 'local_only') bool localOnly,@JsonKey(name: 'extracted_text_available') bool extractedTextAvailable,@JsonKey(name: 'event_count') int eventCount,@JsonKey(name: 'error_message') String errorMessage,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$MedicalDocumentCopyWithImpl<$Res>
    implements _$MedicalDocumentCopyWith<$Res> {
  __$MedicalDocumentCopyWithImpl(this._self, this._then);

  final _MedicalDocument _self;
  final $Res Function(_MedicalDocument) _then;

/// Create a copy of MedicalDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? docType = null,Object? mimeType = null,Object? localUriHint = null,Object? sizeBytes = null,Object? status = null,Object? subjectId = freezed,Object? documentDate = freezed,Object? language = null,Object? localOnly = null,Object? extractedTextAvailable = null,Object? eventCount = null,Object? errorMessage = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_MedicalDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,docType: null == docType ? _self.docType : docType // ignore: cast_nullable_to_non_nullable
as DocumentType,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,localUriHint: null == localUriHint ? _self.localUriHint : localUriHint // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,subjectId: freezed == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String?,documentDate: freezed == documentDate ? _self.documentDate : documentDate // ignore: cast_nullable_to_non_nullable
as String?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,localOnly: null == localOnly ? _self.localOnly : localOnly // ignore: cast_nullable_to_non_nullable
as bool,extractedTextAvailable: null == extractedTextAvailable ? _self.extractedTextAvailable : extractedTextAvailable // ignore: cast_nullable_to_non_nullable
as bool,eventCount: null == eventCount ? _self.eventCount : eventCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$DocumentCreateRequest {

 String get title;@JsonKey(name: 'doc_type') DocumentType get docType;@JsonKey(name: 'mime_type') String get mimeType;@JsonKey(name: 'size_bytes') int get sizeBytes;@JsonKey(name: 'subject_id') String? get subjectId;@JsonKey(name: 'document_date') String? get documentDate;@JsonKey(name: 'local_uri_hint') String? get localUriHint; String? get language;
/// Create a copy of DocumentCreateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentCreateRequestCopyWith<DocumentCreateRequest> get copyWith => _$DocumentCreateRequestCopyWithImpl<DocumentCreateRequest>(this as DocumentCreateRequest, _$identity);

  /// Serializes this DocumentCreateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentCreateRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.docType, docType) || other.docType == docType)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.documentDate, documentDate) || other.documentDate == documentDate)&&(identical(other.localUriHint, localUriHint) || other.localUriHint == localUriHint)&&(identical(other.language, language) || other.language == language));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,docType,mimeType,sizeBytes,subjectId,documentDate,localUriHint,language);

@override
String toString() {
  return 'DocumentCreateRequest(title: $title, docType: $docType, mimeType: $mimeType, sizeBytes: $sizeBytes, subjectId: $subjectId, documentDate: $documentDate, localUriHint: $localUriHint, language: $language)';
}


}

/// @nodoc
abstract mixin class $DocumentCreateRequestCopyWith<$Res>  {
  factory $DocumentCreateRequestCopyWith(DocumentCreateRequest value, $Res Function(DocumentCreateRequest) _then) = _$DocumentCreateRequestCopyWithImpl;
@useResult
$Res call({
 String title,@JsonKey(name: 'doc_type') DocumentType docType,@JsonKey(name: 'mime_type') String mimeType,@JsonKey(name: 'size_bytes') int sizeBytes,@JsonKey(name: 'subject_id') String? subjectId,@JsonKey(name: 'document_date') String? documentDate,@JsonKey(name: 'local_uri_hint') String? localUriHint, String? language
});




}
/// @nodoc
class _$DocumentCreateRequestCopyWithImpl<$Res>
    implements $DocumentCreateRequestCopyWith<$Res> {
  _$DocumentCreateRequestCopyWithImpl(this._self, this._then);

  final DocumentCreateRequest _self;
  final $Res Function(DocumentCreateRequest) _then;

/// Create a copy of DocumentCreateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? docType = null,Object? mimeType = null,Object? sizeBytes = null,Object? subjectId = freezed,Object? documentDate = freezed,Object? localUriHint = freezed,Object? language = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,docType: null == docType ? _self.docType : docType // ignore: cast_nullable_to_non_nullable
as DocumentType,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,subjectId: freezed == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String?,documentDate: freezed == documentDate ? _self.documentDate : documentDate // ignore: cast_nullable_to_non_nullable
as String?,localUriHint: freezed == localUriHint ? _self.localUriHint : localUriHint // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentCreateRequest].
extension DocumentCreateRequestPatterns on DocumentCreateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentCreateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentCreateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentCreateRequest value)  $default,){
final _that = this;
switch (_that) {
case _DocumentCreateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentCreateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentCreateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title, @JsonKey(name: 'doc_type')  DocumentType docType, @JsonKey(name: 'mime_type')  String mimeType, @JsonKey(name: 'size_bytes')  int sizeBytes, @JsonKey(name: 'subject_id')  String? subjectId, @JsonKey(name: 'document_date')  String? documentDate, @JsonKey(name: 'local_uri_hint')  String? localUriHint,  String? language)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentCreateRequest() when $default != null:
return $default(_that.title,_that.docType,_that.mimeType,_that.sizeBytes,_that.subjectId,_that.documentDate,_that.localUriHint,_that.language);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title, @JsonKey(name: 'doc_type')  DocumentType docType, @JsonKey(name: 'mime_type')  String mimeType, @JsonKey(name: 'size_bytes')  int sizeBytes, @JsonKey(name: 'subject_id')  String? subjectId, @JsonKey(name: 'document_date')  String? documentDate, @JsonKey(name: 'local_uri_hint')  String? localUriHint,  String? language)  $default,) {final _that = this;
switch (_that) {
case _DocumentCreateRequest():
return $default(_that.title,_that.docType,_that.mimeType,_that.sizeBytes,_that.subjectId,_that.documentDate,_that.localUriHint,_that.language);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title, @JsonKey(name: 'doc_type')  DocumentType docType, @JsonKey(name: 'mime_type')  String mimeType, @JsonKey(name: 'size_bytes')  int sizeBytes, @JsonKey(name: 'subject_id')  String? subjectId, @JsonKey(name: 'document_date')  String? documentDate, @JsonKey(name: 'local_uri_hint')  String? localUriHint,  String? language)?  $default,) {final _that = this;
switch (_that) {
case _DocumentCreateRequest() when $default != null:
return $default(_that.title,_that.docType,_that.mimeType,_that.sizeBytes,_that.subjectId,_that.documentDate,_that.localUriHint,_that.language);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentCreateRequest implements DocumentCreateRequest {
  const _DocumentCreateRequest({required this.title, @JsonKey(name: 'doc_type') required this.docType, @JsonKey(name: 'mime_type') required this.mimeType, @JsonKey(name: 'size_bytes') required this.sizeBytes, @JsonKey(name: 'subject_id') this.subjectId, @JsonKey(name: 'document_date') this.documentDate, @JsonKey(name: 'local_uri_hint') this.localUriHint, this.language});
  factory _DocumentCreateRequest.fromJson(Map<String, dynamic> json) => _$DocumentCreateRequestFromJson(json);

@override final  String title;
@override@JsonKey(name: 'doc_type') final  DocumentType docType;
@override@JsonKey(name: 'mime_type') final  String mimeType;
@override@JsonKey(name: 'size_bytes') final  int sizeBytes;
@override@JsonKey(name: 'subject_id') final  String? subjectId;
@override@JsonKey(name: 'document_date') final  String? documentDate;
@override@JsonKey(name: 'local_uri_hint') final  String? localUriHint;
@override final  String? language;

/// Create a copy of DocumentCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentCreateRequestCopyWith<_DocumentCreateRequest> get copyWith => __$DocumentCreateRequestCopyWithImpl<_DocumentCreateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentCreateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentCreateRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.docType, docType) || other.docType == docType)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.documentDate, documentDate) || other.documentDate == documentDate)&&(identical(other.localUriHint, localUriHint) || other.localUriHint == localUriHint)&&(identical(other.language, language) || other.language == language));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,docType,mimeType,sizeBytes,subjectId,documentDate,localUriHint,language);

@override
String toString() {
  return 'DocumentCreateRequest(title: $title, docType: $docType, mimeType: $mimeType, sizeBytes: $sizeBytes, subjectId: $subjectId, documentDate: $documentDate, localUriHint: $localUriHint, language: $language)';
}


}

/// @nodoc
abstract mixin class _$DocumentCreateRequestCopyWith<$Res> implements $DocumentCreateRequestCopyWith<$Res> {
  factory _$DocumentCreateRequestCopyWith(_DocumentCreateRequest value, $Res Function(_DocumentCreateRequest) _then) = __$DocumentCreateRequestCopyWithImpl;
@override @useResult
$Res call({
 String title,@JsonKey(name: 'doc_type') DocumentType docType,@JsonKey(name: 'mime_type') String mimeType,@JsonKey(name: 'size_bytes') int sizeBytes,@JsonKey(name: 'subject_id') String? subjectId,@JsonKey(name: 'document_date') String? documentDate,@JsonKey(name: 'local_uri_hint') String? localUriHint, String? language
});




}
/// @nodoc
class __$DocumentCreateRequestCopyWithImpl<$Res>
    implements _$DocumentCreateRequestCopyWith<$Res> {
  __$DocumentCreateRequestCopyWithImpl(this._self, this._then);

  final _DocumentCreateRequest _self;
  final $Res Function(_DocumentCreateRequest) _then;

/// Create a copy of DocumentCreateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? docType = null,Object? mimeType = null,Object? sizeBytes = null,Object? subjectId = freezed,Object? documentDate = freezed,Object? localUriHint = freezed,Object? language = freezed,}) {
  return _then(_DocumentCreateRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,docType: null == docType ? _self.docType : docType // ignore: cast_nullable_to_non_nullable
as DocumentType,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,subjectId: freezed == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String?,documentDate: freezed == documentDate ? _self.documentDate : documentDate // ignore: cast_nullable_to_non_nullable
as String?,localUriHint: freezed == localUriHint ? _self.localUriHint : localUriHint // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DocumentStatusUpdate {

 String get id; DocumentStatus get status;
/// Create a copy of DocumentStatusUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentStatusUpdateCopyWith<DocumentStatusUpdate> get copyWith => _$DocumentStatusUpdateCopyWithImpl<DocumentStatusUpdate>(this as DocumentStatusUpdate, _$identity);

  /// Serializes this DocumentStatusUpdate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentStatusUpdate&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status);

@override
String toString() {
  return 'DocumentStatusUpdate(id: $id, status: $status)';
}


}

/// @nodoc
abstract mixin class $DocumentStatusUpdateCopyWith<$Res>  {
  factory $DocumentStatusUpdateCopyWith(DocumentStatusUpdate value, $Res Function(DocumentStatusUpdate) _then) = _$DocumentStatusUpdateCopyWithImpl;
@useResult
$Res call({
 String id, DocumentStatus status
});




}
/// @nodoc
class _$DocumentStatusUpdateCopyWithImpl<$Res>
    implements $DocumentStatusUpdateCopyWith<$Res> {
  _$DocumentStatusUpdateCopyWithImpl(this._self, this._then);

  final DocumentStatusUpdate _self;
  final $Res Function(DocumentStatusUpdate) _then;

/// Create a copy of DocumentStatusUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentStatusUpdate].
extension DocumentStatusUpdatePatterns on DocumentStatusUpdate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentStatusUpdate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentStatusUpdate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentStatusUpdate value)  $default,){
final _that = this;
switch (_that) {
case _DocumentStatusUpdate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentStatusUpdate value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentStatusUpdate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DocumentStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentStatusUpdate() when $default != null:
return $default(_that.id,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DocumentStatus status)  $default,) {final _that = this;
switch (_that) {
case _DocumentStatusUpdate():
return $default(_that.id,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DocumentStatus status)?  $default,) {final _that = this;
switch (_that) {
case _DocumentStatusUpdate() when $default != null:
return $default(_that.id,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentStatusUpdate implements DocumentStatusUpdate {
  const _DocumentStatusUpdate({required this.id, required this.status});
  factory _DocumentStatusUpdate.fromJson(Map<String, dynamic> json) => _$DocumentStatusUpdateFromJson(json);

@override final  String id;
@override final  DocumentStatus status;

/// Create a copy of DocumentStatusUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentStatusUpdateCopyWith<_DocumentStatusUpdate> get copyWith => __$DocumentStatusUpdateCopyWithImpl<_DocumentStatusUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentStatusUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentStatusUpdate&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status);

@override
String toString() {
  return 'DocumentStatusUpdate(id: $id, status: $status)';
}


}

/// @nodoc
abstract mixin class _$DocumentStatusUpdateCopyWith<$Res> implements $DocumentStatusUpdateCopyWith<$Res> {
  factory _$DocumentStatusUpdateCopyWith(_DocumentStatusUpdate value, $Res Function(_DocumentStatusUpdate) _then) = __$DocumentStatusUpdateCopyWithImpl;
@override @useResult
$Res call({
 String id, DocumentStatus status
});




}
/// @nodoc
class __$DocumentStatusUpdateCopyWithImpl<$Res>
    implements _$DocumentStatusUpdateCopyWith<$Res> {
  __$DocumentStatusUpdateCopyWithImpl(this._self, this._then);

  final _DocumentStatusUpdate _self;
  final $Res Function(_DocumentStatusUpdate) _then;

/// Create a copy of DocumentStatusUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,}) {
  return _then(_DocumentStatusUpdate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,
  ));
}


}

// dart format on
