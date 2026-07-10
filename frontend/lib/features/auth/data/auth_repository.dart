import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_database.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../domain/auth_models.dart';
import 'auth_api.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.watch(authApiProvider),
    tokenStorage: ref.watch(secureTokenStorageProvider),
    localDatabase: ref.watch(localDatabaseProvider),
  );
});

class AuthRepository {
  const AuthRepository({
    required this.api,
    required this.tokenStorage,
    required this.localDatabase,
  });

  final AuthApi api;
  final SecureTokenStorage tokenStorage;
  final LocalDatabase localDatabase;

  Future<AuthState> restoreSession() async {
    final accessToken = await tokenStorage.readAccessToken();
    final refreshToken = await tokenStorage.readRefreshToken();
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return const AuthState.unauthenticated();
    }

    try {
      final user = await api.me();
      return AuthState.authenticated(user);
    } on Object {
      await tokenStorage.clearTokens();
      return const AuthState.unauthenticated();
    }
  }

  Future<AuthState> register({
    required String email,
    required String password,
    required String fullName,
    required String locale,
  }) async {
    final session = await api.register(
      email: email,
      password: password,
      fullName: fullName,
      locale: locale,
    );
    await tokenStorage.saveTokens(
      accessToken: session.tokens.accessToken,
      refreshToken: session.tokens.refreshToken,
    );
    final user = await api.me();
    return AuthState.authenticated(user);
  }

  Future<AuthState> login({
    required String email,
    required String password,
  }) async {
    final tokens = await api.login(email: email, password: password);
    await tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    final user = await api.me();
    return AuthState.authenticated(user);
  }

  Future<void> logout() async {
    final refreshToken = await tokenStorage.readRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await api.logout(refreshToken: refreshToken);
      } on Object {
        // Local token removal is the invariant; server blacklist is best effort.
      }
    }
    await tokenStorage.clearTokens();
    await localDatabase.clearAll();
  }

  Future<AppUser> updateLocale(String locale) {
    return api.updateMe(locale: locale);
  }

  Future<void> deleteAccount() async {
    final refreshToken = await tokenStorage.readRefreshToken();
    await api.deleteMe(refreshToken: refreshToken);
    await tokenStorage.clearTokens();
    await localDatabase.clearAll();
  }
}
