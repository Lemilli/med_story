import 'package:drift/drift.dart';

import '../../../core/storage/local_database.dart' as db;
import '../domain/medical_event.dart';

extension MedicalEventCacheMapper on MedicalEvent {
  db.CachedMedicalEventsCompanion toCacheCompanion() {
    return db.CachedMedicalEventsCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      eventType: Value(eventType.apiName),
      title: Value(title),
      description: Value(description),
      eventDate: Value(eventDate),
      eventEndDate: Value(eventEndDate),
      attributesJson: Value(db.encodeJson(attributes)),
      source: Value(_sourceApiName(source)),
      sourceDocumentId: Value(sourceDocumentId),
      sourceText: Value(sourceText),
      sourceAssetCount: Value(sourceAssetCount),
      sourcePagePositionsJson: Value(db.encodeJson(sourcePagePositions)),
      confidence: Value(confidence),
      tagsJson: Value(db.encodeJson(tags)),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(DateTime.now().toUtc()),
    );
  }
}

extension CachedMedicalEventMapper on db.CachedMedicalEvent {
  MedicalEvent toDomain() {
    return MedicalEvent(
      id: id,
      eventType: _eventTypeFromApiName(eventType),
      title: title,
      description: description,
      eventDate: eventDate,
      eventEndDate: eventEndDate,
      attributes: db.decodeJsonObject(attributesJson),
      source: _sourceFromApiName(source),
      sourceDocumentId: sourceDocumentId,
      sourceText: sourceText,
      sourceAssetCount: sourceAssetCount,
      sourcePagePositions: db
          .decodeJsonList(sourcePagePositionsJson)
          .whereType<num>()
          .map((value) => value.toInt())
          .toList(growable: false),
      confidence: confidence,
      tags: db.decodeStringList(tagsJson),
      subjectId: subjectId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

MedicalEventType _eventTypeFromApiName(String value) {
  return MedicalEventType.values.firstWhere(
    (type) => type.apiName == value,
    orElse: () => MedicalEventType.note,
  );
}

EventSource _sourceFromApiName(String value) {
  return switch (value) {
    'ai_document' => EventSource.aiDocument,
    'ai_voice' => EventSource.aiVoice,
    _ => EventSource.userManual,
  };
}

String _sourceApiName(EventSource source) {
  return switch (source) {
    EventSource.userManual => 'user_manual',
    EventSource.aiDocument => 'ai_document',
    EventSource.aiVoice => 'ai_voice',
  };
}
