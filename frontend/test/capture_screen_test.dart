import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/core/widgets/med_story_action_row.dart';
import 'package:med_story/features/capture/presentation/screens/capture_screen.dart';
import 'package:med_story/l10n/app_localizations.dart';

void main() {
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
          l10n.recordVoiceTitle,
        ],
      );
      await tester.scrollUntilVisible(find.text(l10n.writeNoteTitle), 160);
      await tester.scrollUntilVisible(find.text(l10n.capturePrivacyNotice), 160);
      expect(find.text(l10n.capturePrivacyNotice), findsOneWidget);

      await tester.scrollUntilVisible(find.text(l10n.writeNoteTitle), -160);
      await tester.tap(find.text(l10n.writeNoteTitle));
      await tester.pumpAndSettle();

      expect(find.text('Note editor'), findsOneWidget);
    },
  );
}
