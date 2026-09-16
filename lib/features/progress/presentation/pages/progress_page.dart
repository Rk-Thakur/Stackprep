import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/route_observer.dart';
import '../../../../core/widgets/activity_heatmap.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/track_icon.dart';
import '../../../../injection_container.dart';
import '../../../onboarding/domain/entities/stack_track.dart';
import '../../../practice/presentation/pages/practice_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../topics/presentation/pages/module_detail_page.dart';
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

/// Resolves a competency's track against the catalog, tolerating unknown or
/// differently-cased ids (e.g. "KOTLIN" vs "kotlin") that can come from
/// locally-cached progress data.
StackTrack _trackFor(String trackId, List<StackTrack> tracks) {
  return tracks.firstWhere(
    (t) => t.id.toLowerCase() == trackId.toLowerCase(),
    orElse: () => StackTrack(
      id: trackId,
      name: trackId.toUpperCase(),
      category: 'TRACK',
      shape: TrackShapeType.roundedSquare,
      color: AppColors.primary,
    ),
  );
}

/// Progress tab: activity commitment, an aggregate readiness score, a
/// filterable per-track competency breakdown, and weak-area telemetry.
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProgressCubit>()..load(),
      child: const _ProgressLifecycle(child: _ProgressView()),
    );
  }
}

/// Reloads the [ProgressCubit] whenever the progress page becomes visible
/// again after a nested route (module/topic) pops back.
class _ProgressLifecycle extends StatefulWidget {
  const _ProgressLifecycle({required this.child});

  final Widget child;

  @override
  State<_ProgressLifecycle> createState() => _ProgressLifecycleState();
}

