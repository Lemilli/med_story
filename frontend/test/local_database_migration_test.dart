import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/core/storage/local_database.dart';

void main() {
  test('v9 migration replaces only the unowned upload queue', () async {
    final database = LocalDatabase.forTesting(
      NativeDatabase.memory(
        setup: (rawDatabase) {
          rawDatabase.execute(
            'CREATE TABLE upload_queue_items (id TEXT PRIMARY KEY NOT NULL)',
          );
          rawDatabase.execute(
            "INSERT INTO upload_queue_items (id) VALUES ('legacy-upload')",
          );
          rawDatabase.execute(
            'CREATE TABLE migration_sentinel (value TEXT NOT NULL)',
          );
          rawDatabase.execute(
            "INSERT INTO migration_sentinel (value) VALUES ('preserved')",
          );
          rawDatabase.execute('PRAGMA user_version = 8');
        },
      ),
    );
    addTearDown(database.close);

    expect(await database.select(database.uploadQueueItems).get(), isEmpty);
    expect(
      (await database
              .customSelect('SELECT value FROM migration_sentinel')
              .getSingle())
          .read<String>('value'),
      'preserved',
    );

    final now = DateTime.utc(2026, 8, 5);
    await database
        .into(database.uploadQueueItems)
        .insert(
          UploadQueueItemsCompanion.insert(
            id: 'owned-upload',
            ownerUserId: 'user-1',
            displayName: 'lab.pdf',
            fingerprint: 'lab.pdf::3',
            localPath: '/local/lab.pdf',
            storedFileName: 'lab.pdf',
            mimeType: 'application/pdf',
            sizeBytes: 3,
            docType: 'labResult',
            title: 'Lab results',
            status: 'failed',
            createdAt: now,
            updatedAt: now,
          ),
        );
    expect(
      (await database.select(database.uploadQueueItems).getSingle())
          .ownerUserId,
      'user-1',
    );
  });
}
