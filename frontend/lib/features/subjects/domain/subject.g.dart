// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Subject _$SubjectFromJson(Map<String, dynamic> json) => _Subject(
  id: json['id'] as String,
  displayName: json['display_name'] as String,
  relationship: $enumDecode(_$SubjectRelationshipEnumMap, json['relationship']),
  dateOfBirth: json['date_of_birth'] as String?,
  biologicalSex: $enumDecodeNullable(
    _$BiologicalSexEnumMap,
    json['biological_sex'],
  ),
  isDefault: json['is_default'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SubjectToJson(_Subject instance) => <String, dynamic>{
  'id': instance.id,
  'display_name': instance.displayName,
  'relationship': _$SubjectRelationshipEnumMap[instance.relationship]!,
  'date_of_birth': instance.dateOfBirth,
  'biological_sex': _$BiologicalSexEnumMap[instance.biologicalSex],
  'is_default': instance.isDefault,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$SubjectRelationshipEnumMap = {
  SubjectRelationship.self: 'self',
  SubjectRelationship.child: 'child',
  SubjectRelationship.dependent: 'dependent',
  SubjectRelationship.other: 'other',
};

const _$BiologicalSexEnumMap = {
  BiologicalSex.female: 'female',
  BiologicalSex.male: 'male',
};
