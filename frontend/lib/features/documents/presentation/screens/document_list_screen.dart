import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/l10n.dart';
import '../../../subjects/presentation/controllers/subject_controller.dart';
import '../../data/document_repository.dart';
import '../../data/document_api.dart';
import '../../domain/medical_document.dart';

class DocumentListScreen extends ConsumerStatefulWidget {
  const DocumentListScreen({super.key});

  @override
  ConsumerState<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends ConsumerState<DocumentListScreen> {
  final _search = TextEditingController();
  Future<DocumentPage>? _page;
  DocumentStatus? _status;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectState = ref.watch(subjectControllerProvider);
    final subjectId = subjectState.hasValue
        ? subjectState.value?.selectedSubjectId
        : null;
    _page ??= _load(subjectId);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.documentDetailTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        labelText: l10n.timelineSearchLabel,
                        prefixIcon: const Icon(Icons.search_rounded),
                      ),
                      onSubmitted: (_) => _reload(subjectId),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.filter_list_rounded),
                    tooltip: l10n.timelineFiltersAction,
                    onPressed: () => _chooseStatus(subjectId),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<DocumentPage>(
                future: _page,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }
                  final documents =
                      snapshot.data?.results ?? const <MedicalDocument>[];
                  if (documents.isEmpty) {
                    return Center(child: Text(l10n.documentSelectionEmpty));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.xxxl,
                    ),
                    itemCount: documents.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, index) {
                      final document = documents[index];
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLowest,
                        leading: Icon(
                          document.docType == DocumentType.audio
                              ? Icons.mic_none_rounded
                              : Icons.description_outlined,
                        ),
                        title: Text(document.title),
                        subtitle: Text(
                          '${document.status.apiName} · ${document.eventCount}',
                        ),
                        onTap: () => context.push('/documents/${document.id}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<DocumentPage> _load(String? subjectId) => ref
      .read(documentRepositoryProvider)
      .listDocuments(
        subjectId: subjectId,
        status: _status,
        query: _search.text,
      );
  void _reload(String? subjectId) => setState(() => _page = _load(subjectId));
  Future<void> _chooseStatus(String? subjectId) async {
    final value = await showModalBottomSheet<DocumentStatus?>(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text(context.l10n.timelineAllTypes),
            onTap: () => Navigator.pop(context),
          ),
          for (final status in DocumentStatus.values)
            ListTile(
              title: Text(status.apiName),
              onTap: () => Navigator.pop(context, status),
            ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() {
      _status = value;
      _page = _load(subjectId);
    });
  }
}
