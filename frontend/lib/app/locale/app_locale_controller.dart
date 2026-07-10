import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../l10n/app_localizations.dart';

final appLocaleProvider = Provider<Locale?>((ref) {
  final authState = ref.watch(authControllerProvider);
  final localeCode = authState.asData?.value.user?.locale.trim();
  if (localeCode == null || localeCode.isEmpty) {
    return null;
  }
  final supported = AppLocalizations.supportedLocales.any(
    (locale) => locale.languageCode == localeCode,
  );
  return supported ? Locale(localeCode) : null;
});
