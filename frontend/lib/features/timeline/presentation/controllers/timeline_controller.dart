import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../events/domain/medical_event.dart';
import '../../../subjects/presentation/controllers/subject_controller.dart';
import '../../data/timeline_repository.dart';
import '../../domain/timeline_filters.dart';

final timelineControllerProvider =
    AsyncNotifierProvider<TimelineController, TimelineState>(
      TimelineController.new,
    );

final timelineEventsProvider = StreamProvider.autoDispose<List<MedicalEvent>>((
  ref,
) {
  final timelineValue = ref.watch(timelineControllerProvider);
  final timelineState = timelineValue.hasValue ? timelineValue.value : null;
  final subjectId = timelineState?.subjectId;
  if (subjectId == null) {
    return Stream.value(const <MedicalEvent>[]);
  }
  final filters = timelineState?.filters ?? const TimelineFilters();
  return ref
      .watch(timelineRepositoryProvider)
      .watchTimeline(subjectId: subjectId, filters: filters);
});

class TimelineController extends AsyncNotifier<TimelineState> {
  @override
  Future<TimelineState> build() async {
    final subjectState = await ref.watch(subjectControllerProvider.future);
    final subjectId = subjectState.selectedSubjectId;
    final initialState = TimelineState(subjectId: subjectId);
    if (subjectId == null) {
      return initialState;
    }
    return _refresh(initialState);
  }

  Future<void> refresh() async {
    final current = state.hasValue ? state.value : null;
    if (current == null || current.subjectId == null) {
      return;
    }
    state = AsyncValue.data(current.copyWith(isRefreshing: true));
    state = AsyncValue.data(await _refresh(current.copyWith(nextCursor: null)));
  }

  Future<void> loadMore() async {
    final current = state.hasValue ? state.value : null;
    if (current == null ||
        current.subjectId == null ||
        current.nextCursor == null ||
        current.isLoadingMore) {
      return;
    }

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    try {
      final page = await ref
          .read(timelineRepositoryProvider)
          .refreshTimeline(
            subjectId: current.subjectId!,
            filters: current.filters,
            cursor: current.nextCursor,
          );
      state = AsyncValue.data(
        current.copyWith(
          nextCursor: page.nextCursor,
          isLoadingMore: false,
          errorMessage: null,
        ),
      );
    } on Object catch (error) {
      state = AsyncValue.data(
        current.copyWith(isLoadingMore: false, errorMessage: error.toString()),
      );
    }
  }

  Future<void> updateFilters(TimelineFilters filters) async {
    final current = state.hasValue ? state.value : null;
    if (current == null) {
      return;
    }
    final next = current.copyWith(filters: filters, nextCursor: null);
    state = AsyncValue.data(next);
    if (next.subjectId != null) {
      state = AsyncValue.data(await _refresh(next));
    }
  }

  Future<TimelineState> _refresh(TimelineState current) async {
    final subjectId = current.subjectId;
    if (subjectId == null) {
      return current.copyWith(isRefreshing: false);
    }
    try {
      final page = await ref
          .read(timelineRepositoryProvider)
          .refreshTimeline(subjectId: subjectId, filters: current.filters);
      return current.copyWith(
        nextCursor: page.nextCursor,
        isRefreshing: false,
        errorMessage: null,
      );
    } on Object catch (error) {
      return current.copyWith(
        isRefreshing: false,
        errorMessage: error.toString(),
      );
    }
  }
}

class TimelineState {
  const TimelineState({
    required this.subjectId,
    this.filters = const TimelineFilters(),
    this.nextCursor,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final String? subjectId;
  final TimelineFilters filters;
  final String? nextCursor;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => nextCursor != null;

  TimelineState copyWith({
    String? subjectId,
    TimelineFilters? filters,
    Object? nextCursor = _unchanged,
    bool? isRefreshing,
    bool? isLoadingMore,
    Object? errorMessage = _unchanged,
  }) {
    return TimelineState(
      subjectId: subjectId ?? this.subjectId,
      filters: filters ?? this.filters,
      nextCursor: nextCursor == _unchanged
          ? this.nextCursor
          : nextCursor as String?,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage == _unchanged
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const _unchanged = Object();
