import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/domain/auth_models.dart';

final consentStatusProvider = FutureProvider.autoDispose<ConsentStatus>((ref) {
  return ref.watch(authRepositoryProvider).consents();
});

final accountUsageProvider = FutureProvider.autoDispose<AccountUsage>((ref) {
  return ref.watch(authRepositoryProvider).usage();
});

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return const SettingsState();
  }

  Future<void> updateLocale(String locale) async {
    if (state.isUpdatingLocale) {
      return;
    }
    state = state.copyWith(
      isUpdatingLocale: true,
      actionMessage: null,
      actionError: null,
    );
    try {
      await ref.read(authControllerProvider.notifier).updateLocale(locale);
      state = state.copyWith(
        isUpdatingLocale: false,
        actionMessage: SettingsActionMessage.localeUpdated,
      );
    } on Object {
      state = state.copyWith(
        isUpdatingLocale: false,
        actionError: SettingsActionError.localeUpdateFailed,
      );
    }
  }

  Future<void> deleteAccount() async {
    if (state.isDeletingAccount) {
      return;
    }
    state = state.copyWith(
      isDeletingAccount: true,
      actionMessage: null,
      actionError: null,
    );
    try {
      await ref.read(authControllerProvider.notifier).deleteAccount();
      state = state.copyWith(isDeletingAccount: false);
    } on Object {
      state = state.copyWith(
        isDeletingAccount: false,
        actionError: SettingsActionError.deleteAccountFailed,
      );
    }
  }

  Future<void> updateAiConsent(bool granted) async {
    if (state.isUpdatingAiConsent) return;
    state = state.copyWith(
      isUpdatingAiConsent: true,
      actionMessage: null,
      actionError: null,
    );
    try {
      await ref.read(authRepositoryProvider).updateAiConsent(granted);
      ref.invalidate(consentStatusProvider);
      state = state.copyWith(
        isUpdatingAiConsent: false,
        actionMessage: SettingsActionMessage.aiConsentUpdated,
      );
    } on Object {
      state = state.copyWith(
        isUpdatingAiConsent: false,
        actionError: SettingsActionError.aiConsentUpdateFailed,
      );
    }
  }

  void consumeActionMessages() {
    state = state.copyWith(actionMessage: null, actionError: null);
  }
}

class SettingsState {
  const SettingsState({
    this.isUpdatingLocale = false,
    this.isDeletingAccount = false,
    this.isUpdatingAiConsent = false,
    this.actionMessage,
    this.actionError,
  });

  final bool isUpdatingLocale;
  final bool isDeletingAccount;
  final bool isUpdatingAiConsent;
  final SettingsActionMessage? actionMessage;
  final SettingsActionError? actionError;

  SettingsState copyWith({
    bool? isUpdatingLocale,
    bool? isDeletingAccount,
    bool? isUpdatingAiConsent,
    SettingsActionMessage? actionMessage,
    SettingsActionError? actionError,
  }) {
    return SettingsState(
      isUpdatingLocale: isUpdatingLocale ?? this.isUpdatingLocale,
      isDeletingAccount: isDeletingAccount ?? this.isDeletingAccount,
      isUpdatingAiConsent: isUpdatingAiConsent ?? this.isUpdatingAiConsent,
      actionMessage: actionMessage,
      actionError: actionError,
    );
  }
}

enum SettingsActionMessage { localeUpdated, aiConsentUpdated }

enum SettingsActionError {
  localeUpdateFailed,
  deleteAccountFailed,
  aiConsentUpdateFailed,
}
