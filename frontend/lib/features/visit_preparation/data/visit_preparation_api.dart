import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/error_mapper.dart';
import '../../../core/network/api_client.dart';

final visitPreparationApiProvider = Provider<VisitPreparationApi>((ref) {
  return VisitPreparationApi(ref.watch(apiClientProvider));
});

class VisitPreparation {
  const VisitPreparation({required this.id, required this.subjectId, required this.note});

  factory VisitPreparation.fromJson(Map<String, dynamic> json) => VisitPreparation(
    id: json['id'] as String,
    subjectId: json['subject_id'] as String,
    note: json['note'] as String? ?? '',
  );

  final String id;
  final String subjectId;
  final String note;
}

class VisitPreparationApi {
  const VisitPreparationApi(this._dio);
  final Dio _dio;

  Future<VisitPreparation> get(String subjectId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/visit-preparation', queryParameters: {'subject_id': subjectId},
      );
      return VisitPreparation.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'visit_preparation_load_failed');
    }
  }

  Future<VisitPreparation> save(String subjectId, String note) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/visit-preparation',
        queryParameters: {'subject_id': subjectId},
        data: {'note': note},
      );
      return VisitPreparation.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'visit_preparation_save_failed');
    }
  }
}
