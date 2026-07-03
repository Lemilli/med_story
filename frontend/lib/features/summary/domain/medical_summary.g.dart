// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MedicalSummary _$MedicalSummaryFromJson(Map<String, dynamic> json) =>
    _MedicalSummary(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      version: (json['version'] as num).toInt(),
      isCurrent: json['is_current'] as bool? ?? false,
      content:
          json['content'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      narrativeText: json['narrative_text'] as String? ?? '',
      language: json['language'] as String? ?? '',
      generatedFromEventCount:
          (json['generated_from_event_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MedicalSummaryToJson(_MedicalSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject_id': instance.subjectId,
      'version': instance.version,
      'is_current': instance.isCurrent,
      'content': instance.content,
      'narrative_text': instance.narrativeText,
      'language': instance.language,
      'generated_from_event_count': instance.generatedFromEventCount,
      'created_at': instance.createdAt?.toIso8601String(),
    };

_SummaryRegenerateResult _$SummaryRegenerateResultFromJson(
  Map<String, dynamic> json,
) => _SummaryRegenerateResult(
  jobId: json['job_id'] as String,
  status: json['status'] as String? ?? '',
);

Map<String, dynamic> _$SummaryRegenerateResultToJson(
  _SummaryRegenerateResult instance,
) => <String, dynamic>{'job_id': instance.jobId, 'status': instance.status};
