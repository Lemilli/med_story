import '../../../l10n/app_localizations.dart';
import '../domain/medical_event.dart';

extension EventTypeL10n on MedicalEventType {
  String label(AppLocalizations l10n) {
    return switch (this) {
      MedicalEventType.symptom => l10n.eventTypeSymptom,
      MedicalEventType.diagnosis => l10n.eventTypeDiagnosis,
      MedicalEventType.medication => l10n.eventTypeMedication,
      MedicalEventType.examination => l10n.eventTypeExamination,
      MedicalEventType.procedure => l10n.eventTypeProcedure,
      MedicalEventType.hospitalization => l10n.eventTypeHospitalization,
      MedicalEventType.treatmentOutcome => l10n.eventTypeTreatmentOutcome,
      MedicalEventType.note => l10n.eventTypeNote,
    };
  }
}
