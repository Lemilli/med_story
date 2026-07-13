import 'package:freezed_annotation/freezed_annotation.dart';

import '../../events/domain/medical_event.dart';

part 'timeline_filters.freezed.dart';

@freezed
abstract class TimelineFilters with _$TimelineFilters {
  const factory TimelineFilters({
    @Default(<MedicalEventType>{}) Set<MedicalEventType> types,
    DateTime? from,
    DateTime? to,
    @Default('') String tag,
    @Default('') String query,
  }) = _TimelineFilters;
}
