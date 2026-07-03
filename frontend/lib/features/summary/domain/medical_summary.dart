import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_summary.freezed.dart';
part 'medical_summary.g.dart';

@freezed
abstract class MedicalSummary with _$MedicalSummary {
  const factory MedicalSummary({
    required String id,
    @JsonKey(name: 'subject_id') required String subjectId,
    required int version,
    @JsonKey(name: 'is_current') @Default(false) bool isCurrent,
    @Default(<String, dynamic>{}) Map<String, dynamic> content,
    @JsonKey(name: 'narrative_text') @Default('') String narrativeText,
    @Default('') String language,
    @JsonKey(name: 'generated_from_event_count')
    @Default(0)
    int generatedFromEventCount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _MedicalSummary;

  factory MedicalSummary.fromJson(Map<String, dynamic> json) =>
      _$MedicalSummaryFromJson(json);
}

@freezed
abstract class SummaryRegenerateResult with _$SummaryRegenerateResult {
  const factory SummaryRegenerateResult({
    @JsonKey(name: 'job_id') required String jobId,
    @Default('') String status,
  }) = _SummaryRegenerateResult;

  factory SummaryRegenerateResult.fromJson(Map<String, dynamic> json) =>
      _$SummaryRegenerateResultFromJson(json);
}
