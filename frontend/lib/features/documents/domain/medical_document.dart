import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_document.freezed.dart';
part 'medical_document.g.dart';

@freezed
abstract class MedicalDocument with _$MedicalDocument {
  const factory MedicalDocument({
    required String id,
    @Default('') String title,
    @JsonKey(name: 'doc_type')
    @Default(DocumentType.other)
    DocumentType docType,
    @JsonKey(name: 'mime_type') @Default('') String mimeType,
    @JsonKey(name: 'local_uri_hint') @Default('') String localUriHint,
    @JsonKey(name: 'size_bytes') @Default(0) int sizeBytes,
    @Default(DocumentStatus.pendingIngest) DocumentStatus status,
    @JsonKey(name: 'subject_id') String? subjectId,
    @JsonKey(name: 'document_date') String? documentDate,
    @Default('') String language,
    @JsonKey(name: 'local_only') @Default(false) bool localOnly,
    @JsonKey(name: 'extracted_text_available')
    @Default(false)
    bool extractedTextAvailable,
    @JsonKey(name: 'event_count') @Default(0) int eventCount,
    @JsonKey(name: 'event_id') String? eventId,
    @Default(<DocumentAssetMetadata>[]) List<DocumentAssetMetadata> assets,
    @JsonKey(name: 'error_message') @Default('') String errorMessage,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _MedicalDocument;

  factory MedicalDocument.fromJson(Map<String, dynamic> json) =>
      _$MedicalDocumentFromJson(json);
}

@freezed
abstract class DocumentAssetMetadata with _$DocumentAssetMetadata {
  const factory DocumentAssetMetadata({
    required String id,
    required int position,
    @JsonKey(name: 'file_name') required String fileName,
    @JsonKey(name: 'mime_type') required String mimeType,
    @JsonKey(name: 'size_bytes') required int sizeBytes,
    @Default(true) bool available,
  }) = _DocumentAssetMetadata;

  factory DocumentAssetMetadata.fromJson(Map<String, dynamic> json) =>
      _$DocumentAssetMetadataFromJson(json);
}

@freezed
abstract class DocumentCreateRequest with _$DocumentCreateRequest {
  const factory DocumentCreateRequest({
    required String title,
    @JsonKey(name: 'doc_type') required DocumentType docType,
    @JsonKey(name: 'mime_type') required String mimeType,
    @JsonKey(name: 'size_bytes') required int sizeBytes,
    @JsonKey(name: 'subject_id') String? subjectId,
    @JsonKey(name: 'document_date') String? documentDate,
    @JsonKey(name: 'local_uri_hint') String? localUriHint,
    String? language,
  }) = _DocumentCreateRequest;

  factory DocumentCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$DocumentCreateRequestFromJson(json);
}

@freezed
abstract class DocumentStatusUpdate with _$DocumentStatusUpdate {
  const factory DocumentStatusUpdate({
    required String id,
    required DocumentStatus status,
  }) = _DocumentStatusUpdate;

  factory DocumentStatusUpdate.fromJson(Map<String, dynamic> json) =>
      _$DocumentStatusUpdateFromJson(json);
}

enum DocumentType {
  @JsonValue('medical_record')
  medicalRecord,
  @JsonValue('lab_result')
  labResult,
  report,
  prescription,
  @JsonValue('procedure_summary')
  procedureSummary,
  note,
  image,
  audio,
  other,
}

enum DocumentStatus {
  @JsonValue('pending_ingest')
  pendingIngest,
  processing,
  processed,
  failed,
}

extension DocumentTypeApiName on DocumentType {
  String get apiName {
    return switch (this) {
      DocumentType.medicalRecord => 'medical_record',
      DocumentType.labResult => 'lab_result',
      DocumentType.report => 'report',
      DocumentType.prescription => 'prescription',
      DocumentType.procedureSummary => 'procedure_summary',
      DocumentType.note => 'note',
      DocumentType.image => 'image',
      DocumentType.audio => 'audio',
      DocumentType.other => 'other',
    };
  }
}

extension DocumentStatusApiName on DocumentStatus {
  String get apiName {
    return switch (this) {
      DocumentStatus.pendingIngest => 'pending_ingest',
      DocumentStatus.processing => 'processing',
      DocumentStatus.processed => 'processed',
      DocumentStatus.failed => 'failed',
    };
  }

  bool get isTerminal {
    return this == DocumentStatus.processed || this == DocumentStatus.failed;
  }
}
