import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/storage/daily_challenge_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_observer.dart';
import '../../../../core/widgets/activity_heatmap.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/track_pill.dart';
import '../../../practice/presentation/pages/practice_page.dart';
import '../../../practice/presentation/pages/practice_session_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../progress/presentation/cubit/progress_cubit.dart';
import '../../../progress/presentation/cubit/progress_state.dart';
import '../../../progress/domain/entities/focus_area.dart';
import '../../../progress/presentation/pages/progress_page.dart';
import '../../../topics/presentation/pages/module_detail_page.dart';
import '../../../topics/presentation/pages/topic_detail_page.dart';
import '../../../../injection_container.dart' show sl;

/// The app's landing dashboard: streak, activity, today's challenge,
/// in-progress lesson, and weak topics.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProgressCubit>()..load(),
      child: _HomeLifecycle(
        child: Builder(builder: (context) => _buildHome(context)),
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    return BlocListener<ProgressCubit, ProgressState>(
      listenWhen: (previous, current) =>
          previous.status != ProgressStatus.failure &&
          current.status == ProgressStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.errorMessage ?? 'Failed to load. No internet connection?',
            ),
          ),
        );
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppTopBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<ProgressCubit>().load(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                          '$_greeting, Dev.',
                          style: AppTypography.headlineLgResponsive(context)
                              .copyWith(color: AppColors.onSurface),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        BlocBuilder<ProgressCubit, ProgressState>(
                          buildWhen: (previous, current) =>
                              previous.summary?.currentStreakDays !=
                                  current.summary?.currentStreakDays ||
                              previous.status != current.status,
                          builder: (context, state) {
                            final streak =
                                state.summary?.currentStreakDays ?? 0;
                            return Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department_rounded,
                                  size: 20.r,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Your streak: ',
                                  style: AppTypography.bodyLg.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '$streak',
                                  style: AppTypography.numeralLg.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  'days',
                                  style: AppTypography.bodyLg.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: AppSpacing.lg),
                        const _ActivityCard(),
                        SizedBox(height: AppSpacing.md),
                        BlocBuilder<ProgressCubit, ProgressState>(
                          buildWhen: (previous, current) =>
                              previous.tracks != current.tracks,
                          builder: (context, state) {
                            final tracks = state.tracks;
                            if (tracks.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            // The daily challenge rotates through the tracks
                            // one per calendar day, deterministic for the day.
                            final epochDays =
                                DateTime.now().millisecondsSinceEpoch ~/
                                Duration.millisecondsPerDay;
                            final track =
                                tracks[epochDays % tracks.length];
                            final trackName = track.name;
                            final trackId = track.id;
                            final doneToday =
                                sl<DailyChallengeStore>().isDoneToday();
                            return _DailyChallengeCard(
                              trackName: trackName,
                              trackId: trackId,
                              completed: doneToday,
                              onStart: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PracticeSessionPage(
                                    topicCode: trackId,
                                    challenge: true,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: AppSpacing.md),
                        BlocBuilder<ProgressCubit, ProgressState>(
                          buildWhen: (previous, current) =>
                              previous.summary?.globalReadinessScore !=
                                  current.summary?.globalReadinessScore ||
                              previous.focusAreas != current.focusAreas ||
                              previous.tracks != current.tracks,
                          builder: (context, state) {
                            final summary = state.summary;
                            final focus = state.focusAreas.isNotEmpty
                                ? state.focusAreas.first
                                : null;
                            final hasTracks = state.tracks.isNotEmpty;
                            final trackId =
                                focus?.trackId ??
                                (hasTracks ? state.tracks.first.id : null);
                            final hasProgress =
                                (summary?.globalReadinessScore ?? 0) > 0;
                            return _ContinueCard(
                              masteryScore: summary?.globalReadinessScore ?? 0,
                              title: hasProgress
                                  ? (focus?.title ?? 'Core Competencies')
                                  : 'Get Started',
                              subtitle: hasProgress
                                  ? (focus != null
                                        ? 'Ready for review'
                                        : 'Pick a course to continue')
                                  : 'Complete a course to see your mastery',
                              onResume: () {
                                if (trackId == null) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TopicDetailPage(trackId: trackId),
                                  ),
                                );
                              },
                              buttonLabel: hasProgress
                                  ? 'Resume Course'
                                  : 'Explore Courses',
                            );
                          },
                        ),
                        SizedBox(height: AppSpacing.md),
                        BlocBuilder<ProgressCubit, ProgressState>(
                          buildWhen: (previous, current) =>
                              previous.focusAreas != current.focusAreas,
                          builder: (context, state) =>
                              _WeakTopicsCard(focusAreas: state.focusAreas),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppBottomNavBar(
                currentIndex: 0,
                onTap: (i) {
                  if (i == 0) return;
                  if (i == 1) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PracticePage()),
                    );
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
      ),
    );
  }
}

/// Reloads the [ProgressCubit] whenever the home page becomes visible again
/// after a nested route (track/module/practice) pops back, so the Continue
/// card's mastery score and focus areas stay fresh.
class _HomeLifecycle extends StatefulWidget {
  const _HomeLifecycle({required this.child});

  final Widget child;

  @override
  State<_HomeLifecycle> createState() => _HomeLifecycleState();
}

class _HomeLifecycleState extends State<_HomeLifecycle> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    if (mounted) context.read<ProgressCubit>().load();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Shared card chrome used across the home screen's sections. Pass
/// [accentColor] for a colored left stripe (e.g. the daily challenge card).
/// The border+radius are drawn together on the same [BoxDecoration] so
/// Flutter strokes a proper curved border at the corners (clipping a
/// square-cornered border to a round rect instead just chops it at an
/// angle). The outer [ClipRRect] uses the same radius purely to keep the
/// accent stripe and content from ever drawing past the rounded edge.
class _HomeCard extends StatelessWidget {
  const _HomeCard({required this.child, this.accentColor});

  final Widget child;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.radiusLg,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Stack(
          children: [
            if (accentColor != null)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4.r,
                child: ColoredBox(color: accentColor!),
              ),
            Padding(padding: EdgeInsets.all(AppSpacing.md), child: child),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressCubit, ProgressState>(
      builder: (context, state) {
        final levels = state.summary?.activityLevels;
        final days = levels?.length ?? 35;
        return _HomeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Activity ($days Days)',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Readiness Levels',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      const ReadinessLegend(),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              ActivityHeatmap(
                days: days,
                columns: 7,
                levels: levels,
                streakDays: state.summary?.currentStreakDays ?? 0,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard({
    required this.trackName,
    required this.trackId,
    required this.completed,
    required this.onStart,
  });

  final String trackName;
  final String trackId;

  /// True once today's challenge has been finished, which locks the card.
  final bool completed;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return _HomeCard(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'DAILY CHALLENGE',
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              Icon(
                completed ? Icons.check_circle_rounded : Icons.hub_rounded,
                size: 20.r,
                color: AppColors.primary,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            completed
                ? 'Today\'s challenge complete'
                : 'Ready for today\'s practice?',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 2.r),
          Text(
            completed
                ? 'Come back tomorrow for a new one'
                : 'Keep your streak going',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              TrackPill(label: trackName, dotColor: AppColors.primary),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: completed ? null : onStart,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.r),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
              ),
              child: Text(completed ? 'Completed' : 'Start Challenge'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.onResume,
    required this.masteryScore,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
  });

  final VoidCallback onResume;
  final double masteryScore;
  final String title;
  final String subtitle;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    final percent = (masteryScore * 100).clamp(0, 100).round();
    return _HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONTINUE',
            style: AppTypography.labelMono.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.bodyLg.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.r),
          Text(
            subtitle,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              SizedBox(
                width: 48.r,
                height: 48.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 48.r,
                      height: 48.r,
                      child: CircularProgressIndicator(
                        value: masteryScore.clamp(0.0, 1.0),
                        strokeWidth: 4,
                        backgroundColor: AppColors.outlineVariant,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      '$percent',
                      style: AppTypography.numeralLg.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Mastery Score',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              OutlinedButton(
                onPressed: onResume,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: 10.r,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                ),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeakTopicsCard extends StatelessWidget {
  const _WeakTopicsCard({required this.focusAreas});

  final List<FocusArea> focusAreas;

  @override
  Widget build(BuildContext context) {
    return _HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEAK TOPICS',
            style: AppTypography.labelMono.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          if (focusAreas.isEmpty)
            Text(
              'Nothing flagged yet — keep practicing modules and weak '
              'spots will show up here.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            )
          else
            for (final area in focusAreas)
              Padding(
                padding: EdgeInsets.only(
                  bottom: area == focusAreas.last ? 0 : AppSpacing.sm,
                ),
                child: _WeakTopicRow(
                  title: area.title,
                  percent: area.percent,
                  critical: area.critical,
                  onTap: () {
                    final trackId = area.trackId;
                    final moduleId = area.moduleId;
                    if (trackId == null || moduleId == null) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ModuleDetailPage(
                          trackId: trackId,
                          moduleId: moduleId,
                        ),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}

class _WeakTopicRow extends StatelessWidget {
  const _WeakTopicRow({
    required this.title,
    required this.percent,
    required this.critical,
    required this.onTap,
  });

  final String title;
  final double percent;
  final bool critical;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusFull,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: AppRadius.radiusFull,
        ),
        child: Row(
          children: [
            Container(
              width: 8.r,
              height: 8.r,
              decoration: BoxDecoration(
                color: critical ? AppColors.error : AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              '${(percent * 100).round()}%',
              style: AppTypography.labelMono.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
