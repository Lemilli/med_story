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

  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
    required String locale,
  }) async {
    final response = await _post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'locale': locale,
      },
    );
    final data = response.data ?? <String, dynamic>{};

    return AuthSession(
      user: AppUser.fromJson(data['user'] as Map<String, dynamic>? ?? {}),
      tokens: AuthTokens.fromJson(data),
    );
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

  Future<void> logout({required String refreshToken}) async {
    await _post<void>('/auth/logout', data: {'refresh': refreshToken});
  }

  Future<Response<T>> _get<T>(String path) async {
    try {
      return await _dio.get<T>(path);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<Response<T>> _post<T>(String path, {Object? data}) async {
    try {
      return await _dio.post<T>(path, data: data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  AppFailure _mapDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 400 || statusCode == 401) {
      return const AppFailure('auth_failed');
    }
    return const AppFailure('network_failed');
  }
}
