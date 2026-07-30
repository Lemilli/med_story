import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/l10n.dart';
import '../../../events/domain/medical_event.dart';
import '../../../events/presentation/event_type_l10n.dart';
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
                    const _TimelineHeader(),
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
  const _TimelineHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            context.l10n.appTitle,
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.patientInk,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
        ),
        IconButton(
          tooltip: context.l10n.navSettings,
          onPressed: () => context.push('/timeline/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
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
    final hasActiveFilters = filters.hasActiveFilters;
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
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (filters.query.isNotEmpty)
                  IconButton(
                    tooltip: l10n.timelineClearSearchAction,
                    onPressed: () {
                      searchController.clear();
                      onChanged(filters.copyWith(query: ''));
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                IconButton(
                  tooltip: l10n.timelineFiltersAction,
                  onPressed: () => _showFilters(context, filters),
                  icon: Badge(
                    isLabelVisible: hasActiveFilters,
                    smallSize: 8,
                    child: Icon(
                      hasActiveFilters ? Icons.tune : Icons.tune_rounded,
                    ),
                  ),
                ),
              ],
            ),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => onChanged(filters.copyWith(query: value)),
        ),
        if (hasActiveFilters) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.filter_alt_rounded,
                size: 18,
                color: AppColors.deepClinicalBlue,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  l10n.timelineFiltersActive,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.deepClinicalBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  searchController.clear();
                  onChanged(const TimelineFilters());
                },
                child: Text(l10n.timelineClearFiltersAction),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _showFilters(
    BuildContext context,
    TimelineFilters filters,
  ) async {
    final selected = await showModalBottomSheet<TimelineFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _TimelineFilterSheet(initial: filters),
    );
    if (selected != null && context.mounted) onChanged(selected);
  }
}

extension on TimelineFilters {
  bool get hasActiveFilters =>
      types.isNotEmpty ||
      from != null ||
      to != null ||
      tag.trim().isNotEmpty ||
      query.trim().isNotEmpty;
}

class _TimelineFilterSheet extends StatefulWidget {
  const _TimelineFilterSheet({required this.initial});

  final TimelineFilters initial;

  @override
  State<_TimelineFilterSheet> createState() => _TimelineFilterSheetState();
}

class _TimelineFilterSheetState extends State<_TimelineFilterSheet> {
  late final Set<MedicalEventType> _selected = {...widget.initial.types};
  late DateTime? _year = widget.initial.from;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedYear = _year == null ? null : DateFormat.y().format(_year!);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xs,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              sliver: SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Text(
                      l10n.timelineFiltersAction,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xs),
                  ),
                  SliverToBoxAdapter(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month_outlined),
                      title: Text(l10n.timelineYear),
                      subtitle: Text(selectedYear ?? l10n.timelineAllYears),
                      trailing: selectedYear == null
                          ? const Icon(Icons.chevron_right_rounded)
                          : IconButton(
                              tooltip: l10n.timelineAllYears,
                              onPressed: () => setState(() => _year = null),
                              icon: const Icon(Icons.close_rounded),
                            ),
                      onTap: _pickYear,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Divider(color: AppColors.clinicalLine),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final type = MedicalEventType.values[index];
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _selected.contains(type),
                        title: Text(type.label(l10n)),
                        controlAffinity: ListTileControlAffinity.trailing,
                        onChanged: (value) => setState(
                          () => value == true
                              ? _selected.add(type)
                              : _selected.remove(type),
                        ),
                      );
                    }, childCount: MedicalEventType.values.length),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xs),
                  ),
                  SliverToBoxAdapter(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(
                        context,
                        widget.initial.copyWith(
                          types: _selected,
                          from: _year == null ? null : DateTime(_year!.year),
                          to: _year == null
                              ? null
                              : DateTime(_year!.year, 12, 31),
                        ),
                      ),
                      child: Text(l10n.timelineApplyFiltersAction),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xs),
                  ),
                  SliverToBoxAdapter(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pop(context, const TimelineFilters()),
                      child: Text(l10n.timelineClearFiltersAction),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickYear() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _year ?? today,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: context.l10n.timelineYear,
    );
    if (selected != null && mounted) setState(() => _year = selected);
  }
}

class _TimelineEventRow extends ConsumerWidget {
  const _TimelineEventRow({required this.event});

  final MedicalEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
