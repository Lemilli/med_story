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
}

AppUser _user({required String locale}) {
  return AppUser(
    id: 'user-1',
    email: 'alex@example.com',
    fullName: 'Alex',
    locale: locale,
  );
}
