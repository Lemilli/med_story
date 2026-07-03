import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../events/domain/medical_event.dart';
import '../../../subjects/domain/subject.dart';
import '../../../subjects/presentation/controllers/subject_controller.dart';
import '../../../timeline/data/timeline_repository.dart';
import '../../../timeline/domain/timeline_filters.dart';
import '../../data/summary_api.dart';
import '../../data/summary_repository.dart';
import '../../domain/medical_summary.dart';

final summaryControllerProvider =
    AsyncNotifierProvider<SummaryController, SummaryState>(
      SummaryController.new,
    );

final summarySearchEventsProvider =
    StreamProvider.autoDispose<List<MedicalEvent>>((ref) {
      final summaryValue = ref.watch(summaryControllerProvider);
      final state = summaryValue.hasValue ? summaryValue.value : null;
      final subjectId = state?.subject?.id;
      if (subjectId == null || state == null || state.searchQuery.isEmpty) {
        return Stream.value(const <MedicalEvent>[]);
      }
      return ref
          .watch(timelineRepositoryProvider)
          .watchTimeline(
            subjectId: subjectId,
            filters: TimelineFilters(query: state.searchQuery),
          );
    });

class SummaryController extends AsyncNotifier<SummaryState> {
  @override
  Future<SummaryState> build() async {
    final subjectState = await ref.watch(subjectControllerProvider.future);
    final subject = subjectState.selectedSubject;
    final initial = SummaryState(subject: subject);
    if (subject == null) {
      return initial;
    }
    return _load(initial);
  }

  Future<void> refresh() async {
    final current = state.hasValue ? state.value : null;
    if (current == null || current.subject == null) {
      return;
    }
    state = AsyncValue.data(current.copyWith(isRefreshing: true));
    state = AsyncValue.data(await _load(current));
  }

  Future<void> regenerate() async {
    final current = state.hasValue ? state.value : null;
    final subject = current?.subject;
    if (current == null || subject == null || current.isRegenerating) {
      return;
    }
    state = AsyncValue.data(
      current.copyWith(isRegenerating: true, queuedMessage: null),
    );
    try {
      await ref
          .read(summaryRepositoryProvider)
          .regenerate(subjectId: subject.id);
      state = AsyncValue.data(
        current.copyWith(
          isRegenerating: false,
          queuedMessage: 'queued',
          loadResult: current.loadResult,
        ),
      );
    } on Object catch (error) {
      state = AsyncValue.data(
        current.copyWith(
          isRegenerating: false,
          actionError: error.toString(),
          queuedMessage: null,
        ),
      );
    }
  }

  Future<void> exportPdf() async {
    final current = state.hasValue ? state.value : null;
    final subject = current?.subject;
    if (current == null || subject == null || current.isExporting) {
      return;
    }
    state = AsyncValue.data(
      current.copyWith(isExporting: true, actionError: null),
    );
    try {
      await ref
          .read(summaryRepositoryProvider)
          .exportPdf(subjectId: subject.id);
      state = AsyncValue.data(
        current.copyWith(isExporting: false, exportCompleted: true),
      );
    } on SummaryNotReady {
      state = AsyncValue.data(
        current.copyWith(isExporting: false, actionError: 'summary_not_ready'),
      );
    } on Object catch (error) {
      state = AsyncValue.data(
        current.copyWith(isExporting: false, actionError: error.toString()),
      );
    }
  }

  Future<void> updateSearchQuery(String query) async {
    final current = state.hasValue ? state.value : null;
    final subject = current?.subject;
    if (current == null) {
      return;
    }
    final trimmed = query.trim();
    state = AsyncValue.data(current.copyWith(searchQuery: trimmed));
    if (subject == null || trimmed.isEmpty) {
      return;
    }
    try {
      await ref
          .read(timelineRepositoryProvider)
          .refreshTimeline(
            subjectId: subject.id,
            filters: TimelineFilters(query: trimmed),
          );
    } on Object {
      // Cached timeline results are still useful for summary search.
    }
  }

  void previewVersion(MedicalSummary? summary) {
    final current = state.hasValue ? state.value : null;
    if (current == null) {
      return;
    }
    state = AsyncValue.data(current.copyWith(previewSummary: summary));
  }

  void consumeActionMessages() {
    final current = state.hasValue ? state.value : null;
    if (current == null) {
      return;
    }
    state = AsyncValue.data(
      current.copyWith(
        actionError: null,
        queuedMessage: null,
        exportCompleted: false,
      ),
    );
  }

  Future<SummaryState> _load(SummaryState current) async {
    final subject = current.subject;
    if (subject == null) {
      return current.copyWith(isRefreshing: false);
    }
    final repository = ref.read(summaryRepositoryProvider);
    final result = await repository.getCurrentSummary(subjectId: subject.id);
    final versions = result.isReady
        ? await repository.listVersions(subjectId: subject.id)
        : const <MedicalSummary>[];
    return current.copyWith(
      loadResult: result,
      versions: versions,
      previewSummary: null,
      isRefreshing: false,
      actionError: null,
    );
  }
}

class SummaryState {
  const SummaryState({
    required this.subject,
    this.loadResult = const SummaryLoadResult.notReady(),
    this.versions = const <MedicalSummary>[],
    this.previewSummary,
    this.searchQuery = '',
    this.isRefreshing = false,
    this.isRegenerating = false,
    this.isExporting = false,
    this.exportCompleted = false,
    this.queuedMessage,
    this.actionError,
  });

  final Subject? subject;
  final SummaryLoadResult loadResult;
  final List<MedicalSummary> versions;
  final MedicalSummary? previewSummary;
  final String searchQuery;
  final bool isRefreshing;
  final bool isRegenerating;
  final bool isExporting;
  final bool exportCompleted;
  final String? queuedMessage;
  final String? actionError;

  MedicalSummary? get currentSummary => loadResult.summary;

  MedicalSummary? get visibleSummary => previewSummary ?? currentSummary;

  bool get isPreviewingVersion => previewSummary != null;

  SummaryState copyWith({
    Subject? subject,
    SummaryLoadResult? loadResult,
    List<MedicalSummary>? versions,
    Object? previewSummary = _unchanged,
    String? searchQuery,
    bool? isRefreshing,
    bool? isRegenerating,
    bool? isExporting,
    bool? exportCompleted,
    Object? queuedMessage = _unchanged,
    Object? actionError = _unchanged,
  }) {
    return SummaryState(
      subject: subject ?? this.subject,
      loadResult: loadResult ?? this.loadResult,
      versions: versions ?? this.versions,
      previewSummary: previewSummary == _unchanged
          ? this.previewSummary
          : previewSummary as MedicalSummary?,
      searchQuery: searchQuery ?? this.searchQuery,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isRegenerating: isRegenerating ?? this.isRegenerating,
      isExporting: isExporting ?? this.isExporting,
      exportCompleted: exportCompleted ?? this.exportCompleted,
      queuedMessage: queuedMessage == _unchanged
          ? this.queuedMessage
          : queuedMessage as String?,
      actionError: actionError == _unchanged
          ? this.actionError
          : actionError as String?,
    );
  }
}

const _unchanged = Object();
