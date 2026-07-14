import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../domain/medical_summary.dart';

final summaryApiProvider = Provider<SummaryApi>((ref) {
  return SummaryApi(ref.watch(apiClientProvider));
});

class SummaryApi {
  const SummaryApi(this._dio);

  final Dio _dio;

  Future<MedicalSummary> getCurrentSummary({String? subjectId}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/summary',
        queryParameters: _subjectQuery(subjectId),
      );
      return MedicalSummary.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      if (_isSummaryNotReady(error)) {
        throw const SummaryNotReady();
      }
      throw mapDioException(error, fallback: 'summary_load_failed');
    }
  }

  Future<SummaryRegenerateResult> regenerateSummary({
    String? subjectId,
    String? language,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/summary/regenerate',
        queryParameters: _subjectQuery(subjectId),
        data: {
          if (language != null && language.trim().isNotEmpty)
            'language': language.trim(),
        },
      );
      return SummaryRegenerateResult.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'summary_regenerate_failed');
    }
  }

  Future<String> getJobStatus(String jobId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/jobs/$jobId');
      return response.data?['status'] as String? ?? 'failed';
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'summary_job_status_failed');
    }
  }

  Future<List<MedicalSummary>> listVersions({String? subjectId}) async {
    try {
      final response = await _dio.get<Object>(
        '/summary/versions',
        queryParameters: _subjectQuery(subjectId),
      );
      final data = response.data;
      final results = data is Map<String, dynamic> ? data['results'] : data;
      if (results is List) {
        return results
            .whereType<Map<String, dynamic>>()
            .map(MedicalSummary.fromJson)
            .toList(growable: false);
      }
      return const <MedicalSummary>[];
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'summary_versions_load_failed');
    }
  }

  Future<Uint8List> exportPdf({String? subjectId}) async {
    try {
      final response = await _dio.get<List<int>>(
        '/summary/export',
        queryParameters: {..._subjectQuery(subjectId), 'format': 'pdf'},
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data ?? const <int>[]);
    } on DioException catch (error) {
      if (_isSummaryNotReady(error)) {
        throw const SummaryNotReady();
      }
      throw mapDioException(error, fallback: 'summary_export_failed');
    }
  }

  Map<String, String> _subjectQuery(String? subjectId) {
    if (subjectId == null || subjectId.isEmpty) {
      return const <String, String>{};
    }
    return {'subject_id': subjectId};
  }
}

class SummaryNotReady implements Exception {
  const SummaryNotReady();
}

bool _isSummaryNotReady(DioException error) {
  if (error.response?.statusCode != 404) {
    return false;
  }
  final data = error.response?.data;
  if (data is! Map<String, dynamic>) {
    return false;
  }
  final errorData = data['error'];
  if (errorData is Map<String, dynamic>) {
    return errorData['code'] == 'not_ready';
  }
  return data['code'] == 'not_ready';
}
