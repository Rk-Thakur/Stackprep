import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_scope.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/activity_heatmap.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../onboarding/domain/entities/stack_track.dart';
import '../../../practice/presentation/pages/practice_page.dart';
import '../../../progress/domain/entities/focus_area.dart';
import '../../../progress/domain/entities/track_competency.dart';
import '../../../progress/presentation/cubit/progress_cubit.dart';
import '../../../progress/presentation/cubit/progress_state.dart';
import '../../../progress/presentation/pages/progress_page.dart';
import '../../../../injection_container.dart' show sl;

/// How many days the activity grid covers.
const int _activityDays = 84;

/// Learning Stats page, reached from the Profile tab.
///
/// Everything here is derived from data the progress tab already loads, so the
/// page cannot drift out of sync with the numbers shown elsewhere.
class LearningStatsPage extends StatelessWidget {
  const LearningStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // A pushed route is not a descendant of the profile tab's provider, so
      // this page resolves its own cubit the same way the progress tab does.
      create: (_) => sl<ProgressCubit>()..load(),
      child: Themed(
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                AppTopBar(
                  trailing: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: AppRadius.radiusSm,
                    child: Padding(
                      padding: EdgeInsets.all(4.r),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 22.r,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<ProgressCubit, ProgressState>(
                    builder: (context, state) {
                      return _body(context, state);
                    },
                  ),
                ),
                AppBottomNavBar(
                  currentIndex: 3,
                  onTap: (i) => _onNavTap(context, i),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 3) return;
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    if (index == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const PracticePage()));
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ProgressPage()));
  }

  Widget _body(BuildContext context, ProgressState state) {
    return switch (state.status) {
      ProgressStatus.initial || ProgressStatus.loading => const _StatusMessage(
        icon: Icons.query_stats_rounded,
        title: 'Crunching your numbers',
        detail: 'Reading your attempts, streaks, and module progress.',
      ),
      ProgressStatus.failure => _StatusMessage(
        icon: Icons.error_outline_rounded,
        title: 'Stats unavailable',
        detail: state.errorMessage ?? 'Something went wrong loading progress.',
        isError: true,
      ),
      ProgressStatus.ready => _ReadyBody(state: state),
    };
  }
}

class _ReadyBody extends StatelessWidget {
  const _ReadyBody({required this.state});

