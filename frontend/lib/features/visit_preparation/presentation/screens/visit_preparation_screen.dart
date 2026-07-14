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
  ConsumerState<VisitPreparationScreen> createState() =>
      _VisitPreparationScreenState();
}

class _VisitPreparationScreenState
    extends ConsumerState<VisitPreparationScreen> {
  final _note = TextEditingController();
  Future<VisitPreparation>? _load;
  String? _loadedSubject;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectState = ref.watch(subjectControllerProvider);
    final subject = subjectState.hasValue
        ? subjectState.requireValue.selectedSubjectId
        : null;
    final l10n = context.l10n;
    if (subject == null) {
      return Scaffold(appBar: AppBar(title: Text(l10n.visitPrepTitle)));
    }
    if (_loadedSubject != subject) {
      _loadedSubject = subject;
      _initialized = false;
      _note.clear();
      _load = ref.read(visitPreparationApiProvider).get(subject);
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.visitPrepTitle)),
      body: FutureBuilder<VisitPreparation>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (!_initialized) {
            _initialized = true;
            _note.text = snapshot.data?.reason ?? '';
          }
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Text(context.l10n.summaryBoundaryNote),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _note,
                    maxLength: 300,
                    maxLines: 1,
                    decoration: InputDecoration(labelText: l10n.visitPrepHint),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: _saving ? null : () => _save(subject),
                    child: Text(l10n.visitPrepSave),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () async {
                            final saved = await _save(subject, quiet: true);
                            if (mounted && saved) {
                              await ref
                                  .read(summaryRepositoryProvider)
                                  .exportPdf(subjectId: subject);
                            }
                          },
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(l10n.visitPrepExport),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _save(String subject, {bool quiet = false}) async {
    setState(() => _saving = true);
    try {
      final reason = _note.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      await ref.read(visitPreparationApiProvider).save(subject, reason);
      _note.value = TextEditingValue(
        text: reason,
        selection: TextSelection.collapsed(offset: reason.length),
      );
      if (mounted && !quiet) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.visitPrepSaved)));
      }
      return true;
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.summaryVisitReasonSaveFailed)),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
