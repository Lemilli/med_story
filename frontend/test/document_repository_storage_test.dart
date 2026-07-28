import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/features/documents/data/document_api.dart';
import 'package:med_story/features/documents/data/document_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockDocumentApi extends Mock implements DocumentApi {}

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'medstory-source-ownership',
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('source preparation never creates a durable app copy', () async {
    final source = File('${temporaryDirectory.path}/medical-page.png');
    await source.writeAsBytes([1, 2, 3]);

    final stored = await const AppSandboxDocumentFileStore().save(
      DocumentSourceFile(
        path: source.path,
        fileName: 'medical-page.png',
        mimeType: 'image/png',
        deleteAfterUpload: true,
      ),
    );

    expect(stored.path, source.path);
    expect(stored.localUriHint, isEmpty);
    expect(stored.deleteAfterUpload, isTrue);
    expect(await source.exists(), isTrue);
  });

  test(
    'cleanup deletes MedStory-owned captures but not external sources',
    () async {
      final owned = File('${temporaryDirectory.path}/owned.png');
      final external = File('${temporaryDirectory.path}/external.pdf');
      await owned.writeAsBytes([1]);
      await external.writeAsBytes([2]);
      final repository = DocumentRepository(
        api: _MockDocumentApi(),
        localFileStore: const AppSandboxDocumentFileStore(),
      );

      await repository.deleteOwnedSources([
        StoredDocumentFile(
          path: owned.path,
          fileName: 'owned.png',
          mimeType: 'image/png',
          sizeBytes: 1,
          localUriHint: '',
          deleteAfterUpload: true,
        ),
        StoredDocumentFile(
          path: external.path,
          fileName: 'external.pdf',
          mimeType: 'application/pdf',
          sizeBytes: 1,
          localUriHint: '',
        ),
      ]);

      expect(await owned.exists(), isFalse);
      expect(await external.exists(), isTrue);
    },
  );
}
