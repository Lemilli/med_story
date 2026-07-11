import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/l10n.dart';
import '../../../documents/data/document_api.dart';
import '../../../events/domain/medical_event.dart';
import '../../../events/presentation/controllers/event_controllers.dart';
import '../../../subjects/presentation/controllers/subject_controller.dart';
import '../../../timeline/data/timeline_api.dart';
import '../../../timeline/domain/timeline_filters.dart';

class ReviewInboxScreen extends ConsumerStatefulWidget {
  const ReviewInboxScreen({super.key});
  @override ConsumerState<ReviewInboxScreen> createState() => _ReviewInboxScreenState();
}
class _ReviewInboxScreenState extends ConsumerState<ReviewInboxScreen> {
  Future<TimelinePage>? _page;
  @override Widget build(BuildContext context) {
    final subjectState = ref.watch(subjectControllerProvider);
    final subject = subjectState.hasValue ? subjectState.requireValue.selectedSubjectId : null;
    final l10n = context.l10n;
    if (subject == null) return Scaffold(appBar: AppBar(title: Text(l10n.reviewTitle)));
    _page ??= ref.read(timelineApiProvider).fetchTimeline(subjectId: subject, filters: const TimelineFilters(confirmed: false), limit: 100);
    return Scaffold(appBar: AppBar(title: Text(l10n.reviewTitle)), body: FutureBuilder<TimelinePage>(future: _page, builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
      final items = snapshot.data!.results;
      if (items.isEmpty) return Center(child: Text(l10n.reviewEmpty));
      final event = items.first;
      return Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm), Text(event.description.isEmpty ? event.eventType.apiName : event.description),
        if (event.sourceDocumentId != null) ...[const SizedBox(height: AppSpacing.sm), Text(l10n.eventAiSuggestedNote)],
        const Spacer(),
        FilledButton.icon(onPressed: () => _confirm(event.id), icon: const Icon(Icons.check_rounded), label: Text(l10n.eventConfirmAction)),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(onPressed: () => context.push('/events/${event.id}/edit'), icon: const Icon(Icons.edit_outlined), label: Text(l10n.reviewEdit)),
        const SizedBox(height: AppSpacing.sm),
        TextButton(onPressed: () => _dismiss(event.id), child: Text(l10n.reviewDismiss)),
      ]));
    }));
  }
  Future<void> _confirm(String id) async { await ref.read(eventFormControllerProvider.notifier).confirm(id); if (mounted) setState(() => _page = null); }
  Future<void> _dismiss(String id) async { await ref.read(eventFormControllerProvider.notifier).delete(id); if (mounted) setState(() => _page = null); }
}

class MedicationHistoryScreen extends ConsumerStatefulWidget {
  const MedicationHistoryScreen({super.key});
  @override ConsumerState<MedicationHistoryScreen> createState() => _MedicationHistoryScreenState();
}
class _MedicationHistoryScreenState extends ConsumerState<MedicationHistoryScreen> {
  Future<TimelinePage>? _page;
  @override Widget build(BuildContext context) {
    final subjectState = ref.watch(subjectControllerProvider);
    final subject = subjectState.hasValue ? subjectState.requireValue.selectedSubjectId : null;
    final l10n = context.l10n;
    if (subject == null) return Scaffold(appBar: AppBar(title: Text(l10n.medicationsTitle)));
    _page ??= ref.read(timelineApiProvider).fetchTimeline(subjectId: subject, filters: const TimelineFilters(types: {MedicalEventType.medication, MedicalEventType.treatmentOutcome}, confirmed: true), limit: 100);
    return Scaffold(appBar: AppBar(title: Text(l10n.medicationsTitle)), body: FutureBuilder<TimelinePage>(future: _page, builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
      final items = snapshot.data!.results;
      if (items.isEmpty) return Center(child: Text(l10n.medicationsEmpty));
      return ListView.separated(padding: const EdgeInsets.all(AppSpacing.lg), itemCount: items.length, separatorBuilder: (_, _) => const Divider(), itemBuilder: (_, index) {
        final event = items[index];
        return ListTile(title: Text(event.title), subtitle: Text(event.eventDate), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => context.push('/events/${event.id}'));
      });
    }));
  }
}

class HistorySearchScreen extends ConsumerStatefulWidget {
  const HistorySearchScreen({super.key});
  @override ConsumerState<HistorySearchScreen> createState() => _HistorySearchScreenState();
}
class _HistorySearchScreenState extends ConsumerState<HistorySearchScreen> {
  final _query = TextEditingController(); Future<TimelinePage>? _events; Future<DocumentPage>? _documents;
  @override void dispose() { _query.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final subjectState = ref.watch(subjectControllerProvider);
    final subject = subjectState.hasValue ? subjectState.requireValue.selectedSubjectId : null;
    final l10n = context.l10n;
    return Scaffold(appBar: AppBar(title: Text(l10n.searchTitle)), body: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Column(children: [
      TextField(controller: _query, autofocus: true, decoration: InputDecoration(labelText: l10n.searchHint, prefixIcon: const Icon(Icons.search_rounded)), onSubmitted: (_) => _run(subject)),
      Expanded(child: _events == null ? const SizedBox.shrink() : ListView(children: [
        Text(l10n.searchEvents, style: Theme.of(context).textTheme.titleMedium),
        FutureBuilder<TimelinePage>(future: _events, builder: (_, snapshot) => snapshot.hasData ? Column(children: snapshot.data!.results.map((e) => ListTile(title: Text(e.title), subtitle: Text(e.eventDate), onTap: () => context.push('/events/${e.id}'))).toList()) : const LinearProgressIndicator()),
        const SizedBox(height: AppSpacing.lg), Text(l10n.searchDocuments, style: Theme.of(context).textTheme.titleMedium),
        FutureBuilder<DocumentPage>(future: _documents, builder: (_, snapshot) => snapshot.hasData ? Column(children: snapshot.data!.results.map((d) => ListTile(title: Text(d.title), onTap: () => context.push('/documents/${d.id}'))).toList()) : const LinearProgressIndicator()),
      ])),
    ])));
  }
  void _run(String? subject) { if (subject == null || _query.text.trim().isEmpty) return; setState(() { _events = ref.read(timelineApiProvider).fetchTimeline(subjectId: subject, filters: TimelineFilters(query: _query.text.trim(), confirmed: true)); _documents = ref.read(documentApiProvider).listDocuments(subjectId: subject, query: _query.text.trim()); }); }
}
