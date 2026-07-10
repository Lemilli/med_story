import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/privacy_repository.dart';

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return const SettingsState();
  }

  Future<void> exportPrivacyData() async {
    if (state.isExporting) {
      return;
    }
    state = state.copyWith(
      isExporting: true,
      actionMessage: null,
      actionError: null,
    );
    try {
      await ref.read(privacyRepositoryProvider).exportAndShareData();
      state = state.copyWith(
        isExporting: false,
        actionMessage: SettingsActionMessage.exportShared,
      );
    } on Object {
      state = state.copyWith(
        isExporting: false,
        actionError: SettingsActionError.exportFailed,
      );
    }
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

  void consumeActionMessages() {
    state = state.copyWith(actionMessage: null, actionError: null);
  }
}

class SettingsState {
  const SettingsState({
    this.isExporting = false,
    this.isUpdatingLocale = false,
    this.isDeletingAccount = false,
    this.actionMessage,
    this.actionError,
  });

  final bool isExporting;
  final bool isUpdatingLocale;
  final bool isDeletingAccount;
  final SettingsActionMessage? actionMessage;
  final SettingsActionError? actionError;

  SettingsState copyWith({
    bool? isExporting,
    bool? isUpdatingLocale,
    bool? isDeletingAccount,
    SettingsActionMessage? actionMessage,
    SettingsActionError? actionError,
  }) {
    return SettingsState(
      isExporting: isExporting ?? this.isExporting,
      isUpdatingLocale: isUpdatingLocale ?? this.isUpdatingLocale,
      isDeletingAccount: isDeletingAccount ?? this.isDeletingAccount,
      actionMessage: actionMessage,
      actionError: actionError,
    );
  }
}

enum SettingsActionMessage { exportShared, localeUpdated }

enum SettingsActionError {
  exportFailed,
  localeUpdateFailed,
  deleteAccountFailed,
}
