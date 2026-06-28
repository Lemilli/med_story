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
  final code = _extractCode(error.response?.data);
  if (code != null) {
    final mapped = _mapKnownCode(code, statusCode);
    if (mapped != null) {
      return AppFailure(mapped);
    }
  }
  final message = _extractMessage(error.response?.data);
  if (message != null && message.isNotEmpty) {
    return AppFailure(message);
  }
  if (statusCode == 401) {
    return const AppFailure('auth_failed');
  }
  if (statusCode >= 400 && statusCode < 500) {
    return const AppFailure('request_failed');
  }
  return AppFailure(fallback);
}

String? _extractCode(Object? data) {
  if (data is Map<String, dynamic>) {
    final error = data['error'];
    if (error is Map<String, dynamic>) {
      final code = error['code'];
      if (code is String && code.isNotEmpty) {
        return code;
      }
    }
    final code = data['code'];
    if (code is String && code.isNotEmpty) {
      return code;
    }
  }
  return null;
}

String? _mapKnownCode(String code, int statusCode) {
  return switch (code) {
    'file_too_large' => 'document_file_too_large',
    'unsupported_mime_type' ||
    'unsupported_media_type' ||
    'unsupported_file_type' => 'document_unsupported_mime_type',
    'processing_failed' ||
    'document_processing_failed' ||
    'failed_processing' => 'document_processing_failed',
    'not_authenticated' || 'token_expired' => 'auth_failed',
    'permission_denied' => 'permission_denied',
    'not_found' => 'not_found',
    'throttled' => 'throttled',
    'validation_error' when statusCode == 413 => 'document_file_too_large',
    _ => null,
  };
}

String? _extractMessage(Object? data) {
  if (data is Map<String, dynamic>) {
    final error = data['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message'];
      if (message is String) {
        return message;
      }
    }
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
