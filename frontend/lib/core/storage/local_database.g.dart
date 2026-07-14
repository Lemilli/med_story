// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationshipMeta = const VerificationMeta(
    'relationship',
  );
  @override
  late final GeneratedColumn<String> relationship = GeneratedColumn<String>(
    'relationship',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<String> dateOfBirth = GeneratedColumn<String>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _biologicalSexMeta = const VerificationMeta(
    'biologicalSex',
  );
  @override
  late final GeneratedColumn<String> biologicalSex = GeneratedColumn<String>(
    'biological_sex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    relationship,
    dateOfBirth,
    biologicalSex,
    isDefault,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('relationship')) {
      context.handle(
        _relationshipMeta,
        relationship.isAcceptableOrUnknown(
          data['relationship']!,
          _relationshipMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relationshipMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('biological_sex')) {
      context.handle(
        _biologicalSexMeta,
        biologicalSex.isAcceptableOrUnknown(
          data['biological_sex']!,
          _biologicalSexMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    } else if (isInserting) {
      context.missing(_isDefaultMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      relationship: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship'],
      )!,
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_of_birth'],
      ),
      biologicalSex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}biological_sex'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final String id;
  final String displayName;
  final String relationship;
  final String? dateOfBirth;
  final String? biologicalSex;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const Subject({
    required this.id,
    required this.displayName,
    required this.relationship,
    this.dateOfBirth,
    this.biologicalSex,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['relationship'] = Variable<String>(relationship);
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<String>(dateOfBirth);
    }
    if (!nullToAbsent || biologicalSex != null) {
      map['biological_sex'] = Variable<String>(biologicalSex);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      relationship: Value(relationship),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      biologicalSex: biologicalSex == null && nullToAbsent
          ? const Value.absent()
          : Value(biologicalSex),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory Subject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      relationship: serializer.fromJson<String>(json['relationship']),
      dateOfBirth: serializer.fromJson<String?>(json['dateOfBirth']),
      biologicalSex: serializer.fromJson<String?>(json['biologicalSex']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'relationship': serializer.toJson<String>(relationship),
      'dateOfBirth': serializer.toJson<String?>(dateOfBirth),
      'biologicalSex': serializer.toJson<String?>(biologicalSex),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  Subject copyWith({
    String? id,
    String? displayName,
    String? relationship,
    Value<String?> dateOfBirth = const Value.absent(),
    Value<String?> biologicalSex = const Value.absent(),
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => Subject(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    relationship: relationship ?? this.relationship,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    biologicalSex: biologicalSex.present
        ? biologicalSex.value
        : this.biologicalSex,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      relationship: data.relationship.present
          ? data.relationship.value
          : this.relationship,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      biologicalSex: data.biologicalSex.present
          ? data.biologicalSex.value
          : this.biologicalSex,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('relationship: $relationship, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('biologicalSex: $biologicalSex, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    relationship,
    dateOfBirth,
    biologicalSex,
    isDefault,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.relationship == this.relationship &&
          other.dateOfBirth == this.dateOfBirth &&
          other.biologicalSex == this.biologicalSex &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> relationship;
  final Value<String?> dateOfBirth;
  final Value<String?> biologicalSex;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.relationship = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.biologicalSex = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubjectsCompanion.insert({
    required String id,
    required String displayName,
    required String relationship,
    this.dateOfBirth = const Value.absent(),
    this.biologicalSex = const Value.absent(),
    required bool isDefault,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       relationship = Value(relationship),
       isDefault = Value(isDefault),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<Subject> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? relationship,
    Expression<String>? dateOfBirth,
    Expression<String>? biologicalSex,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (relationship != null) 'relationship': relationship,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (biologicalSex != null) 'biological_sex': biologicalSex,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String>? relationship,
    Value<String?>? dateOfBirth,
    Value<String?>? biologicalSex,
    Value<bool>? isDefault,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return SubjectsCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      relationship: relationship ?? this.relationship,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      biologicalSex: biologicalSex ?? this.biologicalSex,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (relationship.present) {
      map['relationship'] = Variable<String>(relationship.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<String>(dateOfBirth.value);
    }
    if (biologicalSex.present) {
      map['biological_sex'] = Variable<String>(biologicalSex.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('relationship: $relationship, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('biologicalSex: $biologicalSex, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedMedicalEventsTable extends CachedMedicalEvents
    with TableInfo<$CachedMedicalEventsTable, CachedMedicalEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMedicalEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventDateMeta = const VerificationMeta(
    'eventDate',
  );
  @override
  late final GeneratedColumn<String> eventDate = GeneratedColumn<String>(
    'event_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventEndDateMeta = const VerificationMeta(
    'eventEndDate',
  );
  @override
  late final GeneratedColumn<String> eventEndDate = GeneratedColumn<String>(
    'event_end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attributesJsonMeta = const VerificationMeta(
    'attributesJson',
  );
  @override
  late final GeneratedColumn<String> attributesJson = GeneratedColumn<String>(
    'attributes_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceDocumentIdMeta = const VerificationMeta(
    'sourceDocumentId',
  );
  @override
  late final GeneratedColumn<String> sourceDocumentId = GeneratedColumn<String>(
    'source_document_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectId,
    eventType,
    title,
    description,
    eventDate,
    eventEndDate,
    attributesJson,
    source,
    sourceDocumentId,
    confidence,
    tagsJson,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_medical_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedMedicalEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('event_date')) {
      context.handle(
        _eventDateMeta,
        eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta),
      );
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('event_end_date')) {
      context.handle(
        _eventEndDateMeta,
        eventEndDate.isAcceptableOrUnknown(
          data['event_end_date']!,
          _eventEndDateMeta,
        ),
      );
    }
    if (data.containsKey('attributes_json')) {
      context.handle(
        _attributesJsonMeta,
        attributesJson.isAcceptableOrUnknown(
          data['attributes_json']!,
          _attributesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attributesJsonMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('source_document_id')) {
      context.handle(
        _sourceDocumentIdMeta,
        sourceDocumentId.isAcceptableOrUnknown(
          data['source_document_id']!,
          _sourceDocumentIdMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_tagsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedMedicalEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMedicalEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      eventDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_date'],
      )!,
      eventEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_end_date'],
      ),
      attributesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attributes_json'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceDocumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_document_id'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedMedicalEventsTable createAlias(String alias) {
    return $CachedMedicalEventsTable(attachedDatabase, alias);
  }
}

class CachedMedicalEvent extends DataClass
    implements Insertable<CachedMedicalEvent> {
  final String id;
  final String subjectId;
  final String eventType;
  final String title;
  final String description;
  final String eventDate;
  final String? eventEndDate;
  final String attributesJson;
  final String source;
  final String? sourceDocumentId;
  final double? confidence;
  final String tagsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime syncedAt;
  const CachedMedicalEvent({
    required this.id,
    required this.subjectId,
    required this.eventType,
    required this.title,
    required this.description,
    required this.eventDate,
    this.eventEndDate,
    required this.attributesJson,
    required this.source,
    this.sourceDocumentId,
    this.confidence,
    required this.tagsJson,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['event_type'] = Variable<String>(eventType);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['event_date'] = Variable<String>(eventDate);
    if (!nullToAbsent || eventEndDate != null) {
      map['event_end_date'] = Variable<String>(eventEndDate);
    }
    map['attributes_json'] = Variable<String>(attributesJson);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceDocumentId != null) {
      map['source_document_id'] = Variable<String>(sourceDocumentId);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['tags_json'] = Variable<String>(tagsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedMedicalEventsCompanion toCompanion(bool nullToAbsent) {
    return CachedMedicalEventsCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      eventType: Value(eventType),
      title: Value(title),
      description: Value(description),
      eventDate: Value(eventDate),
      eventEndDate: eventEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(eventEndDate),
      attributesJson: Value(attributesJson),
      source: Value(source),
      sourceDocumentId: sourceDocumentId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDocumentId),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      tagsJson: Value(tagsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedMedicalEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMedicalEvent(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      eventDate: serializer.fromJson<String>(json['eventDate']),
      eventEndDate: serializer.fromJson<String?>(json['eventEndDate']),
      attributesJson: serializer.fromJson<String>(json['attributesJson']),
      source: serializer.fromJson<String>(json['source']),
      sourceDocumentId: serializer.fromJson<String?>(json['sourceDocumentId']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'eventType': serializer.toJson<String>(eventType),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'eventDate': serializer.toJson<String>(eventDate),
      'eventEndDate': serializer.toJson<String?>(eventEndDate),
      'attributesJson': serializer.toJson<String>(attributesJson),
      'source': serializer.toJson<String>(source),
      'sourceDocumentId': serializer.toJson<String?>(sourceDocumentId),
      'confidence': serializer.toJson<double?>(confidence),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedMedicalEvent copyWith({
    String? id,
    String? subjectId,
    String? eventType,
    String? title,
    String? description,
    String? eventDate,
    Value<String?> eventEndDate = const Value.absent(),
    String? attributesJson,
    String? source,
    Value<String?> sourceDocumentId = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    String? tagsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) => CachedMedicalEvent(
    id: id ?? this.id,
    subjectId: subjectId ?? this.subjectId,
    eventType: eventType ?? this.eventType,
    title: title ?? this.title,
    description: description ?? this.description,
    eventDate: eventDate ?? this.eventDate,
    eventEndDate: eventEndDate.present ? eventEndDate.value : this.eventEndDate,
    attributesJson: attributesJson ?? this.attributesJson,
    source: source ?? this.source,
    sourceDocumentId: sourceDocumentId.present
        ? sourceDocumentId.value
        : this.sourceDocumentId,
    confidence: confidence.present ? confidence.value : this.confidence,
    tagsJson: tagsJson ?? this.tagsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedMedicalEvent copyWithCompanion(CachedMedicalEventsCompanion data) {
    return CachedMedicalEvent(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      eventEndDate: data.eventEndDate.present
          ? data.eventEndDate.value
          : this.eventEndDate,
      attributesJson: data.attributesJson.present
          ? data.attributesJson.value
          : this.attributesJson,
      source: data.source.present ? data.source.value : this.source,
      sourceDocumentId: data.sourceDocumentId.present
          ? data.sourceDocumentId.value
          : this.sourceDocumentId,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMedicalEvent(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('eventType: $eventType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('eventDate: $eventDate, ')
          ..write('eventEndDate: $eventEndDate, ')
          ..write('attributesJson: $attributesJson, ')
          ..write('source: $source, ')
          ..write('sourceDocumentId: $sourceDocumentId, ')
          ..write('confidence: $confidence, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subjectId,
    eventType,
    title,
    description,
    eventDate,
    eventEndDate,
    attributesJson,
    source,
    sourceDocumentId,
    confidence,
    tagsJson,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMedicalEvent &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.eventType == this.eventType &&
          other.title == this.title &&
          other.description == this.description &&
          other.eventDate == this.eventDate &&
          other.eventEndDate == this.eventEndDate &&
          other.attributesJson == this.attributesJson &&
          other.source == this.source &&
          other.sourceDocumentId == this.sourceDocumentId &&
          other.confidence == this.confidence &&
          other.tagsJson == this.tagsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class CachedMedicalEventsCompanion extends UpdateCompanion<CachedMedicalEvent> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String> eventType;
  final Value<String> title;
  final Value<String> description;
  final Value<String> eventDate;
  final Value<String?> eventEndDate;
  final Value<String> attributesJson;
  final Value<String> source;
  final Value<String?> sourceDocumentId;
  final Value<double?> confidence;
  final Value<String> tagsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedMedicalEventsCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.eventEndDate = const Value.absent(),
    this.attributesJson = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceDocumentId = const Value.absent(),
    this.confidence = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedMedicalEventsCompanion.insert({
    required String id,
    required String subjectId,
    required String eventType,
    required String title,
    required String description,
    required String eventDate,
    this.eventEndDate = const Value.absent(),
    required String attributesJson,
    required String source,
    this.sourceDocumentId = const Value.absent(),
    this.confidence = const Value.absent(),
    required String tagsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       subjectId = Value(subjectId),
       eventType = Value(eventType),
       title = Value(title),
       description = Value(description),
       eventDate = Value(eventDate),
       attributesJson = Value(attributesJson),
       source = Value(source),
       tagsJson = Value(tagsJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedMedicalEvent> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? eventType,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? eventDate,
    Expression<String>? eventEndDate,
    Expression<String>? attributesJson,
    Expression<String>? source,
    Expression<String>? sourceDocumentId,
    Expression<double>? confidence,
    Expression<String>? tagsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (eventType != null) 'event_type': eventType,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (eventDate != null) 'event_date': eventDate,
      if (eventEndDate != null) 'event_end_date': eventEndDate,
      if (attributesJson != null) 'attributes_json': attributesJson,
      if (source != null) 'source': source,
      if (sourceDocumentId != null) 'source_document_id': sourceDocumentId,
      if (confidence != null) 'confidence': confidence,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedMedicalEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? subjectId,
    Value<String>? eventType,
    Value<String>? title,
    Value<String>? description,
    Value<String>? eventDate,
    Value<String?>? eventEndDate,
    Value<String>? attributesJson,
    Value<String>? source,
    Value<String?>? sourceDocumentId,
    Value<double?>? confidence,
    Value<String>? tagsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedMedicalEventsCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      eventType: eventType ?? this.eventType,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      eventEndDate: eventEndDate ?? this.eventEndDate,
      attributesJson: attributesJson ?? this.attributesJson,
      source: source ?? this.source,
      sourceDocumentId: sourceDocumentId ?? this.sourceDocumentId,
      confidence: confidence ?? this.confidence,
      tagsJson: tagsJson ?? this.tagsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<String>(eventDate.value);
    }
    if (eventEndDate.present) {
      map['event_end_date'] = Variable<String>(eventEndDate.value);
    }
    if (attributesJson.present) {
      map['attributes_json'] = Variable<String>(attributesJson.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceDocumentId.present) {
      map['source_document_id'] = Variable<String>(sourceDocumentId.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMedicalEventsCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('eventType: $eventType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('eventDate: $eventDate, ')
          ..write('eventEndDate: $eventEndDate, ')
          ..write('attributesJson: $attributesJson, ')
          ..write('source: $source, ')
          ..write('sourceDocumentId: $sourceDocumentId, ')
          ..write('confidence: $confidence, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedMedicalSummariesTable extends CachedMedicalSummaries
    with TableInfo<$CachedMedicalSummariesTable, CachedMedicalSummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMedicalSummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCurrentMeta = const VerificationMeta(
    'isCurrent',
  );
  @override
  late final GeneratedColumn<bool> isCurrent = GeneratedColumn<bool>(
    'is_current',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_current" IN (0, 1))',
    ),
  );
  static const VerificationMeta _contentJsonMeta = const VerificationMeta(
    'contentJson',
  );
  @override
  late final GeneratedColumn<String> contentJson = GeneratedColumn<String>(
    'content_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _narrativeTextMeta = const VerificationMeta(
    'narrativeText',
  );
  @override
  late final GeneratedColumn<String> narrativeText = GeneratedColumn<String>(
    'narrative_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedFromEventCountMeta =
      const VerificationMeta('generatedFromEventCount');
  @override
  late final GeneratedColumn<int> generatedFromEventCount =
      GeneratedColumn<int>(
        'generated_from_event_count',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectId,
    version,
    isCurrent,
    contentJson,
    narrativeText,
    language,
    generatedFromEventCount,
    createdAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_medical_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedMedicalSummary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('is_current')) {
      context.handle(
        _isCurrentMeta,
        isCurrent.isAcceptableOrUnknown(data['is_current']!, _isCurrentMeta),
      );
    } else if (isInserting) {
      context.missing(_isCurrentMeta);
    }
    if (data.containsKey('content_json')) {
      context.handle(
        _contentJsonMeta,
        contentJson.isAcceptableOrUnknown(
          data['content_json']!,
          _contentJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentJsonMeta);
    }
    if (data.containsKey('narrative_text')) {
      context.handle(
        _narrativeTextMeta,
        narrativeText.isAcceptableOrUnknown(
          data['narrative_text']!,
          _narrativeTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_narrativeTextMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('generated_from_event_count')) {
      context.handle(
        _generatedFromEventCountMeta,
        generatedFromEventCount.isAcceptableOrUnknown(
          data['generated_from_event_count']!,
          _generatedFromEventCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedFromEventCountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedMedicalSummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMedicalSummary(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isCurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_current'],
      )!,
      contentJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_json'],
      )!,
      narrativeText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}narrative_text'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      generatedFromEventCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generated_from_event_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedMedicalSummariesTable createAlias(String alias) {
    return $CachedMedicalSummariesTable(attachedDatabase, alias);
  }
}

class CachedMedicalSummary extends DataClass
    implements Insertable<CachedMedicalSummary> {
  final String id;
  final String subjectId;
  final int version;
  final bool isCurrent;
  final String contentJson;
  final String narrativeText;
  final String language;
  final int generatedFromEventCount;
  final DateTime? createdAt;
  final DateTime syncedAt;
  const CachedMedicalSummary({
    required this.id,
    required this.subjectId,
    required this.version,
    required this.isCurrent,
    required this.contentJson,
    required this.narrativeText,
    required this.language,
    required this.generatedFromEventCount,
    this.createdAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['version'] = Variable<int>(version);
    map['is_current'] = Variable<bool>(isCurrent);
    map['content_json'] = Variable<String>(contentJson);
    map['narrative_text'] = Variable<String>(narrativeText);
    map['language'] = Variable<String>(language);
    map['generated_from_event_count'] = Variable<int>(generatedFromEventCount);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedMedicalSummariesCompanion toCompanion(bool nullToAbsent) {
    return CachedMedicalSummariesCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      version: Value(version),
      isCurrent: Value(isCurrent),
      contentJson: Value(contentJson),
      narrativeText: Value(narrativeText),
      language: Value(language),
      generatedFromEventCount: Value(generatedFromEventCount),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedMedicalSummary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMedicalSummary(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      version: serializer.fromJson<int>(json['version']),
      isCurrent: serializer.fromJson<bool>(json['isCurrent']),
      contentJson: serializer.fromJson<String>(json['contentJson']),
      narrativeText: serializer.fromJson<String>(json['narrativeText']),
      language: serializer.fromJson<String>(json['language']),
      generatedFromEventCount: serializer.fromJson<int>(
        json['generatedFromEventCount'],
      ),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'version': serializer.toJson<int>(version),
      'isCurrent': serializer.toJson<bool>(isCurrent),
      'contentJson': serializer.toJson<String>(contentJson),
      'narrativeText': serializer.toJson<String>(narrativeText),
      'language': serializer.toJson<String>(language),
      'generatedFromEventCount': serializer.toJson<int>(
        generatedFromEventCount,
      ),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedMedicalSummary copyWith({
    String? id,
    String? subjectId,
    int? version,
    bool? isCurrent,
    String? contentJson,
    String? narrativeText,
    String? language,
    int? generatedFromEventCount,
    Value<DateTime?> createdAt = const Value.absent(),
    DateTime? syncedAt,
  }) => CachedMedicalSummary(
    id: id ?? this.id,
    subjectId: subjectId ?? this.subjectId,
    version: version ?? this.version,
    isCurrent: isCurrent ?? this.isCurrent,
    contentJson: contentJson ?? this.contentJson,
    narrativeText: narrativeText ?? this.narrativeText,
    language: language ?? this.language,
    generatedFromEventCount:
        generatedFromEventCount ?? this.generatedFromEventCount,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedMedicalSummary copyWithCompanion(CachedMedicalSummariesCompanion data) {
    return CachedMedicalSummary(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      version: data.version.present ? data.version.value : this.version,
      isCurrent: data.isCurrent.present ? data.isCurrent.value : this.isCurrent,
      contentJson: data.contentJson.present
          ? data.contentJson.value
          : this.contentJson,
      narrativeText: data.narrativeText.present
          ? data.narrativeText.value
          : this.narrativeText,
      language: data.language.present ? data.language.value : this.language,
      generatedFromEventCount: data.generatedFromEventCount.present
          ? data.generatedFromEventCount.value
          : this.generatedFromEventCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMedicalSummary(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('version: $version, ')
          ..write('isCurrent: $isCurrent, ')
          ..write('contentJson: $contentJson, ')
          ..write('narrativeText: $narrativeText, ')
          ..write('language: $language, ')
          ..write('generatedFromEventCount: $generatedFromEventCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subjectId,
    version,
    isCurrent,
    contentJson,
    narrativeText,
    language,
    generatedFromEventCount,
    createdAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMedicalSummary &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.version == this.version &&
          other.isCurrent == this.isCurrent &&
          other.contentJson == this.contentJson &&
          other.narrativeText == this.narrativeText &&
          other.language == this.language &&
          other.generatedFromEventCount == this.generatedFromEventCount &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class CachedMedicalSummariesCompanion
    extends UpdateCompanion<CachedMedicalSummary> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<int> version;
  final Value<bool> isCurrent;
  final Value<String> contentJson;
  final Value<String> narrativeText;
  final Value<String> language;
  final Value<int> generatedFromEventCount;
  final Value<DateTime?> createdAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedMedicalSummariesCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.version = const Value.absent(),
    this.isCurrent = const Value.absent(),
    this.contentJson = const Value.absent(),
    this.narrativeText = const Value.absent(),
    this.language = const Value.absent(),
    this.generatedFromEventCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedMedicalSummariesCompanion.insert({
    required String id,
    required String subjectId,
    required int version,
    required bool isCurrent,
    required String contentJson,
    required String narrativeText,
    required String language,
    required int generatedFromEventCount,
    this.createdAt = const Value.absent(),
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       subjectId = Value(subjectId),
       version = Value(version),
       isCurrent = Value(isCurrent),
       contentJson = Value(contentJson),
       narrativeText = Value(narrativeText),
       language = Value(language),
       generatedFromEventCount = Value(generatedFromEventCount),
       syncedAt = Value(syncedAt);
  static Insertable<CachedMedicalSummary> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<int>? version,
    Expression<bool>? isCurrent,
    Expression<String>? contentJson,
    Expression<String>? narrativeText,
    Expression<String>? language,
    Expression<int>? generatedFromEventCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (version != null) 'version': version,
      if (isCurrent != null) 'is_current': isCurrent,
      if (contentJson != null) 'content_json': contentJson,
      if (narrativeText != null) 'narrative_text': narrativeText,
      if (language != null) 'language': language,
      if (generatedFromEventCount != null)
        'generated_from_event_count': generatedFromEventCount,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedMedicalSummariesCompanion copyWith({
    Value<String>? id,
    Value<String>? subjectId,
    Value<int>? version,
    Value<bool>? isCurrent,
    Value<String>? contentJson,
    Value<String>? narrativeText,
    Value<String>? language,
    Value<int>? generatedFromEventCount,
    Value<DateTime?>? createdAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedMedicalSummariesCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      version: version ?? this.version,
      isCurrent: isCurrent ?? this.isCurrent,
      contentJson: contentJson ?? this.contentJson,
      narrativeText: narrativeText ?? this.narrativeText,
      language: language ?? this.language,
      generatedFromEventCount:
          generatedFromEventCount ?? this.generatedFromEventCount,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isCurrent.present) {
      map['is_current'] = Variable<bool>(isCurrent.value);
    }
    if (contentJson.present) {
      map['content_json'] = Variable<String>(contentJson.value);
    }
    if (narrativeText.present) {
      map['narrative_text'] = Variable<String>(narrativeText.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (generatedFromEventCount.present) {
      map['generated_from_event_count'] = Variable<int>(
        generatedFromEventCount.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMedicalSummariesCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('version: $version, ')
          ..write('isCurrent: $isCurrent, ')
          ..write('contentJson: $contentJson, ')
          ..write('narrativeText: $narrativeText, ')
          ..write('language: $language, ')
          ..write('generatedFromEventCount: $generatedFromEventCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UploadQueueItemsTable extends UploadQueueItems
    with TableInfo<$UploadQueueItemsTable, UploadQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UploadQueueItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storedFileNameMeta = const VerificationMeta(
    'storedFileName',
  );
  @override
  late final GeneratedColumn<String> storedFileName = GeneratedColumn<String>(
    'stored_file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _docTypeMeta = const VerificationMeta(
    'docType',
  );
  @override
  late final GeneratedColumn<String> docType = GeneratedColumn<String>(
    'doc_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDismissedMeta = const VerificationMeta(
    'isDismissed',
  );
  @override
  late final GeneratedColumn<bool> isDismissed = GeneratedColumn<bool>(
    'is_dismissed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dismissed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetsJsonMeta = const VerificationMeta(
    'assetsJson',
  );
  @override
  late final GeneratedColumn<String> assetsJson = GeneratedColumn<String>(
    'assets_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    fingerprint,
    localPath,
    storedFileName,
    mimeType,
    sizeBytes,
    docType,
    title,
    subjectId,
    language,
    status,
    documentId,
    errorMessage,
    isDismissed,
    createdAt,
    updatedAt,
    assetsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'upload_queue_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<UploadQueueItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('stored_file_name')) {
      context.handle(
        _storedFileNameMeta,
        storedFileName.isAcceptableOrUnknown(
          data['stored_file_name']!,
          _storedFileNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storedFileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('doc_type')) {
      context.handle(
        _docTypeMeta,
        docType.isAcceptableOrUnknown(data['doc_type']!, _docTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_docTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('is_dismissed')) {
      context.handle(
        _isDismissedMeta,
        isDismissed.isAcceptableOrUnknown(
          data['is_dismissed']!,
          _isDismissedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('assets_json')) {
      context.handle(
        _assetsJsonMeta,
        assetsJson.isAcceptableOrUnknown(data['assets_json']!, _assetsJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UploadQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UploadQueueItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      storedFileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stored_file_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      docType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      isDismissed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dismissed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      assetsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assets_json'],
      )!,
    );
  }

  @override
  $UploadQueueItemsTable createAlias(String alias) {
    return $UploadQueueItemsTable(attachedDatabase, alias);
  }
}

class UploadQueueItem extends DataClass implements Insertable<UploadQueueItem> {
  final String id;
  final String displayName;
  final String fingerprint;
  final String localPath;
  final String storedFileName;
  final String mimeType;
  final int sizeBytes;
  final String docType;
  final String title;
  final String? subjectId;
  final String? language;
  final String status;
  final String? documentId;
  final String? errorMessage;
  final bool isDismissed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String assetsJson;
  const UploadQueueItem({
    required this.id,
    required this.displayName,
    required this.fingerprint,
    required this.localPath,
    required this.storedFileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.docType,
    required this.title,
    this.subjectId,
    this.language,
    required this.status,
    this.documentId,
    this.errorMessage,
    required this.isDismissed,
    required this.createdAt,
    required this.updatedAt,
    required this.assetsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['fingerprint'] = Variable<String>(fingerprint);
    map['local_path'] = Variable<String>(localPath);
    map['stored_file_name'] = Variable<String>(storedFileName);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['doc_type'] = Variable<String>(docType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<String>(subjectId);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || documentId != null) {
      map['document_id'] = Variable<String>(documentId);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['is_dismissed'] = Variable<bool>(isDismissed);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['assets_json'] = Variable<String>(assetsJson);
    return map;
  }

  UploadQueueItemsCompanion toCompanion(bool nullToAbsent) {
    return UploadQueueItemsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      fingerprint: Value(fingerprint),
      localPath: Value(localPath),
      storedFileName: Value(storedFileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      docType: Value(docType),
      title: Value(title),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      status: Value(status),
      documentId: documentId == null && nullToAbsent
          ? const Value.absent()
          : Value(documentId),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      isDismissed: Value(isDismissed),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      assetsJson: Value(assetsJson),
    );
  }

  factory UploadQueueItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UploadQueueItem(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      localPath: serializer.fromJson<String>(json['localPath']),
      storedFileName: serializer.fromJson<String>(json['storedFileName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      docType: serializer.fromJson<String>(json['docType']),
      title: serializer.fromJson<String>(json['title']),
      subjectId: serializer.fromJson<String?>(json['subjectId']),
      language: serializer.fromJson<String?>(json['language']),
      status: serializer.fromJson<String>(json['status']),
      documentId: serializer.fromJson<String?>(json['documentId']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      isDismissed: serializer.fromJson<bool>(json['isDismissed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      assetsJson: serializer.fromJson<String>(json['assetsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'localPath': serializer.toJson<String>(localPath),
      'storedFileName': serializer.toJson<String>(storedFileName),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'docType': serializer.toJson<String>(docType),
      'title': serializer.toJson<String>(title),
      'subjectId': serializer.toJson<String?>(subjectId),
      'language': serializer.toJson<String?>(language),
      'status': serializer.toJson<String>(status),
      'documentId': serializer.toJson<String?>(documentId),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'isDismissed': serializer.toJson<bool>(isDismissed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'assetsJson': serializer.toJson<String>(assetsJson),
    };
  }

  UploadQueueItem copyWith({
    String? id,
    String? displayName,
    String? fingerprint,
    String? localPath,
    String? storedFileName,
    String? mimeType,
    int? sizeBytes,
    String? docType,
    String? title,
    Value<String?> subjectId = const Value.absent(),
    Value<String?> language = const Value.absent(),
    String? status,
    Value<String?> documentId = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    bool? isDismissed,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assetsJson,
  }) => UploadQueueItem(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    fingerprint: fingerprint ?? this.fingerprint,
    localPath: localPath ?? this.localPath,
    storedFileName: storedFileName ?? this.storedFileName,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    docType: docType ?? this.docType,
    title: title ?? this.title,
    subjectId: subjectId.present ? subjectId.value : this.subjectId,
    language: language.present ? language.value : this.language,
    status: status ?? this.status,
    documentId: documentId.present ? documentId.value : this.documentId,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    isDismissed: isDismissed ?? this.isDismissed,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    assetsJson: assetsJson ?? this.assetsJson,
  );
  UploadQueueItem copyWithCompanion(UploadQueueItemsCompanion data) {
    return UploadQueueItem(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      storedFileName: data.storedFileName.present
          ? data.storedFileName.value
          : this.storedFileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      docType: data.docType.present ? data.docType.value : this.docType,
      title: data.title.present ? data.title.value : this.title,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      language: data.language.present ? data.language.value : this.language,
      status: data.status.present ? data.status.value : this.status,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      isDismissed: data.isDismissed.present
          ? data.isDismissed.value
          : this.isDismissed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      assetsJson: data.assetsJson.present
          ? data.assetsJson.value
          : this.assetsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UploadQueueItem(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('localPath: $localPath, ')
          ..write('storedFileName: $storedFileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('docType: $docType, ')
          ..write('title: $title, ')
          ..write('subjectId: $subjectId, ')
          ..write('language: $language, ')
          ..write('status: $status, ')
          ..write('documentId: $documentId, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('isDismissed: $isDismissed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('assetsJson: $assetsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    fingerprint,
    localPath,
    storedFileName,
    mimeType,
    sizeBytes,
    docType,
    title,
    subjectId,
    language,
    status,
    documentId,
    errorMessage,
    isDismissed,
    createdAt,
    updatedAt,
    assetsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UploadQueueItem &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.fingerprint == this.fingerprint &&
          other.localPath == this.localPath &&
          other.storedFileName == this.storedFileName &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.docType == this.docType &&
          other.title == this.title &&
          other.subjectId == this.subjectId &&
          other.language == this.language &&
          other.status == this.status &&
          other.documentId == this.documentId &&
          other.errorMessage == this.errorMessage &&
          other.isDismissed == this.isDismissed &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.assetsJson == this.assetsJson);
}

class UploadQueueItemsCompanion extends UpdateCompanion<UploadQueueItem> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> fingerprint;
  final Value<String> localPath;
  final Value<String> storedFileName;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<String> docType;
  final Value<String> title;
  final Value<String?> subjectId;
  final Value<String?> language;
  final Value<String> status;
  final Value<String?> documentId;
  final Value<String?> errorMessage;
  final Value<bool> isDismissed;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> assetsJson;
  final Value<int> rowid;
  const UploadQueueItemsCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.localPath = const Value.absent(),
    this.storedFileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.docType = const Value.absent(),
    this.title = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.language = const Value.absent(),
    this.status = const Value.absent(),
    this.documentId = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.isDismissed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.assetsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UploadQueueItemsCompanion.insert({
    required String id,
    required String displayName,
    required String fingerprint,
    required String localPath,
    required String storedFileName,
    required String mimeType,
    required int sizeBytes,
    required String docType,
    required String title,
    this.subjectId = const Value.absent(),
    this.language = const Value.absent(),
    required String status,
    this.documentId = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.isDismissed = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.assetsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       fingerprint = Value(fingerprint),
       localPath = Value(localPath),
       storedFileName = Value(storedFileName),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes),
       docType = Value(docType),
       title = Value(title),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UploadQueueItem> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? fingerprint,
    Expression<String>? localPath,
    Expression<String>? storedFileName,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<String>? docType,
    Expression<String>? title,
    Expression<String>? subjectId,
    Expression<String>? language,
    Expression<String>? status,
    Expression<String>? documentId,
    Expression<String>? errorMessage,
    Expression<bool>? isDismissed,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? assetsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (localPath != null) 'local_path': localPath,
      if (storedFileName != null) 'stored_file_name': storedFileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (docType != null) 'doc_type': docType,
      if (title != null) 'title': title,
      if (subjectId != null) 'subject_id': subjectId,
      if (language != null) 'language': language,
      if (status != null) 'status': status,
      if (documentId != null) 'document_id': documentId,
      if (errorMessage != null) 'error_message': errorMessage,
      if (isDismissed != null) 'is_dismissed': isDismissed,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (assetsJson != null) 'assets_json': assetsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UploadQueueItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String>? fingerprint,
    Value<String>? localPath,
    Value<String>? storedFileName,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<String>? docType,
    Value<String>? title,
    Value<String?>? subjectId,
    Value<String?>? language,
    Value<String>? status,
    Value<String?>? documentId,
    Value<String?>? errorMessage,
    Value<bool>? isDismissed,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? assetsJson,
    Value<int>? rowid,
  }) {
    return UploadQueueItemsCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      fingerprint: fingerprint ?? this.fingerprint,
      localPath: localPath ?? this.localPath,
      storedFileName: storedFileName ?? this.storedFileName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      docType: docType ?? this.docType,
      title: title ?? this.title,
      subjectId: subjectId ?? this.subjectId,
      language: language ?? this.language,
      status: status ?? this.status,
      documentId: documentId ?? this.documentId,
      errorMessage: errorMessage ?? this.errorMessage,
      isDismissed: isDismissed ?? this.isDismissed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assetsJson: assetsJson ?? this.assetsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (storedFileName.present) {
      map['stored_file_name'] = Variable<String>(storedFileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (docType.present) {
      map['doc_type'] = Variable<String>(docType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (isDismissed.present) {
      map['is_dismissed'] = Variable<bool>(isDismissed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (assetsJson.present) {
      map['assets_json'] = Variable<String>(assetsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UploadQueueItemsCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('localPath: $localPath, ')
          ..write('storedFileName: $storedFileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('docType: $docType, ')
          ..write('title: $title, ')
          ..write('subjectId: $subjectId, ')
          ..write('language: $language, ')
          ..write('status: $status, ')
          ..write('documentId: $documentId, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('isDismissed: $isDismissed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('assetsJson: $assetsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentLocalAssetsTable extends DocumentLocalAssets
    with TableInfo<$DocumentLocalAssetsTable, DocumentLocalAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentLocalAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    documentId,
    position,
    localPath,
    fileName,
    mimeType,
    sizeBytes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_local_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentLocalAsset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {documentId, position};
  @override
  DocumentLocalAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentLocalAsset(
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
    );
  }

  @override
  $DocumentLocalAssetsTable createAlias(String alias) {
    return $DocumentLocalAssetsTable(attachedDatabase, alias);
  }
}

class DocumentLocalAsset extends DataClass
    implements Insertable<DocumentLocalAsset> {
  final String documentId;
  final int position;
  final String localPath;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  const DocumentLocalAsset({
    required this.documentId,
    required this.position,
    required this.localPath,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['document_id'] = Variable<String>(documentId);
    map['position'] = Variable<int>(position);
    map['local_path'] = Variable<String>(localPath);
    map['file_name'] = Variable<String>(fileName);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    return map;
  }

  DocumentLocalAssetsCompanion toCompanion(bool nullToAbsent) {
    return DocumentLocalAssetsCompanion(
      documentId: Value(documentId),
      position: Value(position),
      localPath: Value(localPath),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
    );
  }

  factory DocumentLocalAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentLocalAsset(
      documentId: serializer.fromJson<String>(json['documentId']),
      position: serializer.fromJson<int>(json['position']),
      localPath: serializer.fromJson<String>(json['localPath']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'documentId': serializer.toJson<String>(documentId),
      'position': serializer.toJson<int>(position),
      'localPath': serializer.toJson<String>(localPath),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
    };
  }

  DocumentLocalAsset copyWith({
    String? documentId,
    int? position,
    String? localPath,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
  }) => DocumentLocalAsset(
    documentId: documentId ?? this.documentId,
    position: position ?? this.position,
    localPath: localPath ?? this.localPath,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
  );
  DocumentLocalAsset copyWithCompanion(DocumentLocalAssetsCompanion data) {
    return DocumentLocalAsset(
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      position: data.position.present ? data.position.value : this.position,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentLocalAsset(')
          ..write('documentId: $documentId, ')
          ..write('position: $position, ')
          ..write('localPath: $localPath, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    documentId,
    position,
    localPath,
    fileName,
    mimeType,
    sizeBytes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentLocalAsset &&
          other.documentId == this.documentId &&
          other.position == this.position &&
          other.localPath == this.localPath &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes);
}

class DocumentLocalAssetsCompanion extends UpdateCompanion<DocumentLocalAsset> {
  final Value<String> documentId;
  final Value<int> position;
  final Value<String> localPath;
  final Value<String> fileName;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<int> rowid;
  const DocumentLocalAssetsCompanion({
    this.documentId = const Value.absent(),
    this.position = const Value.absent(),
    this.localPath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentLocalAssetsCompanion.insert({
    required String documentId,
    required int position,
    required String localPath,
    required String fileName,
    required String mimeType,
    required int sizeBytes,
    this.rowid = const Value.absent(),
  }) : documentId = Value(documentId),
       position = Value(position),
       localPath = Value(localPath),
       fileName = Value(fileName),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes);
  static Insertable<DocumentLocalAsset> custom({
    Expression<String>? documentId,
    Expression<int>? position,
    Expression<String>? localPath,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (documentId != null) 'document_id': documentId,
      if (position != null) 'position': position,
      if (localPath != null) 'local_path': localPath,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentLocalAssetsCompanion copyWith({
    Value<String>? documentId,
    Value<int>? position,
    Value<String>? localPath,
    Value<String>? fileName,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<int>? rowid,
  }) {
    return DocumentLocalAssetsCompanion(
      documentId: documentId ?? this.documentId,
      position: position ?? this.position,
      localPath: localPath ?? this.localPath,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentLocalAssetsCompanion(')
          ..write('documentId: $documentId, ')
          ..write('position: $position, ')
          ..write('localPath: $localPath, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $CachedMedicalEventsTable cachedMedicalEvents =
      $CachedMedicalEventsTable(this);
  late final $CachedMedicalSummariesTable cachedMedicalSummaries =
      $CachedMedicalSummariesTable(this);
  late final $UploadQueueItemsTable uploadQueueItems = $UploadQueueItemsTable(
    this,
  );
  late final $DocumentLocalAssetsTable documentLocalAssets =
      $DocumentLocalAssetsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    subjects,
    cachedMedicalEvents,
    cachedMedicalSummaries,
    uploadQueueItems,
    documentLocalAssets,
  ];
}

typedef $$SubjectsTableCreateCompanionBuilder =
    SubjectsCompanion Function({
      required String id,
      required String displayName,
      required String relationship,
      Value<String?> dateOfBirth,
      Value<String?> biologicalSex,
      required bool isDefault,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$SubjectsTableUpdateCompanionBuilder =
    SubjectsCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String> relationship,
      Value<String?> dateOfBirth,
      Value<String?> biologicalSex,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$SubjectsTableFilterComposer
    extends Composer<_$LocalDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get biologicalSex => $composableBuilder(
    column: $table.biologicalSex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$LocalDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get biologicalSex => $composableBuilder(
    column: $table.biologicalSex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get biologicalSex => $composableBuilder(
    column: $table.biologicalSex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$SubjectsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $SubjectsTable,
          Subject,
          $$SubjectsTableFilterComposer,
          $$SubjectsTableOrderingComposer,
          $$SubjectsTableAnnotationComposer,
          $$SubjectsTableCreateCompanionBuilder,
          $$SubjectsTableUpdateCompanionBuilder,
          (Subject, BaseReferences<_$LocalDatabase, $SubjectsTable, Subject>),
          Subject,
          PrefetchHooks Function()
        > {
  $$SubjectsTableTableManager(_$LocalDatabase db, $SubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> relationship = const Value.absent(),
                Value<String?> dateOfBirth = const Value.absent(),
                Value<String?> biologicalSex = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion(
                id: id,
                displayName: displayName,
                relationship: relationship,
                dateOfBirth: dateOfBirth,
                biologicalSex: biologicalSex,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required String relationship,
                Value<String?> dateOfBirth = const Value.absent(),
                Value<String?> biologicalSex = const Value.absent(),
                required bool isDefault,
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion.insert(
                id: id,
                displayName: displayName,
                relationship: relationship,
                dateOfBirth: dateOfBirth,
                biologicalSex: biologicalSex,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $SubjectsTable,
      Subject,
      $$SubjectsTableFilterComposer,
      $$SubjectsTableOrderingComposer,
      $$SubjectsTableAnnotationComposer,
      $$SubjectsTableCreateCompanionBuilder,
      $$SubjectsTableUpdateCompanionBuilder,
      (Subject, BaseReferences<_$LocalDatabase, $SubjectsTable, Subject>),
      Subject,
      PrefetchHooks Function()
    >;
typedef $$CachedMedicalEventsTableCreateCompanionBuilder =
    CachedMedicalEventsCompanion Function({
      required String id,
      required String subjectId,
      required String eventType,
      required String title,
      required String description,
      required String eventDate,
      Value<String?> eventEndDate,
      required String attributesJson,
      required String source,
      Value<String?> sourceDocumentId,
      Value<double?> confidence,
      required String tagsJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedMedicalEventsTableUpdateCompanionBuilder =
    CachedMedicalEventsCompanion Function({
      Value<String> id,
      Value<String> subjectId,
      Value<String> eventType,
      Value<String> title,
      Value<String> description,
      Value<String> eventDate,
      Value<String?> eventEndDate,
      Value<String> attributesJson,
      Value<String> source,
      Value<String?> sourceDocumentId,
      Value<double?> confidence,
      Value<String> tagsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedMedicalEventsTableFilterComposer
    extends Composer<_$LocalDatabase, $CachedMedicalEventsTable> {
  $$CachedMedicalEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventEndDate => $composableBuilder(
    column: $table.eventEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attributesJson => $composableBuilder(
    column: $table.attributesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDocumentId => $composableBuilder(
    column: $table.sourceDocumentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedMedicalEventsTableOrderingComposer
    extends Composer<_$LocalDatabase, $CachedMedicalEventsTable> {
  $$CachedMedicalEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventEndDate => $composableBuilder(
    column: $table.eventEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attributesJson => $composableBuilder(
    column: $table.attributesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDocumentId => $composableBuilder(
    column: $table.sourceDocumentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedMedicalEventsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CachedMedicalEventsTable> {
  $$CachedMedicalEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<String> get eventEndDate => $composableBuilder(
    column: $table.eventEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attributesJson => $composableBuilder(
    column: $table.attributesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceDocumentId => $composableBuilder(
    column: $table.sourceDocumentId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$CachedMedicalEventsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $CachedMedicalEventsTable,
          CachedMedicalEvent,
          $$CachedMedicalEventsTableFilterComposer,
          $$CachedMedicalEventsTableOrderingComposer,
          $$CachedMedicalEventsTableAnnotationComposer,
          $$CachedMedicalEventsTableCreateCompanionBuilder,
          $$CachedMedicalEventsTableUpdateCompanionBuilder,
          (
            CachedMedicalEvent,
            BaseReferences<
              _$LocalDatabase,
              $CachedMedicalEventsTable,
              CachedMedicalEvent
            >,
          ),
          CachedMedicalEvent,
          PrefetchHooks Function()
        > {
  $$CachedMedicalEventsTableTableManager(
    _$LocalDatabase db,
    $CachedMedicalEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedMedicalEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedMedicalEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedMedicalEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> eventDate = const Value.absent(),
                Value<String?> eventEndDate = const Value.absent(),
                Value<String> attributesJson = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceDocumentId = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedMedicalEventsCompanion(
                id: id,
                subjectId: subjectId,
                eventType: eventType,
                title: title,
                description: description,
                eventDate: eventDate,
                eventEndDate: eventEndDate,
                attributesJson: attributesJson,
                source: source,
                sourceDocumentId: sourceDocumentId,
                confidence: confidence,
                tagsJson: tagsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String subjectId,
                required String eventType,
                required String title,
                required String description,
                required String eventDate,
                Value<String?> eventEndDate = const Value.absent(),
                required String attributesJson,
                required String source,
                Value<String?> sourceDocumentId = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                required String tagsJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedMedicalEventsCompanion.insert(
                id: id,
                subjectId: subjectId,
                eventType: eventType,
                title: title,
                description: description,
                eventDate: eventDate,
                eventEndDate: eventEndDate,
                attributesJson: attributesJson,
                source: source,
                sourceDocumentId: sourceDocumentId,
                confidence: confidence,
                tagsJson: tagsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedMedicalEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $CachedMedicalEventsTable,
      CachedMedicalEvent,
      $$CachedMedicalEventsTableFilterComposer,
      $$CachedMedicalEventsTableOrderingComposer,
      $$CachedMedicalEventsTableAnnotationComposer,
      $$CachedMedicalEventsTableCreateCompanionBuilder,
      $$CachedMedicalEventsTableUpdateCompanionBuilder,
      (
        CachedMedicalEvent,
        BaseReferences<
          _$LocalDatabase,
          $CachedMedicalEventsTable,
          CachedMedicalEvent
        >,
      ),
      CachedMedicalEvent,
      PrefetchHooks Function()
    >;
typedef $$CachedMedicalSummariesTableCreateCompanionBuilder =
    CachedMedicalSummariesCompanion Function({
      required String id,
      required String subjectId,
      required int version,
      required bool isCurrent,
      required String contentJson,
      required String narrativeText,
      required String language,
      required int generatedFromEventCount,
      Value<DateTime?> createdAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedMedicalSummariesTableUpdateCompanionBuilder =
    CachedMedicalSummariesCompanion Function({
      Value<String> id,
      Value<String> subjectId,
      Value<int> version,
      Value<bool> isCurrent,
      Value<String> contentJson,
      Value<String> narrativeText,
      Value<String> language,
      Value<int> generatedFromEventCount,
      Value<DateTime?> createdAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedMedicalSummariesTableFilterComposer
    extends Composer<_$LocalDatabase, $CachedMedicalSummariesTable> {
  $$CachedMedicalSummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get narrativeText => $composableBuilder(
    column: $table.narrativeText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generatedFromEventCount => $composableBuilder(
    column: $table.generatedFromEventCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedMedicalSummariesTableOrderingComposer
    extends Composer<_$LocalDatabase, $CachedMedicalSummariesTable> {
  $$CachedMedicalSummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get narrativeText => $composableBuilder(
    column: $table.narrativeText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generatedFromEventCount => $composableBuilder(
    column: $table.generatedFromEventCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedMedicalSummariesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CachedMedicalSummariesTable> {
  $$CachedMedicalSummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isCurrent =>
      $composableBuilder(column: $table.isCurrent, builder: (column) => column);

  GeneratedColumn<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get narrativeText => $composableBuilder(
    column: $table.narrativeText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<int> get generatedFromEventCount => $composableBuilder(
    column: $table.generatedFromEventCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$CachedMedicalSummariesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $CachedMedicalSummariesTable,
          CachedMedicalSummary,
          $$CachedMedicalSummariesTableFilterComposer,
          $$CachedMedicalSummariesTableOrderingComposer,
          $$CachedMedicalSummariesTableAnnotationComposer,
          $$CachedMedicalSummariesTableCreateCompanionBuilder,
          $$CachedMedicalSummariesTableUpdateCompanionBuilder,
          (
            CachedMedicalSummary,
            BaseReferences<
              _$LocalDatabase,
              $CachedMedicalSummariesTable,
              CachedMedicalSummary
            >,
          ),
          CachedMedicalSummary,
          PrefetchHooks Function()
        > {
  $$CachedMedicalSummariesTableTableManager(
    _$LocalDatabase db,
    $CachedMedicalSummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedMedicalSummariesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CachedMedicalSummariesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedMedicalSummariesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isCurrent = const Value.absent(),
                Value<String> contentJson = const Value.absent(),
                Value<String> narrativeText = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<int> generatedFromEventCount = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedMedicalSummariesCompanion(
                id: id,
                subjectId: subjectId,
                version: version,
                isCurrent: isCurrent,
                contentJson: contentJson,
                narrativeText: narrativeText,
                language: language,
                generatedFromEventCount: generatedFromEventCount,
                createdAt: createdAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String subjectId,
                required int version,
                required bool isCurrent,
                required String contentJson,
                required String narrativeText,
                required String language,
                required int generatedFromEventCount,
                Value<DateTime?> createdAt = const Value.absent(),
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedMedicalSummariesCompanion.insert(
                id: id,
                subjectId: subjectId,
                version: version,
                isCurrent: isCurrent,
                contentJson: contentJson,
                narrativeText: narrativeText,
                language: language,
                generatedFromEventCount: generatedFromEventCount,
                createdAt: createdAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedMedicalSummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $CachedMedicalSummariesTable,
      CachedMedicalSummary,
      $$CachedMedicalSummariesTableFilterComposer,
      $$CachedMedicalSummariesTableOrderingComposer,
      $$CachedMedicalSummariesTableAnnotationComposer,
      $$CachedMedicalSummariesTableCreateCompanionBuilder,
      $$CachedMedicalSummariesTableUpdateCompanionBuilder,
      (
        CachedMedicalSummary,
        BaseReferences<
          _$LocalDatabase,
          $CachedMedicalSummariesTable,
          CachedMedicalSummary
        >,
      ),
      CachedMedicalSummary,
      PrefetchHooks Function()
    >;
typedef $$UploadQueueItemsTableCreateCompanionBuilder =
    UploadQueueItemsCompanion Function({
      required String id,
      required String displayName,
      required String fingerprint,
      required String localPath,
      required String storedFileName,
      required String mimeType,
      required int sizeBytes,
      required String docType,
      required String title,
      Value<String?> subjectId,
      Value<String?> language,
      required String status,
      Value<String?> documentId,
      Value<String?> errorMessage,
      Value<bool> isDismissed,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> assetsJson,
      Value<int> rowid,
    });
typedef $$UploadQueueItemsTableUpdateCompanionBuilder =
    UploadQueueItemsCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String> fingerprint,
      Value<String> localPath,
      Value<String> storedFileName,
      Value<String> mimeType,
      Value<int> sizeBytes,
      Value<String> docType,
      Value<String> title,
      Value<String?> subjectId,
      Value<String?> language,
      Value<String> status,
      Value<String?> documentId,
      Value<String?> errorMessage,
      Value<bool> isDismissed,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> assetsJson,
      Value<int> rowid,
    });

class $$UploadQueueItemsTableFilterComposer
    extends Composer<_$LocalDatabase, $UploadQueueItemsTable> {
  $$UploadQueueItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storedFileName => $composableBuilder(
    column: $table.storedFileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get docType => $composableBuilder(
    column: $table.docType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDismissed => $composableBuilder(
    column: $table.isDismissed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetsJson => $composableBuilder(
    column: $table.assetsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UploadQueueItemsTableOrderingComposer
    extends Composer<_$LocalDatabase, $UploadQueueItemsTable> {
  $$UploadQueueItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storedFileName => $composableBuilder(
    column: $table.storedFileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get docType => $composableBuilder(
    column: $table.docType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDismissed => $composableBuilder(
    column: $table.isDismissed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetsJson => $composableBuilder(
    column: $table.assetsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UploadQueueItemsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $UploadQueueItemsTable> {
  $$UploadQueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get storedFileName => $composableBuilder(
    column: $table.storedFileName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get docType =>
      $composableBuilder(column: $table.docType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDismissed => $composableBuilder(
    column: $table.isDismissed,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get assetsJson => $composableBuilder(
    column: $table.assetsJson,
    builder: (column) => column,
  );
}

class $$UploadQueueItemsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $UploadQueueItemsTable,
          UploadQueueItem,
          $$UploadQueueItemsTableFilterComposer,
          $$UploadQueueItemsTableOrderingComposer,
          $$UploadQueueItemsTableAnnotationComposer,
          $$UploadQueueItemsTableCreateCompanionBuilder,
          $$UploadQueueItemsTableUpdateCompanionBuilder,
          (
            UploadQueueItem,
            BaseReferences<
              _$LocalDatabase,
              $UploadQueueItemsTable,
              UploadQueueItem
            >,
          ),
          UploadQueueItem,
          PrefetchHooks Function()
        > {
  $$UploadQueueItemsTableTableManager(
    _$LocalDatabase db,
    $UploadQueueItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UploadQueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UploadQueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UploadQueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> storedFileName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> docType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> documentId = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<bool> isDismissed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> assetsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UploadQueueItemsCompanion(
                id: id,
                displayName: displayName,
                fingerprint: fingerprint,
                localPath: localPath,
                storedFileName: storedFileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                docType: docType,
                title: title,
                subjectId: subjectId,
                language: language,
                status: status,
                documentId: documentId,
                errorMessage: errorMessage,
                isDismissed: isDismissed,
                createdAt: createdAt,
                updatedAt: updatedAt,
                assetsJson: assetsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required String fingerprint,
                required String localPath,
                required String storedFileName,
                required String mimeType,
                required int sizeBytes,
                required String docType,
                required String title,
                Value<String?> subjectId = const Value.absent(),
                Value<String?> language = const Value.absent(),
                required String status,
                Value<String?> documentId = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<bool> isDismissed = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> assetsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UploadQueueItemsCompanion.insert(
                id: id,
                displayName: displayName,
                fingerprint: fingerprint,
                localPath: localPath,
                storedFileName: storedFileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                docType: docType,
                title: title,
                subjectId: subjectId,
                language: language,
                status: status,
                documentId: documentId,
                errorMessage: errorMessage,
                isDismissed: isDismissed,
                createdAt: createdAt,
                updatedAt: updatedAt,
                assetsJson: assetsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UploadQueueItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $UploadQueueItemsTable,
      UploadQueueItem,
      $$UploadQueueItemsTableFilterComposer,
      $$UploadQueueItemsTableOrderingComposer,
      $$UploadQueueItemsTableAnnotationComposer,
      $$UploadQueueItemsTableCreateCompanionBuilder,
      $$UploadQueueItemsTableUpdateCompanionBuilder,
      (
        UploadQueueItem,
        BaseReferences<
          _$LocalDatabase,
          $UploadQueueItemsTable,
          UploadQueueItem
        >,
      ),
      UploadQueueItem,
      PrefetchHooks Function()
    >;
typedef $$DocumentLocalAssetsTableCreateCompanionBuilder =
    DocumentLocalAssetsCompanion Function({
      required String documentId,
      required int position,
      required String localPath,
      required String fileName,
      required String mimeType,
      required int sizeBytes,
      Value<int> rowid,
    });
typedef $$DocumentLocalAssetsTableUpdateCompanionBuilder =
    DocumentLocalAssetsCompanion Function({
      Value<String> documentId,
      Value<int> position,
      Value<String> localPath,
      Value<String> fileName,
      Value<String> mimeType,
      Value<int> sizeBytes,
      Value<int> rowid,
    });

class $$DocumentLocalAssetsTableFilterComposer
    extends Composer<_$LocalDatabase, $DocumentLocalAssetsTable> {
  $$DocumentLocalAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DocumentLocalAssetsTableOrderingComposer
    extends Composer<_$LocalDatabase, $DocumentLocalAssetsTable> {
  $$DocumentLocalAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentLocalAssetsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $DocumentLocalAssetsTable> {
  $$DocumentLocalAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);
}

class $$DocumentLocalAssetsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $DocumentLocalAssetsTable,
          DocumentLocalAsset,
          $$DocumentLocalAssetsTableFilterComposer,
          $$DocumentLocalAssetsTableOrderingComposer,
          $$DocumentLocalAssetsTableAnnotationComposer,
          $$DocumentLocalAssetsTableCreateCompanionBuilder,
          $$DocumentLocalAssetsTableUpdateCompanionBuilder,
          (
            DocumentLocalAsset,
            BaseReferences<
              _$LocalDatabase,
              $DocumentLocalAssetsTable,
              DocumentLocalAsset
            >,
          ),
          DocumentLocalAsset,
          PrefetchHooks Function()
        > {
  $$DocumentLocalAssetsTableTableManager(
    _$LocalDatabase db,
    $DocumentLocalAssetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentLocalAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentLocalAssetsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DocumentLocalAssetsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> documentId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentLocalAssetsCompanion(
                documentId: documentId,
                position: position,
                localPath: localPath,
                fileName: fileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String documentId,
                required int position,
                required String localPath,
                required String fileName,
                required String mimeType,
                required int sizeBytes,
                Value<int> rowid = const Value.absent(),
              }) => DocumentLocalAssetsCompanion.insert(
                documentId: documentId,
                position: position,
                localPath: localPath,
                fileName: fileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DocumentLocalAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $DocumentLocalAssetsTable,
      DocumentLocalAsset,
      $$DocumentLocalAssetsTableFilterComposer,
      $$DocumentLocalAssetsTableOrderingComposer,
      $$DocumentLocalAssetsTableAnnotationComposer,
      $$DocumentLocalAssetsTableCreateCompanionBuilder,
      $$DocumentLocalAssetsTableUpdateCompanionBuilder,
      (
        DocumentLocalAsset,
        BaseReferences<
          _$LocalDatabase,
          $DocumentLocalAssetsTable,
          DocumentLocalAsset
        >,
      ),
      DocumentLocalAsset,
      PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$CachedMedicalEventsTableTableManager get cachedMedicalEvents =>
      $$CachedMedicalEventsTableTableManager(_db, _db.cachedMedicalEvents);
  $$CachedMedicalSummariesTableTableManager get cachedMedicalSummaries =>
      $$CachedMedicalSummariesTableTableManager(
        _db,
        _db.cachedMedicalSummaries,
      );
  $$UploadQueueItemsTableTableManager get uploadQueueItems =>
      $$UploadQueueItemsTableTableManager(_db, _db.uploadQueueItems);
  $$DocumentLocalAssetsTableTableManager get documentLocalAssets =>
      $$DocumentLocalAssetsTableTableManager(_db, _db.documentLocalAssets);
}
