import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_story/l10n/app_localizations.dart';

import 'locale/app_locale_controller.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class MedStoryApp extends ConsumerWidget {
  const MedStoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: ref.watch(appLocaleProvider),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
