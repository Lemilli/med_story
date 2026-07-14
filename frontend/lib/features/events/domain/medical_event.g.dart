// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MedicalEvent _$MedicalEventFromJson(Map<String, dynamic> json) =>
    _MedicalEvent(
      id: json['id'] as String,
      eventType: $enumDecode(_$MedicalEventTypeEnumMap, json['event_type']),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      eventDate: json['event_date'] as String,
      eventEndDate: json['event_end_date'] as String?,
      attributes:
          json['attributes'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      source:
          $enumDecodeNullable(_$EventSourceEnumMap, json['source']) ??
          EventSource.userManual,
      sourceDocumentId: json['source_document_id'] as String?,
      sourceText: json['source_text'] as String?,
      sourceAssetCount: (json['source_asset_count'] as num?)?.toInt() ?? 0,
      sourcePagePositions:
          (json['source_page_positions'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      pendingRevision: json['pending_revision'] == null
          ? null
          : EventRevision.fromJson(
              json['pending_revision'] as Map<String, dynamic>,
            ),
      confidence: (json['confidence'] as num?)?.toDouble(),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      subjectId: json['subject_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$MedicalEventToJson(_MedicalEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_type': _$MedicalEventTypeEnumMap[instance.eventType]!,
      'title': instance.title,
      'description': instance.description,
      'event_date': instance.eventDate,
      'event_end_date': instance.eventEndDate,
      'attributes': instance.attributes,
      'source': _$EventSourceEnumMap[instance.source]!,
      'source_document_id': instance.sourceDocumentId,
      'source_text': instance.sourceText,
      'source_asset_count': instance.sourceAssetCount,
      'source_page_positions': instance.sourcePagePositions,
      'pending_revision': instance.pendingRevision,
      'confidence': instance.confidence,
      'tags': instance.tags,
      'subject_id': instance.subjectId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$MedicalEventTypeEnumMap = {
  MedicalEventType.symptom: 'symptom',
  MedicalEventType.diagnosis: 'diagnosis',
  MedicalEventType.medication: 'medication',
  MedicalEventType.examination: 'examination',
  MedicalEventType.procedure: 'procedure',
  MedicalEventType.hospitalization: 'hospitalization',
  MedicalEventType.treatmentOutcome: 'treatment_outcome',
  MedicalEventType.medicalRecord: 'medical_record',
  MedicalEventType.note: 'note',
};

const _$EventSourceEnumMap = {
  EventSource.userManual: 'user_manual',
  EventSource.aiDocument: 'ai_document',
  EventSource.aiVoice: 'ai_voice',
};

_EventRevision _$EventRevisionFromJson(Map<String, dynamic> json) =>
    _EventRevision(
      id: json['id'] as String,
      currentSnapshot:
          json['current_snapshot'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      suggestedChanges:
          json['suggested_changes'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
    );

Map<String, dynamic> _$EventRevisionToJson(_EventRevision instance) =>
    <String, dynamic>{
      'id': instance.id,
      'current_snapshot': instance.currentSnapshot,
      'suggested_changes': instance.suggestedChanges,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'resolved_at': instance.resolvedAt?.toIso8601String(),
    };
