import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_database.dart' as db;
import '../domain/subject.dart';
import 'subject_api.dart';
import 'subject_cache_mapper.dart';

final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return SubjectRepository(
    api: ref.watch(subjectApiProvider),
    database: ref.watch(db.localDatabaseProvider),
  );
});

class SubjectRepository {
  const SubjectRepository({required this.api, required this.database});

  final SubjectApi api;
  final db.LocalDatabase database;

  Future<List<Subject>> listSubjects({bool refresh = true}) async {
    final cached = await database.getCachedSubjects();
    if (!refresh && cached.isNotEmpty) {
      return cached.map((subject) => subject.toDomain()).toList();
    }

    try {
      final remote = await api.listSubjects();
      await database.upsertSubjects(
        remote.map((subject) => subject.toCacheCompanion()),
      );
      return remote;
    } on Object {
      if (cached.isNotEmpty) {
        return cached.map((subject) => subject.toDomain()).toList();
      }
      rethrow;
    }
  }

  Future<Subject> createSubject({
    required String displayName,
    required SubjectRelationship relationship,
    String? dateOfBirth,
    BiologicalSex? biologicalSex,
  }) async {
    final subject = await api.createSubject(
      displayName: displayName,
      relationship: relationship,
      dateOfBirth: dateOfBirth,
      biologicalSex: biologicalSex,
    );
    await database.upsertSubjects([subject.toCacheCompanion()]);
    return subject;
  }

  Future<Subject> updateSubject(
    String id, {
    String? displayName,
    SubjectRelationship? relationship,
    String? dateOfBirth,
    BiologicalSex? biologicalSex,
  }) async {
    final subject = await api.updateSubject(
      id,
      displayName: displayName,
      relationship: relationship,
      dateOfBirth: dateOfBirth,
      biologicalSex: biologicalSex,
    );
    await database.upsertSubjects([subject.toCacheCompanion()]);
    return subject;
  }

  Future<void> deleteSubject(Subject subject) async {
    await api.deleteSubject(subject.id);
    await database.removeSubject(subject.id);
  }
}
