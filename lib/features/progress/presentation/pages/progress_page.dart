import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/activity_heatmap.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../injection_container.dart';
import '../../../onboarding/domain/entities/stack_track.dart';
import '../../../practice/presentation/pages/practice_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domain/entities/focus_area.dart';
import '../../domain/entities/readiness_summary.dart';
import '../../domain/entities/track_competency.dart';
import '../cubit/progress_cubit.dart';
import '../cubit/progress_state.dart';

IconData _trendIcon(TrendDirection trend) => switch (trend) {
  TrendDirection.up => Icons.trending_up_rounded,
  TrendDirection.flat => Icons.remove_rounded,
  TrendDirection.levelUp => Icons.auto_awesome_rounded,
};

/// Progress tab: activity commitment, an aggregate readiness score, a
/// filterable per-track competency breakdown, and weak-area telemetry.
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ProgressCubit>()..load(),
      child: const _ProgressView(),
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView();

  void _comingSoon(BuildContext context, String feature) {
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
            AppTopBar(),
            Expanded(
              child: BlocBuilder<ProgressCubit, ProgressState>(
                builder: (context, state) {
                  if (state.status == ProgressStatus.loading &&
                      state.summary == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == ProgressStatus.failure &&
                      state.summary == null) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Something went wrong.',
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.margin,
                      AppSpacing.md,
                      AppSpacing.margin,
                      AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.summary != null)
                          _CommitmentEngineCard(summary: state.summary!),
                        SizedBox(height: AppSpacing.md),
                        if (state.summary != null)
                          _SystemMasteryCard(summary: state.summary!),
                        SizedBox(height: AppSpacing.lg),
                        const _SectionTitle('Core Competencies'),
                        SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            _TrackFilterChip(
                              label: 'All',
                              selected: state.selectedTrackId == null,
                              onTap: () =>
                                  context.read<ProgressCubit>().selectTrack(null),
                            ),
                            for (final track in state.tracks)
                              _TrackFilterChip(
                                label: track.name,
                                color: track.color,
                                selected: state.selectedTrackId == track.id,
                                onTap: () => context
                                    .read<ProgressCubit>()
                                    .selectTrack(track.id),
                              ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.md),
                        for (var i = 0;
                            i < state.filteredCompetencies.length;
                            i++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  i == state.filteredCompetencies.length - 1
                                  ? 0
                                  : AppSpacing.md,
                            ),
                            child: Builder(
                              builder: (context) {
                                final competency =
                                    state.filteredCompetencies[i];
                                final track = state.tracks.firstWhere(
                                  (t) => t.id == competency.trackId,
                                );
                                return _CompetencyCard(
                                  track: track,
                                  competency: competency,
                                );
                              },
                            ),
                          ),
                        SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            const Expanded(child: _SectionTitle('Focus Areas')),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _comingSoon(context, 'Add focus area'),
                              icon: Icon(Icons.add_rounded, size: 16.r),
                              label: const Text('Focus Area'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.outlineVariant,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 8.r,
                                ),
                                textStyle: AppTypography.labelMono,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.radiusSm,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.md),
                        for (var i = 0; i < state.focusAreas.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: i == state.focusAreas.length - 1
                                  ? 0
                                  : AppSpacing.sm,
                            ),
                            child: _FocusAreaCard(
                              area: state.focusAreas[i],
                              onTap: () => _comingSoon(
                                context,
                                state.focusAreas[i].title,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            AppBottomNavBar(
              currentIndex: 2,
              onTap: (i) {
                if (i == 2) return;
                if (i == 0) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  return;
                }
                if (i == 1) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PracticePage()),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.headlineMd.copyWith(
        color: AppColors.onSurface,
        fontSize: 20.sp,
      ),
    );
  }
}

/// Shared card chrome matching the app's other screens.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: child,
    );
  }
}

class _CommitmentEngineCard extends StatelessWidget {
  const _CommitmentEngineCard({required this.summary});

  final ReadinessSummary summary;

