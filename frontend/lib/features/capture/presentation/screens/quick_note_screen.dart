import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/l10n.dart';
import '../../../events/data/event_api.dart';
import '../../../events/domain/medical_event.dart';
import '../../../events/presentation/controllers/event_controllers.dart';
import '../../../subjects/presentation/controllers/subject_controller.dart';

class QuickNoteScreen extends ConsumerStatefulWidget {
  const QuickNoteScreen({super.key});

  @override
  ConsumerState<QuickNoteScreen> createState() => _QuickNoteScreenState();
}

class _QuickNoteScreenState extends ConsumerState<QuickNoteScreen> {
  final _controller = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final saving = ref.watch(eventFormControllerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.writeNoteTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Text(l10n.writeNoteDescription),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    labelText: l10n.eventDescriptionLabel,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    initialDate: _date,
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                icon: const Icon(Icons.calendar_today_rounded),
                label: Text(
                  '${l10n.eventDateLabel}: ${_date.toIso8601String().substring(0, 10)}',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.eventCreateAction),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    final subjectState = ref.read(subjectControllerProvider);
    final subjectId = subjectState.hasValue
        ? subjectState.value?.selectedSubjectId
        : null;
    if (text.isEmpty || subjectId == null) return;
    final firstLine = text
        .split(RegExp(r'\r?\n'))
        .firstWhere((line) => line.trim().isNotEmpty, orElse: () => '')
        .trim();
    final title = firstLine.isEmpty
        ? context.l10n.documentUntitledTitle
        : firstLine;
    final event = await ref
        .read(eventFormControllerProvider.notifier)
        .create(
          EventWriteRequest(
            eventType: MedicalEventType.note,
            title: title.length > 255 ? title.substring(0, 255) : title,
            description: text,
            eventDate: _date.toIso8601String().substring(0, 10),
            subjectId: subjectId,
          ),
        );
    if (mounted) context.go('/events/${event.id}');
  }
}
