import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/features/events/data/event_api.dart';
import 'package:med_story/features/events/data/event_repository.dart';
import 'package:med_story/features/events/domain/medical_event.dart';
import 'package:med_story/features/events/presentation/screens/event_form_screen.dart';
import 'package:med_story/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockEventRepository extends Mock implements EventRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const EventWriteRequest(
        eventType: MedicalEventType.note,
        title: '',
        eventDate: '2026-10-01',
        subjectId: 'subject-1',
      ),
    );
  });

  testWidgets(
    'narrow scaled editor validates and saves hydrated event fields',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = _MockEventRepository();
      final original = MedicalEvent(
        id: 'event-1',
        eventType: MedicalEventType.note,
        title: 'Сохранённая запись',
        description: 'Исходное описание',
        eventDate: '2026-10-01',
        eventEndDate: '2026-10-02',
        subjectId: 'subject-1',
        attributes: const {'source_fact': 'preserved'},
        tags: const ['original'],
        createdAt: DateTime.utc(2026, 10, 1),
        updatedAt: DateTime.utc(2026, 10, 1),
      );
      when(() => repository.getEvent('event-1'))
          .thenAnswer((_) async => original);
      when(
        () => repository.updateEvent('event-1', any()),
      ).thenAnswer((_) async => original.copyWith(title: 'Обновлённая запись'));
      final router = GoRouter(
        initialLocation: '/events/event-1/edit',
        routes: [
          GoRoute(
            path: '/events/:id/edit',
            builder: (_, state) =>
                EventFormScreen(eventId: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/events/:id',
            builder: (_, state) =>
                Scaffold(body: Text('Saved ${state.pathParameters['id']}')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [eventRepositoryProvider.overrideWithValue(repository)],
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
        tester.element(find.byType(EventFormScreen)),
      )!;
      final title = find.widgetWithText(TextFormField, l10n.eventTitleLabel);
      expect(
        tester.widget<TextFormField>(title).controller!.text,
        original.title,
      );
      await tester.enterText(title, '');
      final save = find.text(l10n.eventSaveAction).hitTestable();
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(save, 200, scrollable: scrollable);
      await tester.tap(save);
      await tester.pumpAndSettle();
      verifyNever(() => repository.updateEvent('event-1', any()));
      await tester.scrollUntilVisible(
        title.hitTestable(),
        -200,
        scrollable: scrollable,
      );
      expect(find.text(l10n.eventRequiredValidation), findsOneWidget);
      await tester.enterText(title, 'Обновлённая запись');
      final description = find.widgetWithText(
        TextFormField,
        l10n.eventDescriptionLabel,
      );
      await tester.scrollUntilVisible(
        description.hitTestable(),
        160,
        scrollable: scrollable,
      );
      expect(
        tester.widget<TextFormField>(description).controller!.text,
        original.description,
      );
      await tester.enterText(description, 'Новое описание');
      final tags = find.widgetWithText(TextFormField, l10n.eventTagsLabel);
      await tester.scrollUntilVisible(
        tags.hitTestable(),
        160,
        scrollable: scrollable,
      );
      expect(tester.widget<TextFormField>(tags).controller!.text, 'original');
      await tester.enterText(tags, 'original, added');
      await tester.scrollUntilVisible(save, 160, scrollable: scrollable);
      await tester.tap(save);
      await tester.pumpAndSettle();
      final saved =
          verify(() => repository.updateEvent('event-1', captureAny()))
                  .captured
                  .single
              as EventWriteRequest;
      expect(saved.title, 'Обновлённая запись');
      expect(saved.description, 'Новое описание');
      expect(saved.tags, ['original', 'added']);
      expect(saved.eventDate, original.eventDate);
      expect(saved.eventEndDate, original.eventEndDate);
      expect(saved.eventType, original.eventType);
      expect(saved.subjectId, original.subjectId);
      expect(saved.attributes, original.attributes);
      expect(find.text('Saved event-1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
