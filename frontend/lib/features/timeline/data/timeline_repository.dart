import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_database.dart' as db;
import '../../events/data/medical_event_cache_mapper.dart';
import '../../events/domain/medical_event.dart';
import '../domain/timeline_filters.dart';
import 'timeline_api.dart';

final timelineRepositoryProvider = Provider<TimelineRepository>((ref) {
  return TimelineRepository(
    api: ref.watch(timelineApiProvider),
    database: ref.watch(db.localDatabaseProvider),
  );
});

class TimelineRepository {
  const TimelineRepository({required this.api, required this.database});

  final TimelineApi api;
  final db.LocalDatabase database;

  Stream<List<MedicalEvent>> watchTimeline({
    required String subjectId,
    TimelineFilters filters = const TimelineFilters(),
  }) {
    return database
        .watchEvents(
          subjectId: subjectId,
          query: filters.query,
          types: filters.types.map((type) => type.apiName).toSet(),
          from: filters.from,
          to: filters.to,
          tag: filters.tag,
        )
        .map((rows) => rows.map((event) => event.toDomain()).toList());
  }

  Future<TimelinePage> refreshTimeline({
    required String subjectId,
    TimelineFilters filters = const TimelineFilters(),
    String? cursor,
    int limit = 20,
  }) async {
    final page = await api.fetchTimeline(
      subjectId: subjectId,
      filters: filters,
      cursor: cursor,
      limit: limit,
    );
    final rows = page.results.map((event) => event.toCacheCompanion());
    if (cursor == null) {
      await database.replaceEventsForSubject(subjectId, rows);
    } else {
      await database.upsertEvents(rows);
    }
    return page;
  }
}
