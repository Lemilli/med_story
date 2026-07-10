import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/features/capture/presentation/screens/capture_screen.dart';
import 'package:med_story/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'capture screen shows active document and voice inputs with deferred notes',
    (tester) async {
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

      expect(find.text(l10n.captureHeadline), findsOneWidget);
      expect(find.text(l10n.scanDocumentTitle), findsOneWidget);
      expect(find.text(l10n.addPhotoTitle), findsOneWidget);
      expect(find.text(l10n.chooseFileTitle), findsOneWidget);
      expect(find.text(l10n.documentSelectionEmpty), findsOneWidget);
      await tester.scrollUntilVisible(find.text(l10n.recordVoiceTitle), 160);
      expect(find.text(l10n.recordVoiceTitle), findsOneWidget);
      expect(find.text(l10n.recordVoiceDescription), findsOneWidget);
      await tester.scrollUntilVisible(find.text(l10n.writeNoteTitle), 160);
      expect(find.text(l10n.writeNoteTitle), findsOneWidget);
      expect(find.text(l10n.writeNoteDeferredDescription), findsOneWidget);
      await tester.scrollUntilVisible(find.text(l10n.privacyPanelTitle), 160);
      expect(find.text(l10n.privacyPanelTitle), findsOneWidget);
      expect(find.text(l10n.boundaryNote), findsOneWidget);
    },
  );
}
