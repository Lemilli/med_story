import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/core/widgets/med_story_action_row.dart';
import 'package:med_story/features/capture/presentation/screens/capture_screen.dart';
import 'package:med_story/features/documents/data/document_repository.dart';
import 'package:med_story/features/documents/domain/medical_document.dart';
import 'package:med_story/features/documents/presentation/controllers/document_controllers.dart';
import 'package:med_story/features/subjects/data/subject_repository.dart';
import 'package:med_story/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  testWidgets(
    'photo grouping retains ordered pages through add, remove and submit',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final pages = (await tester.runAsync(() async {
        final directory = await Directory.systemTemp.createTemp(
          'capture-pages-',
        );
        addTearDown(() => directory.delete(recursive: true));
        final recorder = ui.PictureRecorder();
        Canvas(recorder).drawColor(Colors.white, BlendMode.src);
        final picture = recorder.endRecording();
        final image = await picture.toImage(20, 28);
        final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();
        picture.dispose();
        image.dispose();
        final paths = <String>[];
        for (var index = 0; index < 3; index++) {
          final file = File('${directory.path}/page-$index.png');
          await file.writeAsBytes(bytes);
          paths.add(file.path);
        }
        return paths;
      }))!;
      const channel = MethodChannel('plugins.flutter.io/image_picker');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (call) async => switch (call.method) {
          'pickMultiImage' => pages.take(2).toList(),
          'pickImage' => pages[2],
          _ => null,
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      final queue = _TestUploadController([]);
      final subjects = _MockSubjectRepository();
      when(() => subjects.listSubjects()).thenAnswer((_) async => const []);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentUploadControllerProvider.overrideWith(() => queue),
            subjectRepositoryProvider.overrideWithValue(subjects),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ru'),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.5)),
              child: child!,
            ),
            home: const Scaffold(body: CaptureScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(CaptureScreen)),
      )!;
      await tester.tap(find.text(l10n.addPhotoTitle));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(l10n.photoGroupingSeparateTitle));
      await tester.tap(find.text(l10n.photoGroupingSeparateTitle));
      await tester.pump();
      await tester.ensureVisible(find.text(l10n.photoGroupingOneTitle));
      await tester.tap(find.text(l10n.photoGroupingOneTitle));
      await tester.pump();
      await tester.ensureVisible(find.text(l10n.photoGroupingContinueAction));
      await tester.tap(find.text(l10n.photoGroupingContinueAction));
      await tester.pumpAndSettle();
      expect(queue.enqueued, isEmpty);
      expect(find.text(l10n.documentPagesCount(2)), findsOneWidget);
      expect(tester.takeException(), isNull);

      final firstPage = find.byKey(ValueKey(pages[0]));
      final semantics = find
          .ancestor(of: firstPage, matching: find.byType(Semantics))
          .evaluate()
          .map((element) => element.widget as Semantics)
          .firstWhere(
            (widget) =>
                widget.properties.customSemanticsActions?.isNotEmpty == true,
          );
      semantics.properties.customSemanticsActions![CustomSemanticsAction(
        label: WidgetsLocalizations.of(tester.element(firstPage)).reorderItemDown,
      )]!();
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<ListTile>(find.byType(ListTile))
            .map((tile) => tile.key),
        [ValueKey(pages[1]), ValueKey(pages[0])],
      );
      await tester.tap(find.text(l10n.documentPageAddAction));
      await tester.pumpAndSettle();
      expect(find.text(l10n.documentPagesCount(3)), findsOneWidget);
      await tester.tap(find.byTooltip(l10n.documentPageRemoveAction).first);
      await tester.pumpAndSettle();
      expect(find.text(l10n.documentPagesCount(2)), findsOneWidget);
      await tester.tap(find.text(l10n.documentPagesProcessAction));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      await tester.pumpAndSettle();
      expect(queue.enqueued, hasLength(1));
      expect(queue.enqueued.single.sources.map((source) => source.path), [
        pages[0],
        pages[2],
      ]);
      expect(queue.enqueued.single.language, 'ru');
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(l10n.addPhotoTitle));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(l10n.photoGroupingSeparateTitle));
      await tester.tap(find.text(l10n.photoGroupingSeparateTitle));
      await tester.pump();
      await tester.ensureVisible(find.text(l10n.photoGroupingContinueAction));
      await tester.tap(find.text(l10n.photoGroupingContinueAction));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      await tester.pumpAndSettle();
      for (
        var attempt = 0;
        attempt < 20 && queue.enqueued.length < 3;
        attempt++
      ) {
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });
        await tester.pump();
      }
      expect(queue.enqueued, hasLength(3));
      expect(
        queue.enqueued.skip(1).map((draft) => draft.sources.single.path),
        pages.take(2),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'scaled Russian queue keeps retry, dismissal and result navigation',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final queue = _TestUploadController([
        _queuedItem('failed', UploadQueueStage.failed),
        _queuedItem('complete', UploadQueueStage.completed),
      ]);
      final repository = _MockDocumentRepository();
      when(() => repository.getDocument('document-complete')).thenAnswer(
        (_) async => const MedicalDocument(
          id: 'document-complete',
          eventId: 'event-result',
        ),
      );
      final router = GoRouter(
        initialLocation: '/capture',
        routes: [
          GoRoute(path: '/capture', builder: (_, _) => const CaptureScreen()),
          GoRoute(
            path: '/events/:id',
            builder: (_, state) =>
                Scaffold(body: Text('Opened ${state.pathParameters['id']}')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentUploadControllerProvider.overrideWith(() => queue),
            documentRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ru'),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.5)),
              child: child!,
            ),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(CaptureScreen)),
      )!;
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(l10n.documentRetryAction));
      await tester.pump();
      expect(queue.retried, 'failed');
      await tester.tap(find.text(l10n.uploadQueueDismissAction).first);
      await tester.pump();
      expect(queue.dismissed, 'failed');
      final result = find.text(
        'Synthetic complete record with a long source title',
      );
      await tester.scrollUntilVisible(result, 120);
      await tester.tap(result);
      await tester.pumpAndSettle();
      expect(find.text('Opened event-result'), findsOneWidget);
      verify(() => repository.getDocument('document-complete')).called(1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'file browsing supports cancellation and checks unknown sizes without reading bytes',
    (tester) async {
      final originalPlatform = FilePickerPlatform.instance;
      final picker = _FilePickerPlatform();
      FilePickerPlatform.instance = picker;
      addTearDown(() => FilePickerPlatform.instance = originalPlatform);
      final source = (await tester.runAsync(() async {
        final directory = await Directory.systemTemp.createTemp(
          'capture-picker-',
        );
        addTearDown(() => directory.delete(recursive: true));
        final source = File('${directory.path}/medical-record.pdf');
        final handle = await source.open(mode: FileMode.write);
        await handle.truncate(25 * 1024 * 1024 + 1);
        await handle.close();
        return source;
      }))!;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(body: CaptureScreen()),
          ),
        ),
      );
      final l10n = AppLocalizations.of(
        tester.element(find.byType(CaptureScreen)),
      )!;
      await tester.scrollUntilVisible(find.text(l10n.chooseFileTitle), 160);
      await tester.tap(find.text(l10n.chooseFileTitle));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(picker.selections, 1);

      final file = _PickedFile(source);
      picker.file = file;
      await tester.tap(find.text(l10n.chooseFileTitle));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      await tester.pumpAndSettle();
      expect(find.text(l10n.documentFileTooLargeMessage), findsOneWidget);
      expect(file.byteReads, 0);
      expect(source.existsSync(), isTrue);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'capture screen shows clear source-based actions and opens notes',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/capture',
        routes: [
          GoRoute(
            path: '/capture',
            builder: (context, state) => const CaptureScreen(),
          ),
          GoRoute(
            path: '/notes/new',
            builder: (context, state) =>
                const Scaffold(body: Text('Note editor')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            routerConfig: router,
          ),
        ),
      );

      final l10n = AppLocalizations.of(
        tester.element(find.byType(CaptureScreen)),
      )!;

      expect(find.text(l10n.captureHeadline), findsOneWidget);
      expect(find.text(l10n.scanDocumentTitle), findsOneWidget);
      expect(find.text(l10n.addPhotoTitle), findsOneWidget);
      expect(find.text(l10n.chooseFileTitle), findsOneWidget);
      expect(find.text(l10n.addPhotoDescription), findsOneWidget);
      expect(find.text(l10n.chooseFileDescription), findsOneWidget);
      expect(l10n.addPhotoTitle, 'Add a photo');
      expect(l10n.chooseFileTitle, 'Browse files');
      expect(
        tester
            .widgetList<MedStoryActionRow>(find.byType(MedStoryActionRow))
            .map((row) => row.title),
        [
          l10n.addPhotoTitle,
          l10n.scanDocumentTitle,
          l10n.chooseFileTitle,
          l10n.writeNoteTitle,
        ],
      );
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
      await tester.scrollUntilVisible(find.text(l10n.writeNoteTitle), 160);
      await tester.scrollUntilVisible(
        find.text(l10n.capturePrivacyNotice),
        160,
      );
      expect(find.text(l10n.capturePrivacyNotice), findsOneWidget);

      await tester.scrollUntilVisible(find.text(l10n.writeNoteTitle), -160);
      await tester.tap(find.text(l10n.writeNoteTitle));
      await tester.pumpAndSettle();

      expect(find.text('Note editor'), findsOneWidget);
    },
  );
}

