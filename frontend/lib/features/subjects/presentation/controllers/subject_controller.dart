import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/subject_repository.dart';
import '../../domain/subject.dart';

final subjectControllerProvider =
    AsyncNotifierProvider<SubjectController, SubjectState>(
      SubjectController.new,
    );

class SubjectController extends AsyncNotifier<SubjectState> {
  @override
  Future<SubjectState> build() async {
    final subjects = await ref.watch(subjectRepositoryProvider).listSubjects();
    return SubjectState(
      subjects: subjects,
      selectedSubjectId: subjects.firstOrNull?.id,
    );
  }

  void selectSubject(String id) {
    final current = state.hasValue ? state.value : null;
    if (current == null) {
      return;
    }
    state = AsyncValue.data(current.copyWith(selectedSubjectId: id));
  }

  Future<void> refresh() async {
    final current = state.hasValue ? state.value : null;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final subjects = await ref
          .read(subjectRepositoryProvider)
          .listSubjects(refresh: true);
      final selectedId = current?.selectedSubjectId;
      final selectedStillExists = subjects.any(
        (subject) => subject.id == selectedId,
      );
      return SubjectState(
        subjects: subjects,
        selectedSubjectId: selectedStillExists
            ? selectedId
            : subjects.firstOrNull?.id,
      );
    });
  }

  Future<void> createSubject({
    required String displayName,
    required SubjectRelationship relationship,
  }) async {
    final repository = ref.read(subjectRepositoryProvider);
    final created = await repository.createSubject(
      displayName: displayName,
      relationship: relationship,
    );
    final subjects = await repository.listSubjects(refresh: true);
    state = AsyncValue.data(
      SubjectState(subjects: subjects, selectedSubjectId: created.id),
    );
  }
}

class SubjectState {
  const SubjectState({required this.subjects, required this.selectedSubjectId});

  final List<Subject> subjects;
  final String? selectedSubjectId;

  Subject? get selectedSubject {
    final selectedId = selectedSubjectId;
    if (selectedId == null) {
      return null;
    }
    return subjects.where((subject) => subject.id == selectedId).firstOrNull;
  }

  SubjectState copyWith({List<Subject>? subjects, String? selectedSubjectId}) {
    return SubjectState(
      subjects: subjects ?? this.subjects,
      selectedSubjectId: selectedSubjectId ?? this.selectedSubjectId,
    );
  }
}