  @override
  Widget build(BuildContext context) {
    return _ProgressCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commitment Engine',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
              fontSize: 21.sp,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '365 Days of Mastery',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                'LESS',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10.sp,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              for (final color in kReadinessScale)
                Padding(
                  padding: EdgeInsets.only(right: 3.r),
                  child: Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: AppRadius.radiusSm,
                    ),
                  ),
                ),
              Text(
                'MORE',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          const ActivityHeatmap(days: 91, columns: 13, seed: 42),
          SizedBox(height: AppSpacing.md),
          Container(height: 1, color: AppColors.outlineVariant),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  label: 'CURRENT STREAK',
                  value: '${summary.currentStreakDays}',
                  suffix: ' DAYS',
                ),
              ),
              Expanded(
                child: _StatColumn(
                  label: 'TOTAL SESSIONS',
                  value: '${summary.totalSessions}',
                ),
              ),
              Expanded(
                child: _StatColumn(
                  label: 'READINESS SCORE',
                  value: '${(summary.readinessScore * 100).round()}',
                  suffix: '%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value, this.suffix});

  final String label;
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMono.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 10.sp,
          ),
        ),
        SizedBox(height: 4.r),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTypography.numeralLg.copyWith(
                  color: AppColors.primary,
                  fontSize: 26.sp,
                ),
              ),
              if (suffix != null)
                TextSpan(
                  text: suffix,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SystemMasteryCard extends StatelessWidget {
  const _SystemMasteryCard({required this.summary});

  final ReadinessSummary summary;

  @override
  Widget build(BuildContext context) {
    return _ProgressCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SYSTEM MASTERY',
            style: AppTypography.labelMono.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Aggregate assessment of technical readiness across all '
            'registered engineering tracks.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${(summary.globalReadinessScore * 100).round()}%',
                style: AppTypography.headlineLg.copyWith(
                  color: AppColors.primary,
                  fontSize: 40.sp,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'GLOBAL_READINESS_SCORE',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.radiusFull,
            child: LinearProgressIndicator(
              value: summary.globalReadinessScore,
              minHeight: 8.r,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(
                'SYS.INIT',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10.sp,
                ),
              ),
              const Spacer(),
              Text(
                'TARGET: ${(summary.targetScore * 100).round()}%',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrackFilterChip extends StatelessWidget {
  const _TrackFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    final textColor = selected ? activeColor : AppColors.onSurfaceVariant;
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
            color: selected ? activeColor : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMono.copyWith(color: textColor),
        ),
      ),
    );
  }
}

class _CompetencyCard extends StatelessWidget {
  const _CompetencyCard({required this.track, required this.competency});

  final StackTrack track;
  final TrackCompetency competency;

  @override
  Widget build(BuildContext context) {
    return _ProgressCard(
      child: Column(
        children: [
          SizedBox(
            width: 96.r,
            height: 96.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 96.r,
                  height: 96.r,
                  child: CircularProgressIndicator(
                    value: competency.score / 100,
                    strokeWidth: 6,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation(track.color),
                  ),
                ),
                Text(
                  '${competency.score}',
                  style: AppTypography.numeralLg.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 28.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            track.name,
            style: AppTypography.bodyLg.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 2.r),
          Text(
            competency.level,
            style: AppTypography.labelMono.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusAreaCard extends StatelessWidget {
  const _FocusAreaCard({required this.area, required this.onTap});

  final FocusArea area;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  area.title,
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (area.critical) ...[
                  SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.r,
                      vertical: 2.r,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer.withValues(alpha: 0.3),
                      borderRadius: AppRadius.radiusSm,
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'CRITICAL',
                      style: AppTypography.labelMono.copyWith(
                        color: AppColors.error,
                        fontSize: 9.sp,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  '${(area.percent * 100).round()}%',
                  style: AppTypography.numeralLg.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            _SegmentedBar(value: area.percent),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  _trendIcon(area.trend),
                  size: 14.r,
                  color: AppColors.onSurfaceVariant,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  area.trendLabel,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12.sp,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18.r,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A blocky "telemetry" progress bar — a handful of thick segments rather
/// than a smooth fill, echoing the app's terminal/mono aesthetic.
class _SegmentedBar extends StatelessWidget {
  const _SegmentedBar({required this.value});

  final double value;

  static const int _segments = 5;

  @override
  Widget build(BuildContext context) {
    final filled = (value.clamp(0, 1) * _segments).round();
    return Row(
      children: List.generate(_segments, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == _segments - 1 ? 0 : 4.r),
            child: Container(
              height: 8.r,
              decoration: BoxDecoration(
                color: i < filled
                    ? AppColors.primary
                    : AppColors.surfaceContainerHigh,
                borderRadius: AppRadius.radiusSm,
              ),
            ),
          ),
        );
      }),
    );
  }
}
