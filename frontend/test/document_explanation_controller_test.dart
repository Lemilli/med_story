import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/core/error/app_failure.dart';
import 'package:med_story/features/documents/data/document_api.dart';
import 'package:med_story/features/documents/data/document_repository.dart';
import 'package:med_story/features/documents/domain/medical_document.dart';
import 'package:med_story/features/documents/presentation/controllers/document_controllers.dart';
import 'package:mocktail/mocktail.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}

void main() {
  late _MockDocumentRepository repository;

  setUp(() {
    repository = _MockDocumentRepository();
  });

  test('explanation provider exposes a ready explanation', () async {
    final container = ProviderContainer(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    when(
      () => repository.getDocumentExplanation('document-1'),
    ).thenAnswer((_) async => _explanation());

    final state = await container.read(
      documentExplanationProvider('document-1').future,
    );

    expect(state.isReady, isTrue);
    expect(state.explanation?.summaryText, contains('plain language'));
  });

  test('explanation provider treats not-ready as a normal state', () async {
    final container = ProviderContainer(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    when(
      () => repository.getDocumentExplanation('document-1'),
    ).thenThrow(const DocumentExplanationNotReady());

    final state = await container.read(
      documentExplanationProvider('document-1').future,
    );

    expect(state.isReady, isFalse);
    expect(state.explanation, isNull);
  });

  test('regenerate controller returns queued job result', () async {
    final container = ProviderContainer(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    when(
      () => repository.regenerateDocumentExplanation('document-1'),
    ).thenAnswer(
      (_) async =>
          const ExplanationRegenerateResult(jobId: 'job-1', status: 'queued'),
    );

    final result = await container
        .read(documentExplanationControllerProvider.notifier)
        .regenerate('document-1');

    expect(result.jobId, 'job-1');
    expect(
      container.read(documentExplanationControllerProvider).hasError,
      isFalse,
    );
  });

  test('regenerate controller exposes hard failures', () async {
    final container = ProviderContainer(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    when(
      () => repository.regenerateDocumentExplanation('document-1'),
    ).thenThrow(const AppFailure('document_explanation_regenerate_failed'));

    await expectLater(
      container
          .read(documentExplanationControllerProvider.notifier)
          .regenerate('document-1'),
      throwsA(isA<AppFailure>()),
    );
  });
}

DocumentExplanation _explanation() {
  return DocumentExplanation(
    documentId: 'document-1',
    summaryText: 'A plain language explanation.',
    keyPoints: const ['One useful point'],
    glossary: const {'CRP': 'A marker of inflammation'},
    language: 'en',
    createdAt: DateTime.utc(2026, 6),
  );
}
