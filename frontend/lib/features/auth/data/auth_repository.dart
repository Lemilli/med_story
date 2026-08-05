import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_database.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../../../core/storage/temporary_file_cleanup.dart';
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
    await clearSensitiveTemporaryFiles();
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

  Future<RegistrationResult> register({
    required String email,
    required String password,
    required String fullName,
    required String locale,
    required bool acceptPrivacyNotice,
    required bool aiProcessingConsent,
  }) async {
    return api.register(
      email: email,
      password: password,
      fullName: fullName,
      locale: locale,
      acceptPrivacyNotice: acceptPrivacyNotice,
      aiProcessingConsent: aiProcessingConsent,
    );
  }

  Future<AuthState> verifyEmail({
    required String email,
    required String code,
  }) async {
    final session = await api.verifyEmail(email: email, code: code);
    await tokenStorage.saveTokens(
      accessToken: session.tokens.accessToken,
      refreshToken: session.tokens.refreshToken,
    );
    final user = session.user.id.isEmpty ? await api.me() : session.user;
    return AuthState.authenticated(user);
  }

  Future<void> resendVerification(String email) =>
      api.resendVerification(email: email);

  Future<void> requestPasswordReset(String email) =>
      api.requestPasswordReset(email: email);

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) => api.confirmPasswordReset(
    email: email,
    code: code,
    newPassword: newPassword,
  );

  Future<ConsentStatus> consents() => api.consents();

  Future<ConsentStatus> updateAiConsent(bool granted) =>
      api.updateAiConsent(granted: granted);

  Future<AccountUsage> usage() => api.usage();

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
    await clearSensitiveTemporaryFiles();
  }

  Future<AppUser> updateLocale(String locale) {
    return api.updateMe(locale: locale);
  }

  Future<void> deleteAccount() async {
    final refreshToken = await tokenStorage.readRefreshToken();
    await api.deleteMe(refreshToken: refreshToken);
    await tokenStorage.clearTokens();
    await localDatabase.clearAll();
    await clearSensitiveTemporaryFiles();
  }
}
