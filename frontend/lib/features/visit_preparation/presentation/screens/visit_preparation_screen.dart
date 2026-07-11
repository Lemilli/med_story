import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/l10n.dart';
import '../../../subjects/presentation/controllers/subject_controller.dart';
import '../../../summary/data/summary_repository.dart';
import '../../data/visit_preparation_api.dart';

class VisitPreparationScreen extends ConsumerStatefulWidget {
  const VisitPreparationScreen({super.key});
  @override
  ConsumerState<VisitPreparationScreen> createState() => _VisitPreparationScreenState();
}

class _VisitPreparationScreenState extends ConsumerState<VisitPreparationScreen> {
  final _note = TextEditingController();
  Future<VisitPreparation>? _load;
  bool _saving = false;

  @override
  void dispose() { _note.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final subjectState = ref.watch(subjectControllerProvider);
    final subject = subjectState.hasValue ? subjectState.requireValue.selectedSubjectId : null;
    final l10n = context.l10n;
    if (subject == null) return Scaffold(appBar: AppBar(title: Text(l10n.visitPrepTitle)));
    _load ??= ref.read(visitPreparationApiProvider).get(subject);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.visitPrepTitle)),
      body: FutureBuilder<VisitPreparation>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
          if (_note.text.isEmpty) _note.text = snapshot.data?.note ?? '';
          return SafeArea(child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(children: [
              Text(context.l10n.summaryBoundaryNote),
              const SizedBox(height: AppSpacing.lg),
              Expanded(child: TextField(
                controller: _note, expands: true, minLines: null, maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(labelText: l10n.visitPrepHint),
              )),
              const SizedBox(height: AppSpacing.md),
              FilledButton(onPressed: _saving ? null : () => _save(subject), child: Text(l10n.visitPrepSave)),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _saving ? null : () async {
                  await _save(subject, quiet: true);
                  if (mounted) await ref.read(summaryRepositoryProvider).exportPdf(subjectId: subject);
                },
                icon: const Icon(Icons.ios_share_rounded), label: Text(l10n.visitPrepExport),
              ),
            ]),
          ));
        },
      ),
    );
  }

  Future<void> _save(String subject, {bool quiet = false}) async {
    setState(() => _saving = true);
    try {
      await ref.read(visitPreparationApiProvider).save(subject, _note.text.trim());
      if (mounted && !quiet) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.visitPrepSaved)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
