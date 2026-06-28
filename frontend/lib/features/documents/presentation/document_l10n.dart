import '../../../l10n/app_localizations.dart';
import '../domain/medical_document.dart';

extension DocumentTypeL10n on DocumentType {
  String label(AppLocalizations l10n) {
    return switch (this) {
      DocumentType.labResult => l10n.documentTypeLabResult,
      DocumentType.report => l10n.documentTypeReport,
      DocumentType.prescription => l10n.documentTypePrescription,
      DocumentType.procedureSummary => l10n.documentTypeProcedureSummary,
      DocumentType.note => l10n.documentTypeNote,
      DocumentType.image => l10n.documentTypeImage,
      DocumentType.audio => l10n.documentTypeAudio,
      DocumentType.other => l10n.documentTypeOther,
    };
  }
}

extension DocumentStatusL10n on DocumentStatus {
  String label(AppLocalizations l10n) {
    return switch (this) {
      DocumentStatus.pendingIngest => l10n.documentStatusPending,
      DocumentStatus.processing => l10n.documentStatusProcessing,
      DocumentStatus.processed => l10n.documentStatusProcessed,
      DocumentStatus.failed => l10n.documentStatusFailed,
    };
  }
}