  final ProgressState state;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    final modulesCompleted = state.competencies.fold<int>(
      0,
      (total, c) => total + c.modulesCompleted,
    );
    final modulesTotal = state.competencies.fold<int>(
      0,
      (total, c) => total + c.modulesTotal,
    );
    final trackNames = {for (final track in state.tracks) track.id: track};

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
          Text(
            'Learning Stats',
            style: AppTypography.headlineLg.copyWith(
              color: AppColors.onSurface,
              fontSize: 26.sp,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Everything you have practised, measured from your own attempts.',
            style: AppTypography.bodyLg.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          _SectionLabel('AT_A_GLANCE'),
          SizedBox(height: AppSpacing.sm),
          _MetricGrid(
            metrics: [
              _Metric(
                label: 'CURRENT_STREAK',
                value: '${summary?.currentStreakDays ?? 0}',
                unit: summary != null && summary.currentStreakDays == 1
                    ? 'day'
                    : 'days',
              ),
              _Metric(
                label: 'SESSIONS',
                value: '${summary?.totalSessions ?? 0}',
              ),
              _Metric(
                label: 'MODULES_DONE',
                value: '$modulesCompleted',
                unit: modulesTotal > 0 ? 'of $modulesTotal' : null,
              ),
              _Metric(
                label: 'READINESS',
                value: _percent(summary?.globalReadinessScore ?? 0),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          _SectionLabel('ACTIVITY'),
          SizedBox(height: AppSpacing.sm),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last $_activityDays days',
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  _activityCaption(summary?.activityLevels ?? const []),
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                ActivityHeatmap(
                  days: _activityDays,
                  levels: summary?.activityLevels,
                  streakDays: summary?.currentStreakDays ?? 0,
                ),
              ],
            ),
          ),
          if (state.competencies.isNotEmpty) ...[
            SizedBox(height: AppSpacing.lg),
            _SectionLabel('TRACK_BREAKDOWN'),
            SizedBox(height: AppSpacing.sm),
            _Card(
              child: Column(
                children: [
                  for (var i = 0; i < state.competencies.length; i++) ...[
                    if (i > 0)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Container(
                          height: 1,
                          color: AppColors.outlineVariant,
                        ),
                      ),
                    _TrackRow(
                      competency: state.competencies[i],
                      track: trackNames[state.competencies[i].trackId],
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (state.focusAreas.isNotEmpty) ...[
            SizedBox(height: AppSpacing.lg),
            _SectionLabel('NEEDS_ATTENTION'),
            SizedBox(height: AppSpacing.sm),
            _Card(
              child: Column(
                children: [
                  for (var i = 0; i < state.focusAreas.length; i++) ...[
                    if (i > 0)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Container(
                          height: 1,
                          color: AppColors.outlineVariant,
                        ),
                      ),
                    _FocusRow(focus: state.focusAreas[i]),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.title,
    required this.detail,
    this.isError = false,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.primary;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40.r, color: color),
            SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<_Metric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Two columns on a phone, four across once there is room, so the cards
        // do not stretch into empty boxes on a desktop window.
        final columns = constraints.maxWidth > 520 ? 4 : 2;
        final spacing = AppSpacing.sm;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final metric in metrics) SizedBox(width: width, child: metric),
          ],
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.unit});

  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMono.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 9.sp,
            ),
          ),
          SizedBox(height: 6.r),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTypography.headlineLg.copyWith(
                    color: AppColors.primary,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (unit != null) ...[
                  SizedBox(width: 4.r),
                  Text(
                    unit!,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({required this.competency, this.track});

  final TrackCompetency competency;
  final StackTrack? track;

  @override
  Widget build(BuildContext context) {
    final hasCatalog = competency.modulesTotal > 0;
    final fraction = hasCatalog
        ? (competency.modulesCompleted / competency.modulesTotal).clamp(
            0.0,
            1.0,
          )
        : competency.score / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                track?.name ?? competency.trackId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            if (hasCatalog)
              Text(
                '${competency.modulesCompleted}/${competency.modulesTotal}',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              )
            else
              Text(
                '${competency.score}',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
        SizedBox(height: 8.r),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6.r,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(
              track?.color ?? AppColors.primary,
            ),
          ),
        ),
        SizedBox(height: 6.r),
        Text(
          hasCatalog
              ? 'Modules completed'
              : 'Competency score • ${competency.level}',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _FocusRow extends StatelessWidget {
  const _FocusRow({required this.focus});

  final FocusArea focus;

  @override
  Widget build(BuildContext context) {
    final (icon, tint) = switch (focus.trend) {
      TrendDirection.up => (Icons.trending_up_rounded, AppColors.primary),
      TrendDirection.flat => (
        Icons.trending_flat_rounded,
        AppColors.onSurfaceVariant,
      ),
      TrendDirection.levelUp => (Icons.trending_up_rounded, AppColors.tertiary),
    };

    return Row(
      children: [
        Icon(icon, size: 18.r, color: tint),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      focus.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (focus.critical)
                    Padding(
                      padding: EdgeInsets.only(left: AppSpacing.xs),
                      child: Text(
                        'CRITICAL',
                        style: AppTypography.labelMono.copyWith(
                          color: AppColors.error,
                          fontSize: 9.sp,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 2.r),
              Text(
                focus.trendLabel,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          _percent(focus.percent),
          style: AppTypography.labelMono.copyWith(color: AppColors.onSurface),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.labelMono.copyWith(color: AppColors.primary),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: child,
    );
  }
}

String _percent(double fraction) => '${(fraction * 100).round()}%';

/// Describes the activity grid in words, so the numbers are not the only
/// signal that the user has been showing up.
String _activityCaption(List<int> levels) {
  if (levels.isEmpty) return 'No activity recorded yet.';
  final activeDays = levels.where((level) => level > 0).length;
  if (activeDays == 0) return 'No activity recorded yet.';
  return 'Active on $activeDays of the last ${levels.length} days.';
}
