import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/l10n.dart';
import '../../../events/domain/medical_event.dart';
import '../../../events/presentation/event_type_l10n.dart';
import '../../../subjects/presentation/controllers/subject_controller.dart';
import '../../domain/timeline_filters.dart';
import '../controllers/timeline_controller.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final timelineState = ref.watch(timelineControllerProvider);
    final events = ref.watch(timelineEventsProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(timelineControllerProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TimelineHeader(onAdd: () => context.push('/events/new')),
                    const SizedBox(height: AppSpacing.lg),
                    const _SubjectSwitcher(),
                    const SizedBox(height: AppSpacing.lg),
                    timelineState.maybeWhen(
                      data: (state) => _TimelineFilters(
                        state: state,
                        searchController: _searchController,
                        onChanged: (filters) => ref
                            .read(timelineControllerProvider.notifier)
                            .updateFilters(filters),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                    timelineState.maybeWhen(
                      data: (state) {
                        if (state.errorMessage == null) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: _InlineNotice(
                            message: l10n.timelineOfflineNotice,
                          ),
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            events.when(
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyTimeline(
                  title: l10n.timelineNoSubjectTitle,
                  message: error.toString(),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyTimeline(
                      title: l10n.timelineEmptyTitle,
                      message: l10n.timelineEmptyMessage,
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xxxl,
                  ),
                  sliver: SliverList.separated(
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return timelineState.maybeWhen(
                          data: (state) => _LoadMoreButton(state: state),
                          orElse: () => const SizedBox.shrink(),
                        );
                      }
                      return _TimelineEventRow(event: items[index]);
                    },
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemCount: timelineState.maybeWhen(
                      data: (state) =>
                          state.hasMore ? items.length + 1 : items.length,
                      orElse: () => items.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineHeader extends StatelessWidget {
  const _TimelineHeader({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.timelineHeadline,
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.patientInk,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.timelineSubtitle,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.secondaryInk,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        IconButton.filled(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          color: AppColors.clinicalWhite,
        ),
      ],
    );
  }
}

class _SubjectSwitcher extends ConsumerWidget {
  const _SubjectSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final subjects = ref.watch(subjectControllerProvider);

    return subjects.when(
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (error, _) => _InlineNotice(message: error.toString()),
      data: (state) {
        if (state.subjects.isEmpty) {
          return _InlineNotice(message: l10n.timelineNoSubjectMessage);
        }
        return DropdownButtonFormField<String>(
          initialValue: state.selectedSubjectId,
          decoration: InputDecoration(labelText: l10n.subjectSwitcherLabel),
          items: state.subjects.map((subject) {
            final suffix = subject.isDefault
                ? ' • ${l10n.subjectDefaultLabel}'
                : '';
            return DropdownMenuItem(
              value: subject.id,
              child: Text('${subject.displayName}$suffix'),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }
            ref.read(subjectControllerProvider.notifier).selectSubject(value);
          },
        );
      },
    );
  }
}

class _TimelineFilters extends StatelessWidget {
  const _TimelineFilters({
    required this.state,
    required this.searchController,
    required this.onChanged,
  });

  final TimelineState state;
  final TextEditingController searchController;
  final ValueChanged<TimelineFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filters = state.filters;
    if (searchController.text != filters.query) {
      searchController.text = filters.query;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            labelText: l10n.timelineSearchLabel,
            prefixIcon: const Icon(Icons.search_rounded),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => onChanged(filters.copyWith(query: value)),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: Text(l10n.timelineAllTypes),
                selected: filters.types.isEmpty,
                onSelected: (_) => onChanged(
                  filters.copyWith(types: const <MedicalEventType>{}),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              for (final type in MedicalEventType.values) ...[
                FilterChip(
                  label: Text(type.label(l10n)),
                  selected: filters.types.contains(type),
                  onSelected: (selected) {
                    final next = {...filters.types};
                    selected ? next.add(type) : next.remove(type);
                    onChanged(filters.copyWith(types: next));
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineEventRow extends StatelessWidget {
  const _TimelineEventRow({required this.event});

  final MedicalEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final date = DateTime.tryParse(event.eventDate);
    final formattedDate = date == null
        ? event.eventDate
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(date);

    return Material(
      color: AppColors.clinicalWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.clinicalLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/events/${event.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    formattedDate,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.deepClinicalBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (!event.isConfirmed)
                    _StatusBadge(label: l10n.eventUnconfirmedBadge),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                event.title,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.patientInk,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                event.eventType.label(l10n),
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryInk,
                  height: 1.3,
                ),
              ),
              if (event.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: event.tags
                      .map((tag) => Chip(label: Text(tag)))
                      .toList(growable: false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.quietSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.clinicalLine),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(label),
      ),
    );
  }
}

class _LoadMoreButton extends ConsumerWidget {
  const _LoadMoreButton({required this.state});

  final TimelineState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: OutlinedButton(
        onPressed: state.isLoadingMore
            ? null
            : () => ref.read(timelineControllerProvider.notifier).loadMore(),
        child: state.isLoadingMore
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(l10n.timelineLoadMore),
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history_rounded,
            color: AppColors.deepClinicalBlue,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.patientInk,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.secondaryInk,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message});

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
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.deepClinicalBlue,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
