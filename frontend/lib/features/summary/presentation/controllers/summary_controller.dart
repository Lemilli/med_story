import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../subjects/domain/subject.dart';
import '../../../subjects/presentation/controllers/subject_controller.dart';
import '../../data/summary_api.dart';
import '../../data/summary_repository.dart';
import '../../domain/medical_summary.dart';
import '../../../visit_preparation/data/visit_preparation_api.dart';

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
    return _load(initial, loadReason: true);
  }

  Future<void> refresh() async {
    final current = state.hasValue ? state.value : null;
    if (current == null ||
        current.subject == null ||
        current.isRefreshing ||
        current.isRegenerating ||
        current.isSavingReason) {
      return;
    }
    state = AsyncValue.data(current.copyWith(isRefreshing: true));
    try {
      final result = await ref
          .read(summaryRepositoryProvider)
          .getCurrentSummary(subjectId: current.subject!.id);
      final latest = state.requireValue;
      state = AsyncValue.data(
        latest.copyWith(
          loadResult: result,
          isRefreshing: false,
          actionError: null,
        ),
      );
    } on Object catch (error) {
      final latest = state.requireValue;
      state = AsyncValue.data(
        latest.copyWith(isRefreshing: false, actionError: error.toString()),
      );
    }
  }

  Future<void> regenerate() async {
    final current = state.hasValue ? state.value : null;
    final subject = current?.subject;
    if (current == null ||
        subject == null ||
        current.isRegenerating ||
        current.isRefreshing ||
        current.isSavingReason) {
      return;
    }
    state = AsyncValue.data(
      current.copyWith(isRegenerating: true, queuedMessage: null),
    );
    try {
      if (current.reason.trim() != current.savedReason.trim()) {
        final saved = await ref
            .read(visitPreparationApiProvider)
            .save(subject.id, current.reason.trim());
        final latest = state.requireValue;
        state = AsyncValue.data(
          latest.copyWith(reason: saved.reason, savedReason: saved.reason),
        );
      }
      final result = await ref
          .read(summaryRepositoryProvider)
          .regenerate(subjectId: subject.id);
      var status = result.status;
      for (
        var attempt = 0;
        attempt < 45 && !const {'succeeded', 'failed'}.contains(status);
        attempt++
      ) {
        await Future<void>.delayed(const Duration(seconds: 2));
        status = await ref
            .read(summaryRepositoryProvider)
            .getJobStatus(result.jobId);
      }
      if (status != 'succeeded') {
        throw StateError('summary_regenerate_failed:$status');
      }
      final refreshed = await ref
          .read(summaryRepositoryProvider)
          .getCurrentSummary(subjectId: subject.id);
      final latest = state.requireValue;
      state = AsyncValue.data(
        latest.copyWith(
          loadResult: refreshed,
          isRegenerating: false,
          actionError: null,
        ),
      );
    } on Object catch (error) {
      final latest = state.requireValue;
      state = AsyncValue.data(
        latest.copyWith(
          isRegenerating: false,
          actionError: error.toString(),
          queuedMessage: null,
        ),
      );
    }
  }

  Future<bool> updateReason(String reason) async {
    final current = state.value;
    final subject = current?.subject;
    if (current == null ||
        subject == null ||
        current.isSavingReason ||
        current.isRegenerating ||
        current.isRefreshing) {
      return false;
    }
    final normalized = reason.trim();
    state = AsyncValue.data(
      current.copyWith(isSavingReason: true, actionError: null),
    );
    try {
      final saved = await ref
          .read(visitPreparationApiProvider)
          .save(subject.id, normalized);
      final latest = state.requireValue;
      state = AsyncValue.data(
        latest.copyWith(
          reason: saved.reason,
          savedReason: saved.reason,
          isSavingReason: false,
          actionError: null,
        ),
      );
      return true;
    } on Object {
      final latest = state.requireValue;
      state = AsyncValue.data(
        latest.copyWith(
          isSavingReason: false,
          actionError: 'visit_reason_save_failed',
        ),
      );
      return false;
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

  Future<SummaryState> _load(
    SummaryState current, {
    bool loadReason = false,
  }) async {
    final subject = current.subject;
    if (subject == null) {
      return current.copyWith(isRefreshing: false);
    }
    final repository = ref.read(summaryRepositoryProvider);
    final summaryFuture = repository.getCurrentSummary(subjectId: subject.id);
    final reasonFuture = loadReason
        ? ref.read(visitPreparationApiProvider).get(subject.id)
        : null;
    final result = await summaryFuture;
    var reason = current.reason;
    if (reasonFuture != null) {
      try {
        reason = (await reasonFuture).reason;
      } on Object {
        // A summary can still be useful when its optional visit reason cannot load.
      }
    }
    return current.copyWith(
      loadResult: result,
      reason: reason,
      savedReason: loadReason ? reason : current.savedReason,
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
    this.reason = '',
    this.savedReason = '',
    this.isSavingReason = false,
  });

  final Subject? subject;
  final SummaryLoadResult loadResult;
  final bool isRefreshing;
  final bool isRegenerating;
  final bool isExporting;
  final bool exportCompleted;
  final String? queuedMessage;
  final String? actionError;
  final String reason;
  final String savedReason;
  final bool isSavingReason;

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
    String? reason,
    String? savedReason,
    bool? isSavingReason,
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
      reason: reason ?? this.reason,
      savedReason: savedReason ?? this.savedReason,
      isSavingReason: isSavingReason ?? this.isSavingReason,
    );
  }
}
