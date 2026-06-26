import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

part 'local_database.g.dart';

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  final database = LocalDatabase();
  ref.onDispose(database.close);
  return database;
});

class Subjects extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get relationship => text()();
  TextColumn get dateOfBirth => text().nullable()();
  TextColumn get biologicalSex => text().nullable()();
  BoolColumn get isDefault => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedMedicalEvents extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text()();
  TextColumn get eventType => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get eventDate => text()();
  TextColumn get eventEndDate => text().nullable()();
  TextColumn get attributesJson => text()();
  TextColumn get source => text()();
  TextColumn get sourceDocumentId => text().nullable()();
  RealColumn get confidence => real().nullable()();
  BoolColumn get isConfirmed => boolean()();
  TextColumn get tagsJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Subjects, CachedMedicalEvents])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @visibleForTesting
  LocalDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Future<void> clearAll() async {
    await transaction(() async {
      await delete(cachedMedicalEvents).go();
      await delete(subjects).go();
    });
  }

  Future<void> upsertSubjects(Iterable<SubjectsCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(subjects, rows.toList());
    });
  }

  Future<void> upsertEvents(Iterable<CachedMedicalEventsCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(cachedMedicalEvents, rows.toList());
    });
  }

  Future<void> removeEvent(String id) {
    return (delete(
      cachedMedicalEvents,
    )..where((event) => event.id.equals(id))).go();
  }

  Future<void> removeSubject(String id) async {
    await transaction(() async {
      await (delete(
        cachedMedicalEvents,
      )..where((event) => event.subjectId.equals(id))).go();
      await (delete(subjects)..where((subject) => subject.id.equals(id))).go();
    });
  }

  Future<List<Subject>> getCachedSubjects() {
    return (select(subjects)..orderBy([
          (subject) => OrderingTerm(
            expression: subject.isDefault,
            mode: OrderingMode.desc,
          ),
          (subject) => OrderingTerm(expression: subject.displayName),
        ]))
        .get();
  }

  Stream<List<CachedMedicalEvent>> watchEvents({
    required String subjectId,
    String? query,
    Set<String> types = const {},
    DateTime? from,
    DateTime? to,
    String? tag,
  }) {
    final statement = select(cachedMedicalEvents)
      ..where((event) => event.subjectId.equals(subjectId));

    if (types.isNotEmpty) {
      statement.where((event) => event.eventType.isIn(types));
    }
    if (from != null) {
      statement.where(
        (event) => event.eventDate.isBiggerOrEqualValue(_dateOnly(from)),
      );
    }
    if (to != null) {
      statement.where(
        (event) => event.eventDate.isSmallerOrEqualValue(_dateOnly(to)),
      );
    }
    final trimmedQuery = query?.trim();
    if (trimmedQuery != null && trimmedQuery.isNotEmpty) {
      statement.where(
        (event) =>
            event.title.like('%$trimmedQuery%') |
            event.description.like('%$trimmedQuery%'),
      );
    }
    final trimmedTag = tag?.trim().toLowerCase();
    if (trimmedTag != null && trimmedTag.isNotEmpty) {
      statement.where((event) => event.tagsJson.like('%"$trimmedTag"%'));
    }

    statement.orderBy([
      (event) =>
          OrderingTerm(expression: event.eventDate, mode: OrderingMode.desc),
      (event) =>
          OrderingTerm(expression: event.createdAt, mode: OrderingMode.desc),
    ]);

    return statement.watch();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/med_story.sqlite');
    return NativeDatabase.createInBackground(file);
  });
}

String _dateOnly(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String encodeJson(Object value) => jsonEncode(value);

Map<String, dynamic> decodeJsonObject(String value) {
  final decoded = jsonDecode(value);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  return <String, dynamic>{};
}

List<String> decodeStringList(String value) {
  final decoded = jsonDecode(value);
  if (decoded is List) {
    return decoded.whereType<String>().toList();
  }
  return const [];
}