class _ProgressLifecycleState extends State<_ProgressLifecycle>
    with RouteAware {
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
    // Reload progress (competencies, focus areas, streak) after returning
    // from a nested module/topic so the indicators stay fresh.
    if (mounted) context.read<ProgressCubit>().load();
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
                    return const _ProgressSkeleton();
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
                                final track = _trackFor(
                                  competency.trackId,
                                  state.tracks,
                                );
                                return _RevealOnScroll(
                                  key: ValueKey(
                                    '${state.selectedTrackId ?? 'all'}-$i',
                                  ),
                                  builder: (context, visible) =>
                                      _CompetencyCard(
                                        track: track,
                                        competency: competency,
                                        animate: visible,
                                      ),
                                );
                              },
                            ),
                          ),
                        SizedBox(height: AppSpacing.lg),
                        const _SectionTitle('Focus Areas'),
                        SizedBox(height: 2.r),
                        Text(
                          'Auto-detected from your lowest-scoring modules.',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md),
                        if (state.focusAreas.isEmpty)
                          Text(
                            'Nothing flagged yet — keep practicing modules '
                            'and weak spots will show up here.',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          )
                        else
                          for (var i = 0; i < state.focusAreas.length; i++)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: i == state.focusAreas.length - 1
                                    ? 0
                                    : AppSpacing.sm,
                              ),
                              child: _FocusAreaCard(
                                area: state.focusAreas[i],
                                onTap: () {
                                  final area = state.focusAreas[i];
                                  final trackId = area.trackId;
                                  final moduleId = area.moduleId;
                                  if (trackId == null || moduleId == null) {
                                    _comingSoon(context, area.title);
                                    return;
                                  }
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

/// Shimmering placeholder matching the progress tab's overall layout while
/// the first `progress/overview` fetch is still in flight.
class _ProgressSkeleton extends StatelessWidget {
  const _ProgressSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.margin,
          AppSpacing.md,
          AppSpacing.margin,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProgressCard(
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
                  SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    height: 70.r,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: AppRadius.radiusSm,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Container(height: 1, color: AppColors.outlineVariant),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i == 2 ? 0 : 8.r),
                            child: Container(
                              height: 36.r,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: AppRadius.radiusSm,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),
            _ProgressCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SYSTEM MASTERY',
                    style: AppTypography.labelMono.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Container(
                    width: 120.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: AppRadius.radiusSm,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    height: 8.r,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: AppRadius.radiusFull,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            const _SectionTitle('Core Competencies'),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: EdgeInsets.only(right: AppSpacing.xs),
                    child: Container(
                      width: 72.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.radiusFull,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            for (var i = 0; i < 2; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == 1 ? 0 : AppSpacing.md,
                ),
                child: _ProgressCard(
                  child: Column(
                    children: [
                      Container(
                        width: 96.r,
                        height: 96.r,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Track name',
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                        ),
                      ),
                    ],
                  ),
                ),
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
          ActivityHeatmap(
            days: summary.activityLevels.isNotEmpty
                ? summary.activityLevels.length
                : 91,
            columns: 13,
            levels: summary.activityLevels,
          ),
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

class _RevealOnScroll extends StatefulWidget {
  const _RevealOnScroll({super.key, required this.builder});

  final Widget Function(BuildContext context, bool visible) builder;

  @override
  State<_RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<_RevealOnScroll>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  ScrollPosition? _position;

  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attach());
  }

  void _attach() {
    if (!mounted) return;
    final position = Scrollable.of(context).position;
    _position = position;
    position.addListener(_checkVisibility);
    _checkVisibility();
  }

  Future<void> _checkVisibility() async {
    if (!mounted || _visible) return;
    // Wait a frame so layout is settled before measuring.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final scrollable = Scrollable.of(context);
    final geometry = scrollable.context.findRenderObject() as RenderBox?;
    if (geometry == null || !geometry.hasSize) return;
    final top = renderObject.localToGlobal(
      Offset.zero,
      ancestor: geometry,
    ).dy;
    final bottom = top + renderObject.size.height;
    if (top < geometry.size.height && bottom > 0) {
      setState(() {
        _visible = true;
        _fade.forward();
      });
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_checkVisibility);
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: widget.builder(context, _visible),
    );
  }
}

class _CompetencyCard extends StatefulWidget {
  const _CompetencyCard({
    required this.track,
    required this.competency,
    required this.animate,
  });

  final StackTrack track;
  final TrackCompetency competency;

  /// Whether the card is currently on screen. The entrance/progress animation
  /// only plays once the card becomes visible.
  final bool animate;

  @override
  State<_CompetencyCard> createState() => _CompetencyCardState();
}

class _CompetencyCardState extends State<_CompetencyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  bool _started = false;

  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _ringPulse = Tween(begin: 1.0, end: 1.06)
      .animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(
            0.72,
            1.0,
            curve: Curves.easeOutBack,
          ),
        ),
      );

  late final Animation<double> _entrance = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _maybeStart();
  }

  @override
  void didUpdateWidget(covariant _CompetencyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      _maybeStart();
    }
  }

  void _maybeStart() {
    if (widget.animate && !_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.track;
    final competency = widget.competency;
    final target = (competency.score / 100).clamp(0.0, 1.0);

    return FadeTransition(
      opacity: _entrance,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(_entrance),
        child: _ProgressCard(
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Transform.scale(
                  scale: _ringPulse.value,
                  child: child,
                ),
                child: SizedBox(
                  width: 96.r,
                  height: 96.r,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 96.r,
                        height: 96.r,
                        child: CircularProgressIndicator(
                          value: target * _progress.value,
                          strokeWidth: 6,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          valueColor: AlwaysStoppedAnimation(track.color),
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: competency.score.toDouble()),
                        duration: const Duration(milliseconds: 1100),
                        curve: Curves.easeOutCubic,
                        builder: (context, score, _) => Text(
                          '${score.round()}',
                          style: AppTypography.numeralLg.copyWith(
                            color: AppColors.onSurface,
                            fontSize: 28.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
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
            ],
          ),
        ),
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
                Expanded(
                  child: Text(
                    area.title,
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
