import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/core/storage/local_database.dart';
import 'package:med_story/core/storage/secure_token_storage.dart';
import 'package:med_story/features/auth/data/auth_api.dart';
import 'package:med_story/features/auth/data/auth_repository.dart';
import 'package:med_story/features/auth/domain/auth_models.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthApi extends Mock implements AuthApi {}

class _MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

class _MockLocalDatabase extends Mock implements LocalDatabase {}

void main() {
  late _MockAuthApi api;
  late _MockSecureTokenStorage tokenStorage;
  late _MockLocalDatabase localDatabase;
  late AuthRepository repository;

  setUp(() {
    api = _MockAuthApi();
    tokenStorage = _MockSecureTokenStorage();
    localDatabase = _MockLocalDatabase();
    repository = AuthRepository(
      api: api,
      tokenStorage: tokenStorage,
      localDatabase: localDatabase,
    );
  });

  test('updates locale through /me', () async {
    final updated = _user(locale: 'ru');
    when(() => api.updateMe(locale: 'ru')).thenAnswer((_) async => updated);

    final result = await repository.updateLocale('ru');

    expect(result.locale, 'ru');
    verify(() => api.updateMe(locale: 'ru')).called(1);
  });

  test(
    'registration returns verification requirement without storing tokens',
    () async {
      const registration = RegistrationResult(
        verificationRequired: true,
        emailMasked: 'a***@example.com',
      );
      when(
        () => api.register(
          email: 'alex@example.com',
          password: 'strong-password',
          fullName: 'Alex',
          locale: 'en',
          acceptPrivacyNotice: true,
          aiProcessingConsent: false,
        ),
      ).thenAnswer((_) async => registration);

      final result = await repository.register(
        email: 'alex@example.com',
        password: 'strong-password',
        fullName: 'Alex',
        locale: 'en',
        acceptPrivacyNotice: true,
        aiProcessingConsent: false,
      );

      expect(result.emailMasked, 'a***@example.com');
      verifyNever(
        () => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      );
    },
  );

  test('email verification stores returned session tokens', () async {
    final user = _user(locale: 'en');
    when(
      () => api.verifyEmail(email: 'alex@example.com', code: '123456'),
    ).thenAnswer(
      (_) async => AuthSession(
        user: user,
        tokens: const AuthTokens(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
        ),
      ),
    );
    when(
      () => tokenStorage.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      ),
    ).thenAnswer((_) async {});

    final state = await repository.verifyEmail(
      email: 'alex@example.com',
      code: '123456',
    );

    expect(state.isAuthenticated, isTrue);
    expect(state.user?.id, 'user-1');
    verify(
      () => tokenStorage.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      ),
    ).called(1);
  });

  test('AI consent is updated through the dedicated endpoint', () async {
    const updated = ConsentStatus(
      privacyNoticeAccepted: true,
      privacyNoticeVersion: '2026-08-05',
      aiProcessingAllowed: true,
    );
    when(
      () => api.updateAiConsent(granted: true),
    ).thenAnswer((_) async => updated);

    final result = await repository.updateAiConsent(true);

    expect(result.aiProcessingAllowed, isTrue);
    verify(() => api.updateAiConsent(granted: true)).called(1);
  });

  test('parses consent records and nested demo usage', () {
    final consents = ConsentStatus.fromRecords(const [
      {
        'kind': 'privacy_notice',
        'notice_version': '2026-08-05',
        'granted': true,
      },
      {'kind': 'ai_processing', 'notice_version': '', 'granted': false},
    ]);
    final usage = AccountUsage.fromJson(const {
      'ai': {
        'user_daily': {'used': 3, 'limit': 10},
      },
      'storage': {'used_bytes': 1048576, 'limit_bytes': 104857600},
    });

    expect(consents.privacyNoticeAccepted, isTrue);
    expect(consents.aiProcessingAllowed, isFalse);
    expect(usage.aiUnitsRemainingToday, 7);
    expect(usage.storageBytesUsed, 1048576);
  });

  test('delete account sends refresh token and clears local state', () async {
    when(
      () => tokenStorage.readRefreshToken(),
    ).thenAnswer((_) async => 'refresh-token');
    when(
      () => api.deleteMe(refreshToken: 'refresh-token'),
    ).thenAnswer((_) async {});
    when(() => tokenStorage.clearTokens()).thenAnswer((_) async {});
    when(() => localDatabase.clearAll()).thenAnswer((_) async {});

    await repository.deleteAccount();

    verify(() => api.deleteMe(refreshToken: 'refresh-token')).called(1);
    verify(() => tokenStorage.clearTokens()).called(1);
    verify(() => localDatabase.clearAll()).called(1);
  });

  test('logout clears tokens and all local account data', () async {
    when(
      () => tokenStorage.readRefreshToken(),
    ).thenAnswer((_) async => 'refresh-token');
    when(
      () => api.logout(refreshToken: 'refresh-token'),
    ).thenAnswer((_) async {});
    when(() => tokenStorage.clearTokens()).thenAnswer((_) async {});
    when(() => localDatabase.clearAll()).thenAnswer((_) async {});

    await repository.logout();

    verify(() => tokenStorage.clearTokens()).called(1);
    verify(() => localDatabase.clearAll()).called(1);
  });
}

AppUser _user({required String locale}) {
  return AppUser(
    id: 'user-1',
    email: 'alex@example.com',
    fullName: 'Alex',
    locale: locale,
  );
}
