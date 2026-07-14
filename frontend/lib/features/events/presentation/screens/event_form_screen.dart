import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/l10n.dart';
import '../../../subjects/presentation/controllers/subject_controller.dart';
import '../../data/event_api.dart';
import '../../domain/medical_event.dart';
import '../controllers/event_controllers.dart';
import '../event_type_l10n.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({this.eventId, super.key});

  final String? eventId;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  MedicalEventType _eventType = MedicalEventType.note;
  DateTime _eventDate = DateTime.now();
  DateTime? _eventEndDate;
  bool _didHydrate = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventId = widget.eventId;
    if (eventId != null) {
      final detail = ref.watch(eventDetailProvider(eventId));
      return detail.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text(error.toString())),
        ),
        data: (event) {
          _hydrate(event);
          return _buildForm(context, existingEvent: event);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context, {MedicalEvent? existingEvent}) {
    final l10n = context.l10n;
    final formState = ref.watch(eventFormControllerProvider);
    final isEditing = existingEvent != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.eventEditTitle : l10n.eventNewTitle),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xxxl,
            ),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l10n.eventTitleLabel),
                textInputAction: TextInputAction.next,
                validator: (value) => _required(value, l10n),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<MedicalEventType>(
                initialValue: _eventType,
                decoration: InputDecoration(labelText: l10n.eventTypeLabel),
                items: MedicalEventType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label(l10n)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _eventType = value);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _DateField(
                label: l10n.eventDateLabel,
                value: _eventDate,
                onTap: () async {
                  final picked = await _pickDate(context, _eventDate);
                  if (picked != null) {
                    setState(() => _eventDate = picked);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _DateField(
                label: l10n.eventEndDateLabel,
                value: _eventEndDate,
                onTap: () async {
                  final picked = await _pickDate(
                    context,
                    _eventEndDate ?? _eventDate,
                  );
                  if (picked != null) {
                    setState(() => _eventEndDate = picked);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.eventDescriptionLabel,
                ),
                minLines: 3,
                maxLines: 6,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: l10n.eventTagsLabel,
                  helperText: l10n.eventTagsHelper,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _BoundaryNote(text: l10n.eventBoundaryNote),
              const SizedBox(height: AppSpacing.lg),
              if (formState.hasError) ...[
                _ErrorNotice(message: formState.error.toString()),
                const SizedBox(height: AppSpacing.md),
              ],
              FilledButton(
                onPressed: formState.isLoading
                    ? null
                    : () => _save(context, existingEvent),
                child: formState.isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isEditing
                            ? l10n.eventSaveAction
                            : l10n.eventCreateAction,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _hydrate(MedicalEvent event) {
    if (_didHydrate) {
      return;
    }
    _didHydrate = true;
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _tagsController.text = event.tags.join(', ');
    _eventType = event.eventType;
    _eventDate = DateTime.tryParse(event.eventDate) ?? DateTime.now();
    _eventEndDate = event.eventEndDate == null
        ? null
        : DateTime.tryParse(event.eventEndDate!);
  }

  Future<void> _save(BuildContext context, MedicalEvent? existingEvent) async {
    final subjectId =
        existingEvent?.subjectId ??
        (ref.read(subjectControllerProvider).hasValue
            ? ref.read(subjectControllerProvider).value?.selectedSubjectId
            : null);
    if (!_formKey.currentState!.validate() || subjectId == null) {
      return;
    }

    final request = EventWriteRequest(
      eventType: _eventType,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      eventDate: _dateOnly(_eventDate),
      eventEndDate: _eventEndDate == null ? null : _dateOnly(_eventEndDate!),
      // Extracted structured data is kept for downstream summaries, but is not
      // a user-editable field in this simple event editor.
      attributes: existingEvent?.attributes ?? <String, dynamic>{},
      tags: _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList(),
      subjectId: subjectId,
    );

    final notifier = ref.read(eventFormControllerProvider.notifier);
    final saved = existingEvent == null
        ? await notifier.create(request)
        : await notifier.saveUpdate(existingEvent.id, request);
    if (context.mounted) {
      context.go('/events/${saved.id}');
    }
  }

  String? _required(String? value, dynamic l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.eventRequiredValidation;
    }
    return null;
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? '' : _dateOnly(value!);
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: text),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today_rounded),
      ),
      onTap: onTap,
    );
  }
}

class _BoundaryNote extends StatelessWidget {
  const _BoundaryNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.shield_outlined,
          color: AppColors.deepClinicalBlue,
          size: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.quietSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.clinicalLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(message),
      ),
    );
  }
}

Future<DateTime?> _pickDate(BuildContext context, DateTime initialDate) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(1900),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );
}

String _dateOnly(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