class _MockDocumentRepository extends Mock implements DocumentRepository {}

class _MockSubjectRepository extends Mock implements SubjectRepository {}

class _TestUploadController extends DocumentUploadController {
  _TestUploadController(this.items);

  final List<QueuedUpload> items;
  String? retried;
  String? dismissed;
  final enqueued = <DocumentUploadDraft>[];

  @override
  Future<List<QueuedUpload>> build() async => items;

  @override
  Future<UploadEnqueueResult> enqueue(DocumentUploadDraft draft) async {
    enqueued.add(draft);
    return UploadEnqueueResult.enqueued;
  }

  @override
  Future<void> retry(String id) async {
    retried = id;
  }

  @override
  Future<void> dismiss(String id) async {
    dismissed = id;
  }
}

QueuedUpload _queuedItem(String id, UploadQueueStage stage) => QueuedUpload(
  id: id,
  ownerUserId: 'synthetic-user',
  displayName: 'Synthetic $id record with a long source title',
  fingerprint: id,
  localFiles: const [
    StoredDocumentFile(
      path: '/private/tmp/synthetic.pdf',
      fileName: 'synthetic.pdf',
      mimeType: 'application/pdf',
      sizeBytes: 100,
      localUriHint: '',
    ),
  ],
  draft: const DocumentUploadDraft(
    title: 'Synthetic record',
    docType: DocumentType.report,
    sources: [
      DocumentSourceFile(
        path: '/private/tmp/synthetic.pdf',
        fileName: 'synthetic.pdf',
        mimeType: 'application/pdf',
      ),
    ],
  ),
  stage: stage,
  documentId: 'document-$id',
  createdAt: DateTime(2026, 10, 28),
  updatedAt: DateTime(2026, 10, 28),
);

class _FilePickerPlatform extends FilePickerPlatform {
  PlatformFile? file;
  int selections = 0;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    selections++;
    return file;
  }
}

final class _PickedFile extends PlatformFile {
  _PickedFile(this.file);

  final File file;
  int byteReads = 0;

  @override
  String get name => 'medical-record.pdf';

  @override
  Uri get uri => file.uri;

  @override
  XFile get xFile => XFile(file.path);

  @override
  int? lengthSync() => null;

  @override
  Future<int?> length() => file.length();

  @override
  Future<Uint8List> readAsBytes() async {
    byteReads++;
    return file.readAsBytes();
  }

  @override
  Stream<Uint8List> readAsByteStream() {
    byteReads++;
    return file.openRead().map(Uint8List.fromList);
  }
}
