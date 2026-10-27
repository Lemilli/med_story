import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/features/documents/data/document_repository.dart';
import 'package:med_story/features/documents/domain/medical_document.dart';
import 'package:med_story/features/documents/presentation/screens/document_detail_screen.dart';
import 'package:med_story/features/events/data/event_repository.dart';
import 'package:med_story/features/events/domain/medical_event.dart';
import 'package:med_story/features/events/presentation/screens/event_detail_screen.dart';
import 'package:med_story/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockEventRepository extends Mock implements EventRepository {}

class _MockDocumentRepository extends Mock implements DocumentRepository {}

void main() {
  for (final isDocument in [false, true]) {
    final kind = isDocument ? 'document' : 'event';
    testWidgets(
      '$kind deletion requires confirmation and returns to timeline',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final events = _MockEventRepository();
        final documents = _MockDocumentRepository();
        when(() => events.getEvent('event-1')).thenAnswer(
          (_) async => MedicalEvent(
            id: 'event-1',
            eventType: MedicalEventType.note,
            title: 'Synthetic retained event',
            description: 'Synthetic original note',
            eventDate: '2026-10-01',
            subjectId: 'subject-1',
            createdAt: DateTime.utc(2026, 10, 1),
            updatedAt: DateTime.utc(2026, 10, 1),
          ),
        );
        when(() => events.deleteEvent('event-1')).thenAnswer((_) async {});
        when(() => documents.getDocument('document-1')).thenAnswer(
          (_) async => const MedicalDocument(
            id: 'document-1',
            title: 'Synthetic retained document',
            status: DocumentStatus.processed,
          ),
        );
        when(() => documents.deleteDocument('document-1'))
            .thenAnswer((_) async {});
        final router = GoRouter(
          initialLocation: '/detail',
          routes: [
            GoRoute(
              path: '/detail',
              builder: (_, _) => isDocument
                  ? const DocumentDetailScreen(documentId: 'document-1')
                  : const EventDetailScreen(eventId: 'event-1'),
            ),
            GoRoute(
              path: '/timeline',
              builder: (_, _) =>
                  const Scaffold(body: Text('Returned to timeline')),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              eventRepositoryProvider.overrideWithValue(events),
              documentRepositoryProvider.overrideWithValue(documents),
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
        final detail = isDocument
            ? find.byType(DocumentDetailScreen)
            : find.byType(EventDetailScreen);
        final l10n = AppLocalizations.of(tester.element(detail))!;
        final deleteLabel = isDocument
            ? l10n.documentDeleteAction
            : l10n.eventDeleteAction;
        final deleteAction = find.text(deleteLabel).hitTestable();
        await tester.scrollUntilVisible(deleteAction, 180);
        await tester.tap(deleteAction);
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsOneWidget);
      final dialogScroll = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(Scrollable),
      ).first;
      final cancel = find.text(l10n.eventCancelAction).hitTestable();
      await tester.scrollUntilVisible(cancel, 160, scrollable: dialogScroll);
      await tester.tap(cancel);
        await tester.pumpAndSettle();
        verifyNever(() => events.deleteEvent(any()));
        verifyNever(() => documents.deleteDocument(any()));
        expect(detail, findsOneWidget);
        await tester.tap(deleteAction);
        await tester.pumpAndSettle();
        final confirm = find.descendant(
          of: find.byType(Dialog),
          matching: find.widgetWithText(FilledButton, deleteLabel),
      ).hitTestable();
      await tester.scrollUntilVisible(confirm, 160, scrollable: dialogScroll);
        await tester.tap(confirm);
        await tester.pumpAndSettle();
        if (isDocument) {
          verify(() => documents.deleteDocument('document-1')).called(1);
          verifyNever(() => events.deleteEvent(any()));
        } else {
          verify(() => events.deleteEvent('event-1')).called(1);
          verifyNever(() => documents.deleteDocument(any()));
        }
        expect(find.text('Returned to timeline'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
