// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MedicalDocument _$MedicalDocumentFromJson(Map<String, dynamic> json) =>
    _MedicalDocument(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      docType:
          $enumDecodeNullable(_$DocumentTypeEnumMap, json['doc_type']) ??
          DocumentType.other,
      mimeType: json['mime_type'] as String? ?? '',
      localUriHint: json['local_uri_hint'] as String? ?? '',
      sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
      status:
          $enumDecodeNullable(_$DocumentStatusEnumMap, json['status']) ??
          DocumentStatus.pendingIngest,
      subjectId: json['subject_id'] as String?,
      documentDate: json['document_date'] as String?,
      language: json['language'] as String? ?? '',
      localOnly: json['local_only'] as bool? ?? true,
      extractedTextAvailable:
          json['extracted_text_available'] as bool? ?? false,
      explanationAvailable: json['explanation_available'] as bool? ?? false,
      eventCount: (json['event_count'] as num?)?.toInt() ?? 0,
      errorMessage: json['error_message'] as String? ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$MedicalDocumentToJson(_MedicalDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'doc_type': _$DocumentTypeEnumMap[instance.docType]!,
      'mime_type': instance.mimeType,
      'local_uri_hint': instance.localUriHint,
      'size_bytes': instance.sizeBytes,
      'status': _$DocumentStatusEnumMap[instance.status]!,
      'subject_id': instance.subjectId,
      'document_date': instance.documentDate,
      'language': instance.language,
      'local_only': instance.localOnly,
      'extracted_text_available': instance.extractedTextAvailable,
      'explanation_available': instance.explanationAvailable,
      'event_count': instance.eventCount,
      'error_message': instance.errorMessage,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$DocumentTypeEnumMap = {
  DocumentType.medicalRecord: 'medical_record',
  DocumentType.labResult: 'lab_result',
  DocumentType.report: 'report',
  DocumentType.prescription: 'prescription',
  DocumentType.procedureSummary: 'procedure_summary',
  DocumentType.note: 'note',
  DocumentType.image: 'image',
  DocumentType.audio: 'audio',
  DocumentType.other: 'other',
};

const _$DocumentStatusEnumMap = {
  DocumentStatus.pendingIngest: 'pending_ingest',
  DocumentStatus.processing: 'processing',
  DocumentStatus.processed: 'processed',
  DocumentStatus.failed: 'failed',
};

_DocumentCreateRequest _$DocumentCreateRequestFromJson(
  Map<String, dynamic> json,
) => _DocumentCreateRequest(
  title: json['title'] as String,
  docType: $enumDecode(_$DocumentTypeEnumMap, json['doc_type']),
  mimeType: json['mime_type'] as String,
  sizeBytes: (json['size_bytes'] as num).toInt(),
  subjectId: json['subject_id'] as String?,
  documentDate: json['document_date'] as String?,
  localUriHint: json['local_uri_hint'] as String?,
);

Map<String, dynamic> _$DocumentCreateRequestToJson(
  _DocumentCreateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'doc_type': _$DocumentTypeEnumMap[instance.docType]!,
  'mime_type': instance.mimeType,
  'size_bytes': instance.sizeBytes,
  'subject_id': instance.subjectId,
  'document_date': instance.documentDate,
  'local_uri_hint': instance.localUriHint,
};

_DocumentStatusUpdate _$DocumentStatusUpdateFromJson(
  Map<String, dynamic> json,
) => _DocumentStatusUpdate(
  id: json['id'] as String,
  status: $enumDecode(_$DocumentStatusEnumMap, json['status']),
);

Map<String, dynamic> _$DocumentStatusUpdateToJson(
  _DocumentStatusUpdate instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': _$DocumentStatusEnumMap[instance.status]!,
};

_DocumentExplanation _$DocumentExplanationFromJson(Map<String, dynamic> json) =>
    _DocumentExplanation(
      documentId: json['document_id'] as String,
      summaryText: json['summary_text'] as String? ?? '',
      keyPoints:
          (json['key_points'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      glossary:
          (json['glossary'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      language: json['language'] as String? ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DocumentExplanationToJson(
  _DocumentExplanation instance,
) => <String, dynamic>{
  'document_id': instance.documentId,
  'summary_text': instance.summaryText,
  'key_points': instance.keyPoints,
  'glossary': instance.glossary,
  'language': instance.language,
  'created_at': instance.createdAt?.toIso8601String(),
};

_ExplanationRegenerateResult _$ExplanationRegenerateResultFromJson(
  Map<String, dynamic> json,
) => _ExplanationRegenerateResult(
  jobId: json['job_id'] as String,
  status: json['status'] as String? ?? '',
);

Map<String, dynamic> _$ExplanationRegenerateResultToJson(
  _ExplanationRegenerateResult instance,
) => <String, dynamic>{'job_id': instance.jobId, 'status': instance.status};
