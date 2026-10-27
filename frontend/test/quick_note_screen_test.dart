import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/features/capture/presentation/controllers/voice_capture_controller.dart';
import 'package:med_story/features/capture/presentation/screens/quick_note_screen.dart';
import 'package:med_story/features/documents/data/document_api.dart';
import 'package:med_story/features/documents/domain/medical_document.dart';
import 'package:med_story/features/subjects/data/subject_repository.dart';
import 'package:med_story/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockDocumentApi extends Mock implements DocumentApi {}

class _MockSubjectRepository extends Mock implements SubjectRepository {}

void main() {
  testWidgets(
    'voice completion preserves the latest edited text and submits it',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final documentApi = _MockDocumentApi();
      final subjectRepository = _MockSubjectRepository();
      final transcript = Completer<String>();
      final voice = _TestVoiceController();
      when(() => subjectRepository.listSubjects())
          .thenAnswer((_) async => const []);
      when(
        () => documentApi.transcribeAudio(
          filePath: any(named: 'filePath'),
          fileName: any(named: 'fileName'),
          mimeType: any(named: 'mimeType'),
          language: any(named: 'language'),
        ),
      ).thenAnswer((_) => transcript.future);
      when(
        () => documentApi.processNote(
          text: any(named: 'text'),
          subjectId: any(named: 'subjectId'),
          language: any(named: 'language'),
        ),
      ).thenAnswer(
        (_) async => const DocumentStatusUpdate(
          id: 'document-1',
          status: DocumentStatus.processing,
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentApiProvider.overrideWithValue(documentApi),
            subjectRepositoryProvider.overrideWithValue(subjectRepository),
            voiceCaptureControllerProvider.overrideWith(() => voice),
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
            home: const QuickNoteScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(QuickNoteScreen)),
      )!;
      await tester.enterText(find.byType(TextField), 'Typed before recording');
      await tester.tap(find.text(l10n.recordVoiceTitle));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(l10n.voiceStopAction));
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Latest edited note');
      transcript.complete('Appended transcript');
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Latest edited note\n\nAppended transcript',
      );
      expect(voice.discards, 1);
      await tester.tap(find.text(l10n.eventCreateAction));
      await tester.pump();
      verify(
        () => documentApi.processNote(
          text: 'Latest edited note\n\nAppended transcript',
          subjectId: null,
          language: 'ru',
        ),
      ).called(1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets('leaving during note polling does not access an unmounted ref', (
    tester,
  ) async {
    final documentApi = _MockDocumentApi();
    final subjectRepository = _MockSubjectRepository();
    when(() => subjectRepository.listSubjects())
        .thenAnswer((_) async => const []);
    when(
      () => documentApi.processNote(
        text: any(named: 'text'),
        subjectId: any(named: 'subjectId'),
        language: any(named: 'language'),
      ),
    ).thenAnswer(
      (_) async => const DocumentStatusUpdate(
        id: 'document-1',
        status: DocumentStatus.processing,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentApiProvider.overrideWithValue(documentApi),
          subjectRepositoryProvider.overrideWithValue(subjectRepository),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const _QuickNoteTestHost(),
        ),
      ),
    );
    await tester.tap(find.text('Open note'));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(QuickNoteScreen)),
    )!;
    await tester.enterText(find.byType(TextField), 'Synthetic medical note');
    await tester.tap(find.text(l10n.eventCreateAction));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Open note'), findsOneWidget);
    verifyNever(() => documentApi.getDocument(any()));
    expect(tester.takeException(), isNull);
  });
}

class _TestVoiceController extends VoiceCaptureController {
  int discards = 0;

  @override
  Future<VoiceCaptureState> build() async =>
      const VoiceCaptureState(stage: VoiceCaptureStage.idle);

  @override
  Future<void> startRecording() async {
    state = const AsyncData(
      VoiceCaptureState(stage: VoiceCaptureStage.recording),
    );
  }

  @override
  Future<void> stopRecording({bool maxDurationReached = false}) async {
    state = const AsyncData(
      VoiceCaptureState(
        stage: VoiceCaptureStage.recorded,
        path: '/private/tmp/synthetic-recording.m4a',
        fileName: 'synthetic-recording.m4a',
      ),
    );
  }

  @override
  Future<void> discardRecording() async {
    discards++;
    state = const AsyncData(VoiceCaptureState(stage: VoiceCaptureStage.idle));
  }
}

class _QuickNoteTestHost extends StatelessWidget {
  const _QuickNoteTestHost();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).push<void>(
            PageRouteBuilder(
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (_, _, _) => const QuickNoteScreen(),
            ),
          ),
          child: const Text('Open note'),
        ),
      ),
    );
  }
}
