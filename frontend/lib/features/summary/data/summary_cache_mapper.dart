import 'package:drift/drift.dart';

import '../../../core/storage/local_database.dart' as db;
import '../domain/medical_summary.dart';

extension MedicalSummaryCacheMapper on MedicalSummary {
  db.CachedMedicalSummariesCompanion toCacheCompanion() {
    final now = DateTime.now().toUtc();
    return db.CachedMedicalSummariesCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      version: Value(version),
      isCurrent: Value(isCurrent),
      contentJson: Value(db.encodeJson(content)),
      narrativeText: Value(narrativeText),
      language: Value(language),
      generatedFromEventCount: Value(generatedFromEventCount),
      createdAt: Value(createdAt),
      syncedAt: Value(now),
    );
  }
}

extension CachedMedicalSummaryMapper on db.CachedMedicalSummary {
  MedicalSummary toDomain() {
    return MedicalSummary(
      id: id,
      subjectId: subjectId,
      version: version,
      isCurrent: isCurrent,
      content: db.decodeJsonObject(contentJson),
      narrativeText: narrativeText,
      language: language,
      generatedFromEventCount: generatedFromEventCount,
      createdAt: createdAt,
    );
  }
}
