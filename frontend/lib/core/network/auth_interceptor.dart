import 'package:dio/dio.dart';

import '../storage/secure_token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokenStorage, required String baseUrl})
    : _refreshDio = Dio(BaseOptions(baseUrl: baseUrl));

  final SecureTokenStorage tokenStorage;
  final Dio _refreshDio;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await tokenStorage.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    if (statusCode != 401 || path.contains('/auth/refresh')) {
      handler.next(err);
      return;
    }

    final refreshToken = await tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      handler.next(err);
      return;
    }

    try {
      final refreshResponse = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh': refreshToken},
      );
      final data = refreshResponse.data ?? <String, dynamic>{};
      final accessToken = data['access'] as String?;
      final nextRefreshToken = data['refresh'] as String? ?? refreshToken;

      if (accessToken == null || accessToken.isEmpty) {
        handler.next(err);
        return;
      }

      await tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: nextRefreshToken,
      );

      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $accessToken';
      final response = await _refreshDio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on Object {
      await tokenStorage.clearTokens();
      handler.next(err);
    }
  }
}
