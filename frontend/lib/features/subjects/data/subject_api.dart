import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../domain/subject.dart';

final subjectApiProvider = Provider<SubjectApi>((ref) {
  return SubjectApi(ref.watch(apiClientProvider));
});

class SubjectApi {
  const SubjectApi(this._dio);

  final Dio _dio;

  Future<List<Subject>> listSubjects() async {
    try {
      final response = await _dio.get<List<dynamic>>('/subjects');
      final data = response.data ?? const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(Subject.fromJson)
          .toList(growable: false);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<Subject> createSubject({
    required String displayName,
    required SubjectRelationship relationship,
    String? dateOfBirth,
    BiologicalSex? biologicalSex,
  }) async {
    try {
      final data = <String, dynamic>{
        'display_name': displayName,
        'relationship': relationship.name,
      };
      if (dateOfBirth != null) {
        data['date_of_birth'] = dateOfBirth;
      }
      if (biologicalSex != null) {
        data['biological_sex'] = biologicalSex.name;
      }
      final response = await _dio.post<Map<String, dynamic>>(
        '/subjects',
        data: data,
      );
      return Subject.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<Subject> updateSubject(
    String id, {
    String? displayName,
    SubjectRelationship? relationship,
    String? dateOfBirth,
    BiologicalSex? biologicalSex,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (displayName != null) {
        data['display_name'] = displayName;
      }
      if (relationship != null) {
        data['relationship'] = relationship.name;
      }
      if (dateOfBirth != null) {
        data['date_of_birth'] = dateOfBirth;
      }
      if (biologicalSex != null) {
        data['biological_sex'] = biologicalSex.name;
      }
      final response = await _dio.patch<Map<String, dynamic>>(
        '/subjects/$id',
        data: data,
      );
      return Subject.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _dio.delete<void>('/subjects/$id');
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
