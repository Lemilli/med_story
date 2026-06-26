import 'package:dio/dio.dart';

import 'app_failure.dart';

AppFailure mapDioException(
  DioException error, {
  String fallback = 'network_failed',
}) {
  final statusCode = error.response?.statusCode;
  if (statusCode == null) {
    return AppFailure(fallback);
  }
  final message = _extractMessage(error.response?.data);
  if (message != null && message.isNotEmpty) {
    return AppFailure(message);
  }
  if (statusCode >= 400 && statusCode < 500) {
    return const AppFailure('request_failed');
  }
  return AppFailure(fallback);
}

String? _extractMessage(Object? data) {
  if (data is Map<String, dynamic>) {
    final detail = data['detail'];
    if (detail is String) {
      return detail;
    }
    for (final entry in data.entries) {
      final value = entry.value;
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
      if (value is String) {
        return value;
      }
    }
  }
  if (data is String && data.isNotEmpty) {
    return data;
  }
  return null;
}
