import 'package:freezed_annotation/freezed_annotation.dart';

part 'subject.freezed.dart';
part 'subject.g.dart';

@freezed
abstract class Subject with _$Subject {
  const factory Subject({
    required String id,
    @JsonKey(name: 'display_name') required String displayName,
    required SubjectRelationship relationship,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    @JsonKey(name: 'biological_sex') BiologicalSex? biologicalSex,
    @JsonKey(name: 'is_default') required bool isDefault,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Subject;

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);
}

enum SubjectRelationship { self, child, dependent, other }

enum BiologicalSex { female, male }
