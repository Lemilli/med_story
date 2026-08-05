import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_failure.dart';
import '../../../core/network/api_client.dart';
import '../domain/auth_models.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});

class AuthApi {
  const AuthApi(this._dio);

  final Dio _dio;

  Future<RegistrationResult> register({
    required String email,
    required String password,
    required String fullName,
    required String locale,
    required bool acceptPrivacyNotice,
    required bool aiProcessingConsent,
  }) async {
    final response = await _post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'locale': locale,
        'privacy_notice_version': '2026-08-05',
        'privacy_accepted': acceptPrivacyNotice,
        'ai_processing_accepted': aiProcessingConsent,
      },
    );
    final data = response.data ?? <String, dynamic>{};
    return RegistrationResult.fromJson(data);
  }

  Future<AuthSession> verifyEmail({
    required String email,
    required String code,
  }) async {
    final response = await _post<Map<String, dynamic>>(
      '/auth/verify-email',
      data: {'email': email, 'code': code},
    );
    final data = response.data ?? <String, dynamic>{};
    final tokenData = data['tokens'] is Map<String, dynamic>
        ? data['tokens'] as Map<String, dynamic>
        : data;
    return AuthSession(
      user: AppUser.fromJson(data['user'] as Map<String, dynamic>? ?? {}),
      tokens: AuthTokens.fromJson(tokenData),
    );
  }

  Future<void> resendVerification({required String email}) async {
    await _post<void>('/auth/resend-verification', data: {'email': email});
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _post<void>('/auth/password-reset/request', data: {'email': email});
  }

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _post<void>(
      '/auth/password-reset/confirm',
      data: {'email': email, 'code': code, 'new_password': newPassword},
    );
  }

  Future<ConsentStatus> consents() async {
    final response = await _get<Object?>('/me/consents');
    final data = response.data;
    if (data is List) {
      return ConsentStatus.fromRecords(
        data.whereType<Map>().map((record) => record.cast<String, dynamic>()),
      );
    }
    return ConsentStatus.fromJson(
      data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  }

  Future<ConsentStatus> updateAiConsent({required bool granted}) async {
    await _put<void>('/me/consents/ai-processing', data: {'granted': granted});
    return consents();
  }

  Future<AccountUsage> usage() async {
    final response = await _get<Map<String, dynamic>>('/me/usage');
    return AccountUsage.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final response = await _post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    return AuthTokens.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<AppUser> me() async {
    final response = await _get<Map<String, dynamic>>('/me');
    return AppUser.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<AppUser> updateMe({String? fullName, String? locale}) async {
    final data = <String, String>{};
    if (fullName != null) {
      data['full_name'] = fullName;
    }
    if (locale != null) {
      data['locale'] = locale;
    }
    final response = await _patch<Map<String, dynamic>>('/me', data: data);
    return AppUser.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> deleteMe({String? refreshToken}) async {
    final data = refreshToken != null && refreshToken.isNotEmpty
        ? {'refresh': refreshToken}
        : <String, String>{};
    await _delete<void>('/me', data: data);
  }

  Future<void> logout({required String refreshToken}) async {
    await _post<void>('/auth/logout', data: {'refresh': refreshToken});
  }

  Future<Response<T>> _get<T>(String path) async {
    try {
      return await _dio.get<T>(path);
    } on DioException catch (error) {
      throw _mapDioException(error, path: path);
    }
  }

  Future<Response<T>> _post<T>(String path, {Object? data}) async {
    try {
      return await _dio.post<T>(path, data: data);
    } on DioException catch (error) {
      throw _mapDioException(error, path: path);
    }
  }

  Future<Response<T>> _patch<T>(String path, {Object? data}) async {
    try {
      return await _dio.patch<T>(path, data: data);
    } on DioException catch (error) {
      throw _mapDioException(error, path: path);
    }
  }

  Future<Response<T>> _put<T>(String path, {Object? data}) async {
    try {
      return await _dio.put<T>(path, data: data);
    } on DioException catch (error) {
      throw _mapDioException(error, path: path);
    }
  }

  Future<Response<T>> _delete<T>(String path, {Object? data}) async {
    try {
      return await _dio.delete<T>(path, data: data);
    } on DioException catch (error) {
      throw _mapDioException(error, path: path);
    }
  }

  AppFailure _mapDioException(DioException error, {required String path}) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    if (statusCode == null) {
      return const AppFailure('network_failed');
    }
    final errorCode = _apiErrorCode(data);
    if (errorCode == 'demo_capacity_reached') {
      return const AppFailure('demo_capacity_reached');
    }
    if (path == '/auth/register' && statusCode == 400) {
      return _mapRegisterFailure(data);
    }
    if (path == '/auth/login' && (statusCode == 400 || statusCode == 401)) {
      return const AppFailure('auth_invalid_credentials');
    }
    if (path == '/auth/verify-email' && statusCode == 400) {
      return const AppFailure('auth_verification_invalid');
    }
    if (statusCode == 429) {
      return const AppFailure('throttled');
    }
    if (statusCode == 400 || statusCode == 401) {
      return const AppFailure('auth_failed');
    }
    return const AppFailure('network_failed');
  }

  AppFailure _mapRegisterFailure(Object? data) {
    final emailMessages = _fieldMessages(data, 'email');
    final passwordMessages = _fieldMessages(data, 'password');
    final messages = [...emailMessages, ...passwordMessages];
    final normalized = messages.join(' ').toLowerCase();

    if (_containsAny(normalized, const [
      'already exists',
      'already registered',
      'already created',
      'unique',
    ])) {
      return const AppFailure('auth_email_already_exists');
    }
    if (emailMessages.isNotEmpty &&
        _containsAny(normalized, const ['valid email', 'invalid'])) {
      return const AppFailure('auth_invalid_email');
    }
    if (emailMessages.isNotEmpty &&
        _containsAny(normalized, const ['required', 'blank'])) {
      return const AppFailure('auth_email_required');
    }
    if (passwordMessages.isNotEmpty &&
        _containsAny(normalized, const [
          'too short',
          'too common',
          'entirely numeric',
          'similar',
          'minimum length',
          'required',
          'blank',
        ])) {
      return const AppFailure('auth_password_not_accepted');
    }
    return const AppFailure('auth_register_failed');
  }

  List<String> _fieldMessages(Object? data, String field) {
    if (data is! Map) {
      return const [];
    }
    final value = data[field];
    if (value is List) {
      return value.map((message) => message.toString()).toList();
    }
    if (value is String) {
      return [value];
    }
    return const [];
  }

  bool _containsAny(String value, List<String> needles) {
    return needles.any(value.contains);
  }

  String? _apiErrorCode(Object? data) {
    if (data is! Map) return null;
    final error = data['error'];
    if (error is Map && error['code'] is String) {
      return error['code'] as String;
    }
    return data['code'] is String ? data['code'] as String : null;
  }
}
