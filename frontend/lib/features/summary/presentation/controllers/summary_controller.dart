import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../subjects/domain/subject.dart';
import '../../../subjects/presentation/controllers/subject_controller.dart';
import '../../data/summary_api.dart';
import '../../data/summary_repository.dart';
import '../../domain/medical_summary.dart';

final summaryControllerProvider =
    AsyncNotifierProvider<SummaryController, SummaryState>(
      SummaryController.new,
    );

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
    return current.copyWith(
      loadResult: result,
      isRefreshing: false,
      actionError: null,
    );
  }
}

const _unchanged = Object();

class SummaryState {
  const SummaryState({
    required this.subject,
    this.loadResult = const SummaryLoadResult.notReady(),
    this.isRefreshing = false,
    this.isRegenerating = false,
    this.isExporting = false,
    this.exportCompleted = false,
    this.queuedMessage,
    this.actionError,
  });

  final Subject? subject;
  final SummaryLoadResult loadResult;
  final bool isRefreshing;
  final bool isRegenerating;
  final bool isExporting;
  final bool exportCompleted;
  final String? queuedMessage;
  final String? actionError;

  MedicalSummary? get currentSummary => loadResult.summary;

  MedicalSummary? get visibleSummary => currentSummary;

  SummaryState copyWith({
    Subject? subject,
    SummaryLoadResult? loadResult,
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
