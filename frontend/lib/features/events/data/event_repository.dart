import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_database.dart' as db;
import 'event_api.dart';
import 'medical_event_cache_mapper.dart';
import '../domain/medical_event.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(
    api: ref.watch(eventApiProvider),
    database: ref.watch(db.localDatabaseProvider),
  );
});

class EventRepository {
  const EventRepository({required this.api, required this.database});

  final EventApi api;
  final db.LocalDatabase database;

  Future<MedicalEvent> getEvent(String id) async {
    try {
      final event = await api.getEvent(id);
      await database.upsertEvents([event.toCacheCompanion()]);
      return event;
    } on Object {
      final cached = await database.getEvent(id);
      if (cached != null) {
        return cached.toDomain();
      }
      rethrow;
    }
  }

  Future<MedicalEvent> createEvent(EventWriteRequest request) async {
    final event = await api.createEvent(request);
    await database.upsertEvents([event.toCacheCompanion()]);
    return event;
  }

  Future<MedicalEvent> updateEvent(String id, EventWriteRequest request) async {
    final event = await api.updateEvent(id, request);
    await database.upsertEvents([event.toCacheCompanion()]);
    return event;
  }

  Future<void> deleteEvent(String id) async {
    await api.deleteEvent(id);
    await database.removeEvent(id);
  }

  Future<EventRevision> regenerateEvent(String id) => api.regenerateEvent(id);

  Future<MedicalEvent> applyRevision(
    String eventId,
    String revisionId,
    List<String> fields,
  ) async {
    final event = await api.applyRevision(eventId, revisionId, fields);
    await database.upsertEvents([event.toCacheCompanion()]);
    return event;
  }

  Future<void> discardRevision(String eventId, String revisionId) =>
      api.discardRevision(eventId, revisionId);
}
