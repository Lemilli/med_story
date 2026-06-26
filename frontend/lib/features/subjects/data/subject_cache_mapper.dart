import 'package:drift/drift.dart';

import '../../../core/storage/local_database.dart' as db;
import '../domain/subject.dart';

extension SubjectCacheMapper on Subject {
  db.SubjectsCompanion toCacheCompanion() {
    return db.SubjectsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      relationship: Value(relationship.name),
      dateOfBirth: Value(dateOfBirth),
      biologicalSex: Value(biologicalSex?.name),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(DateTime.now().toUtc()),
    );
  }
}

extension CachedSubjectMapper on db.Subject {
  Subject toDomain() {
    return Subject(
      id: id,
      displayName: displayName,
      relationship: SubjectRelationship.values.byName(relationship),
      dateOfBirth: dateOfBirth,
      biologicalSex: biologicalSex == null
          ? null
          : BiologicalSex.values.byName(biologicalSex!),
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
