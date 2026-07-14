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
      eventCount: (json['event_count'] as num?)?.toInt() ?? 0,
      eventId: json['event_id'] as String?,
      assets:
          (json['assets'] as List<dynamic>?)
              ?.map(
                (e) =>
                    DocumentAssetMetadata.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <DocumentAssetMetadata>[],
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
      'event_count': instance.eventCount,
      'event_id': instance.eventId,
      'assets': instance.assets,
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

_DocumentAssetMetadata _$DocumentAssetMetadataFromJson(
  Map<String, dynamic> json,
) => _DocumentAssetMetadata(
  id: json['id'] as String,
  position: (json['position'] as num).toInt(),
  fileName: json['file_name'] as String,
  mimeType: json['mime_type'] as String,
  sizeBytes: (json['size_bytes'] as num).toInt(),
);

Map<String, dynamic> _$DocumentAssetMetadataToJson(
  _DocumentAssetMetadata instance,
) => <String, dynamic>{
  'id': instance.id,
  'position': instance.position,
  'file_name': instance.fileName,
  'mime_type': instance.mimeType,
  'size_bytes': instance.sizeBytes,
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
  language: json['language'] as String?,
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
  'language': instance.language,
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
