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

class SummaryItem {
  const SummaryItem({
    required this.text,
    this.detail = '',
    this.sourceEventIds = const [],
    this.sources = const [],
  });

  factory SummaryItem.fromJson(Map<String, dynamic> json) {
    return SummaryItem(
      text: json['text'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      sourceEventIds: (json['source_event_ids'] as List? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      sources: (json['sources'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (source) =>
                SummarySource.fromJson(Map<String, dynamic>.from(source)),
          )
          .toList(growable: false),
    );
  }

  final String text;
  final String detail;
  final List<String> sourceEventIds;
  final List<SummarySource> sources;
}

class SummarySource {
  const SummarySource({
    required this.eventId,
    required this.title,
    required this.eventDate,
    this.documentTitle,
    this.sourcePagePositions = const [],
  });

  factory SummarySource.fromJson(Map<String, dynamic> json) {
    return SummarySource(
      eventId: json['event_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      eventDate: json['event_date'] as String? ?? '',
      documentTitle: json['document_title'] as String?,
      sourcePagePositions: (json['source_page_positions'] as List? ?? const [])
          .whereType<num>()
          .map((position) => position.toInt())
          .toList(growable: false),
    );
  }

  final String eventId;
  final String title;
  final String eventDate;
  final String? documentTitle;
  final List<int> sourcePagePositions;
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
