import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/error_mapper.dart';
import '../../../core/network/api_client.dart';

final privacyApiProvider = Provider<PrivacyApi>((ref) {
  return PrivacyApi(ref.watch(apiClientProvider));
});

class PrivacyApi {
  const PrivacyApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> exportData() async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('/privacy/export');
      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw mapDioException(error, fallback: 'privacy_export_failed');
    }
  }
}
