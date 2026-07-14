import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_event.freezed.dart';
part 'medical_event.g.dart';

@freezed
abstract class MedicalEvent with _$MedicalEvent {
  const factory MedicalEvent({
    required String id,
    @JsonKey(name: 'event_type') required MedicalEventType eventType,
    required String title,
    @Default('') String description,
    @JsonKey(name: 'event_date') required String eventDate,
    @JsonKey(name: 'event_end_date') String? eventEndDate,
    @Default(<String, dynamic>{}) Map<String, dynamic> attributes,
    @Default(EventSource.userManual) EventSource source,
    @JsonKey(name: 'source_document_id') String? sourceDocumentId,
    @JsonKey(name: 'source_text') String? sourceText,
    @JsonKey(name: 'source_asset_count') @Default(0) int sourceAssetCount,
    @JsonKey(name: 'source_page_positions')
    @Default(<int>[])
    List<int> sourcePagePositions,
    @JsonKey(name: 'pending_revision') EventRevision? pendingRevision,
    double? confidence,
    @Default(<String>[]) List<String> tags,
    @JsonKey(name: 'subject_id') required String subjectId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _MedicalEvent;

  factory MedicalEvent.fromJson(Map<String, dynamic> json) =>
      _$MedicalEventFromJson(json);
}

@freezed
abstract class EventRevision with _$EventRevision {
  const factory EventRevision({
    required String id,
    @JsonKey(name: 'current_snapshot')
    @Default(<String, dynamic>{})
    Map<String, dynamic> currentSnapshot,
    @JsonKey(name: 'suggested_changes')
    @Default(<String, dynamic>{})
    Map<String, dynamic> suggestedChanges,
    @Default('pending') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
  }) = _EventRevision;

  factory EventRevision.fromJson(Map<String, dynamic> json) =>
      _$EventRevisionFromJson(json);
}

enum MedicalEventType {
  symptom,
  diagnosis,
  medication,
  examination,
  procedure,
  hospitalization,
  @JsonValue('treatment_outcome')
  treatmentOutcome,
  @JsonValue('medical_record')
  medicalRecord,
  note,
}

enum EventSource {
  @JsonValue('user_manual')
  userManual,
  @JsonValue('ai_document')
  aiDocument,
  @JsonValue('ai_voice')
  aiVoice,
}

extension MedicalEventTypeApiName on MedicalEventType {
  String get apiName {
    return switch (this) {
      MedicalEventType.symptom => 'symptom',
      MedicalEventType.diagnosis => 'diagnosis',
      MedicalEventType.medication => 'medication',
      MedicalEventType.examination => 'examination',
      MedicalEventType.procedure => 'procedure',
      MedicalEventType.hospitalization => 'hospitalization',
      MedicalEventType.treatmentOutcome => 'treatment_outcome',
      MedicalEventType.medicalRecord => 'medical_record',
      MedicalEventType.note => 'note',
    };
  }
}
