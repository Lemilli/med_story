import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/l10n.dart';
import '../../../../core/storage/local_database.dart' as db;
import '../../domain/medical_event.dart';
import '../controllers/event_controllers.dart';
import '../event_type_l10n.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(eventDetailProvider(eventId));
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.eventDetailTitle)),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (event) => _EventDetailBody(event: event),
      ),
    );
  }
}

class _EventDetailBody extends ConsumerWidget {
  const _EventDetailBody({required this.event});

  final MedicalEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final date = DateTime.tryParse(event.eventDate);
    final formattedDate = date == null
        ? event.eventDate
        : DateFormat.yMMMMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(date);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          Text(
            event.title,
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.patientInk,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${event.eventType.label(l10n)} • $formattedDate',
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryInk,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_showOriginalSource(event))
            _Panel(
              child: _DetailSection(
                title: event.source == EventSource.aiVoice
                    ? l10n.eventOriginalTranscriptTitle
                    : l10n.eventOriginalSourceTitle,
                child: Text(
                  event.source == EventSource.aiVoice
                      ? event.sourceText ?? l10n.eventDetailsEmptyDescription
                      : event.description,
                  style: textTheme.bodyLarge?.copyWith(height: 1.45),
                ),
              ),
            ),
          if (_showAiAnalysis(event)) ...[
            if (_showOriginalSource(event))
              const SizedBox(height: AppSpacing.md),
            _Panel(
              child: _DetailSection(
                title: l10n.eventAiAnalysisTitle,
                child: Text(
                  event.description.isEmpty
                      ? l10n.eventDetailsEmptyDescription
                      : event.description,
                  style: textTheme.bodyLarge?.copyWith(height: 1.45),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (event.sourceDocumentId != null && event.sourceAssetCount > 0) ...[
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _OriginalSourceScreen(event: event),
                ),
              ),
              icon: const Icon(Icons.collections_outlined),
              label: Text(
                event.sourceAssetCount > 1
                    ? l10n.eventViewOriginalPagesAction(event.sourceAssetCount)
                    : l10n.eventViewOriginalAction,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/events/${event.id}/edit'),
                  icon: const Icon(Icons.edit_rounded),
                  label: Text(l10n.eventEditAction),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, ref),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.eventDeleteAction),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.eventDeleteConfirmTitle),
        content: Text(l10n.eventDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.eventCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.eventDeleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(eventFormControllerProvider.notifier).delete(event.id);
    if (context.mounted) {
      context.go('/timeline');
    }
  }
}

bool _showOriginalSource(MedicalEvent event) =>
    event.source == EventSource.userManual ||
    event.source == EventSource.aiVoice;

bool _showAiAnalysis(MedicalEvent event) =>
    event.source != EventSource.userManual;

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            color: AppColors.patientInk,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _OriginalSourceScreen extends ConsumerStatefulWidget {
  const _OriginalSourceScreen({required this.event});

  final MedicalEvent event;

  @override
  ConsumerState<_OriginalSourceScreen> createState() =>
      _OriginalSourceScreenState();
}

class _OriginalSourceScreenState extends ConsumerState<_OriginalSourceScreen> {
  final _pageController = PageController();
  late final Future<List<db.DocumentLocalAsset>> _assetsFuture;
  var _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final documentId = widget.event.sourceDocumentId;
    _assetsFuture = documentId == null
        ? Future.value(const [])
        : ref.read(db.localDatabaseProvider).getDocumentLocalAssets(documentId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final documentId = widget.event.sourceDocumentId;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.eventViewOriginalAction)),
      body: documentId == null
          ? Center(
              child: Text(
                widget.event.sourceText ?? l10n.eventOriginalUnavailable,
              ),
            )
          : FutureBuilder<List<db.DocumentLocalAsset>>(
              future: _assetsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final assets = snapshot.data ?? const [];
                if (assets.isEmpty) {
                  if (widget.event.sourceText != null) {
                    return ListView(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      children: [
                        Text(
                          widget.event.sourceText!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(height: 1.5),
                        ),
                      ],
                    );
                  }
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Text(
                        l10n.eventOriginalUnavailable,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final hasMultiplePages = assets.length > 1;
                final currentPage = _currentPage.clamp(0, assets.length - 1);
                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: assets.length,
                            onPageChanged: (page) =>
                                setState(() => _currentPage = page),
                            itemBuilder: (context, index) {
                              final asset = assets[index];
                              if (asset.mimeType.startsWith('image/')) {
                                return InteractiveViewer(
                                  key: ValueKey(asset.localPath),
                                  minScale: 1,
                                  maxScale: 4,
                                  boundaryMargin: const EdgeInsets.all(48),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.lg,
                                      ),
                                      child: Image.file(
                                        key: ValueKey(asset.localPath),
                                        File(asset.localPath),
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) => Center(
                                          child: Text(
                                            l10n.eventOriginalUnavailable,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Center(
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.insert_drive_file_outlined,
                                  ),
                                  title: Text(asset.fileName),
                                  subtitle: Text(asset.mimeType),
                                ),
                              );
                            },
                          ),
                          if (hasMultiplePages) ...[
                            Positioned(
                              top: AppSpacing.md,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: _PageIndicator(
                                  label: l10n.eventOriginalPageIndicator(
                                    currentPage + 1,
                                    assets.length,
                                  ),
                                ),
                              ),
                            ),
                            if (currentPage > 0)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _PageNavigationButton(
                                  icon: Icons.chevron_left_rounded,
                                  tooltip: l10n.eventPreviousOriginalPage,
                                  onPressed: () => _goToPage(currentPage - 1),
                                ),
                              ),
                            if (currentPage < assets.length - 1)
                              Align(
                                alignment: Alignment.centerRight,
                                child: _PageNavigationButton(
                                  icon: Icons.chevron_right_rounded,
                                  tooltip: l10n.eventNextOriginalPage,
                                  onPressed: () => _goToPage(currentPage + 1),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.eventOriginalLocalOnly,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.secondaryInk),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton.icon(
                            onPressed: () => SharePlus.instance.share(
                              ShareParams(
                                files: [
                                  for (final asset in assets)
                                    XFile(asset.localPath),
                                ],
                                fileNameOverrides: [
                                  for (final asset in assets) asset.fileName,
                                ],
                              ),
                            ),
                            icon: const Icon(Icons.ios_share_rounded),
                            label: Text(l10n.eventOriginalShareAction),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  void _goToPage(int page) {
    if (!_pageController.hasClients || page == _currentPage) {
      return;
    }

    // PageView's callback keeps the indicator and available arrows in sync
    // for both button taps and swipe navigation.
    _pageController.jumpToPage(page);
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: label,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.quietSurface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.patientInk,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageNavigationButton extends StatelessWidget {
  const _PageNavigationButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: Icon(icon),
        tooltip: tooltip,
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: AppColors.quietSurface,
          foregroundColor: AppColors.patientInk,
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.quietSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.clinicalLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}
