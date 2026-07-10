import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/features/settings/data/privacy_api.dart';
import 'package:med_story/features/settings/data/privacy_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockPrivacyApi extends Mock implements PrivacyApi {}

class _FakePrivacyShareService implements PrivacyShareService {
  Map<String, dynamic>? sharedPayload;

  @override
  Future<void> shareJson(Map<String, dynamic> payload) async {
    sharedPayload = payload;
  }
}

void main() {
  test('exports privacy payload through share service', () async {
    final api = _MockPrivacyApi();
    final shareService = _FakePrivacyShareService();
    final repository = PrivacyRepository(api: api, shareService: shareService);
    final payload = {
      'profile': {'email': 'alex@example.com'},
      'medical_events': [
        {'title': 'Pain flare'},
      ],
    };

    when(() => api.exportData()).thenAnswer((_) async => payload);

    await repository.exportAndShareData();

    expect(shareService.sharedPayload, payload);
  });
}
