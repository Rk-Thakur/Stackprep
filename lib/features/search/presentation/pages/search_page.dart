import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../injection_container.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../progress/presentation/pages/progress_page.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';

class _FilterOption {
  const _FilterOption(this.label, {this.icon, this.dotColor});

  final String label;
  final IconData? icon;
  final Color? dotColor;
}

const List<_FilterOption> _kFilters = [
  _FilterOption('All Types', icon: Icons.tune_rounded),
  _FilterOption('Kotlin', dotColor: Color(0xFF8B5CF6)),
  _FilterOption('Swift', dotColor: Color(0xFFF14C33)),
  _FilterOption('Architecture', icon: Icons.architecture_rounded),
  _FilterOption('Errors', icon: Icons.bug_report_rounded),
];

const List<String> _kRecentSearches = [
  'iOS Memory Leaks Instruments',
  'Dagger Hilt setup testing',
  'Coroutine Exception Handling',
];

class _TrendingItem {
  const _TrendingItem({
    required this.title,
    required this.description,
    required this.tags,
  });

  final String title;
  final String description;
  final String tags;
}

const List<_TrendingItem> _kTrendingItems = [
  _TrendingItem(
    title: 'Compose Navigation Transitions',
    description:
        'Implementing Shared Element transitions in Jetpack Compose '
        'navigation graphs.',
    tags: 'UI / UX',
  ),
  _TrendingItem(
    title: 'SwiftData Migration Patterns',
    description:
        'Best practices for migrating complex Core Data models to '
        'SwiftData schemas.',
    tags: 'DATA / MIGRATION',
  ),
  _TrendingItem(
    title: 'Structured Concurrency Pitfalls',
    description:
        'Common mistakes with CoroutineScope lifecycles and cancellation '
        'propagation.',
    tags: 'CONCURRENCY / KOTLIN',
  ),
];

/// Search & Discovery page, reached from the Practice tab's search bar.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchCubit>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      context.read<SearchCubit>().queryChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.md,
                  AppSpacing.margin,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search & Discovery',
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 24.sp,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    _SearchField(controller: _controller, focusNode: _focusNode),
                    SizedBox(height: AppSpacing.md),
                    BlocBuilder<SearchCubit, SearchState>(
                      buildWhen: (previous, current) =>
                          previous.selectedFilter != current.selectedFilter,
                      builder: (context, state) {
                        return Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            for (final filter in _kFilters)
                              _FilterChip(
                                option: filter,
                                selected: state.selectedFilter == filter.label,
                                onTap: () => context
                                    .read<SearchCubit>()
                                    .filterSelected(filter.label),
                              ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'RECENT',
                            style: AppTypography.labelMono.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _comingSoon('Clear recent'),
                          child: Text(
                            'Clear',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Container(height: 1, color: AppColors.outlineVariant),
                    for (final query in _kRecentSearches)
                      _RecentRow(
                        label: query,
                        onTap: () => _comingSoon(query),
                      ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'TRENDING',
                      style: AppTypography.labelMono.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Container(height: 1, color: AppColors.outlineVariant),
                    SizedBox(height: AppSpacing.md),
                    for (var i = 0; i < _kTrendingItems.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == _kTrendingItems.length - 1
                              ? 0
                              : AppSpacing.md,
                        ),
                        child: _TrendingCard(
                          item: _kTrendingItems[i],
                          onTap: () => _comingSoon(_kTrendingItems[i].title),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            AppBottomNavBar(
              currentIndex: 1,
              onTap: (i) {
                if (i == 1) return;
                if (i == 0) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  return;
                }
                if (i == 2) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProgressPage()),
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.margin,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Icon(
                Icons.terminal_rounded,
                size: 18.r,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'StackPrep',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.primary,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20.r,
            color: AppColors.onSurfaceVariant,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search patterns, errors, architecture...',
                hintStyle: AppTypography.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14.r),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 3.r),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.keyboard_command_key_rounded,
                  size: 13.r,
                  color: AppColors.onSurfaceVariant,
                ),
                SizedBox(width: 2.r),
                Text(
                  'K',
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _FilterOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusFull,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 8.r,
        ),
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusFull,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (option.icon != null)
              Icon(option.icon, size: 14.r, color: color)
            else if (option.dotColor != null)
              Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                  color: option.dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            SizedBox(width: AppSpacing.xs),
            Text(
              option.label,
              style: AppTypography.labelMono.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(
              Icons.history_rounded,
              size: 20.r,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.item, required this.onTap});

  final _TrendingItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusLg,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.trending_up_rounded,
              size: 20.r,
              color: AppColors.primary,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.r),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    item.tags,
                    style: AppTypography.labelMono.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11.sp,
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
}
