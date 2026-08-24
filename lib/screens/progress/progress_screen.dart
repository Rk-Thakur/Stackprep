import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/stack_tracks.dart';
import '../../models/stack_track.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/activity_heatmap.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_top_bar.dart';
import '../practice/practice_screen.dart';
import '../profile/profile_screen.dart';

class _TrackProgress {
  const _TrackProgress(this.score, this.level);

  final int score;
  final String level;
}

const Map<String, _TrackProgress> _kTrackProgress = {
  'kotlin': _TrackProgress(72, 'ADVANCED'),
  'swift': _TrackProgress(85, 'EXPERT'),
  'flutter': _TrackProgress(42, 'INTERMEDIATE'),
  'react_native': _TrackProgress(58, 'INTERMEDIATE'),
};

class _FocusArea {
  const _FocusArea({
    required this.title,
    required this.percent,
    required this.trendIcon,
    required this.trendLabel,
    this.critical = false,
  });

  final String title;
  final double percent;
  final bool critical;
  final IconData trendIcon;
  final String trendLabel;
}

const List<_FocusArea> _kFocusAreas = [
  _FocusArea(
    title: 'Memory Management',
    percent: 0.88,
    critical: true,
    trendIcon: Icons.trending_up_rounded,
    trendLabel: '+5% this week',
  ),
  _FocusArea(
    title: 'Concurrency',
    percent: 0.85,
    trendIcon: Icons.trending_up_rounded,
    trendLabel: '+3% this week',
  ),
  _FocusArea(
    title: 'Design Patterns',
    percent: 0.78,
    trendIcon: Icons.trending_up_rounded,
    trendLabel: '+2% this week',
  ),
  _FocusArea(
    title: 'UI Architecture',
    percent: 0.64,
    trendIcon: Icons.remove_rounded,
    trendLabel: 'Stable',
  ),
  _FocusArea(
    title: 'Networking',
    percent: 0.45,
    trendIcon: Icons.auto_awesome_rounded,
    trendLabel: 'Level up',
  ),
];

/// Progress tab: activity commitment, an aggregate readiness score, a
/// filterable per-track competency breakdown, and weak-area telemetry.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String? _selectedTrackId;

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    final tracks = _selectedTrackId == null
        ? kStackTracks
        : kStackTracks.where((t) => t.id == _selectedTrackId).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(onMenuTap: () => _comingSoon('Menu')),
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
                    const _CommitmentEngineCard(),
                    SizedBox(height: AppSpacing.md),
                    const _SystemMasteryCard(),
                    SizedBox(height: AppSpacing.lg),
                    const _SectionTitle('Core Competencies'),
                    SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _TrackFilterChip(
                          label: 'All',
                          selected: _selectedTrackId == null,
                          onTap: () => setState(() => _selectedTrackId = null),
                        ),
                        for (final track in kStackTracks)
                          _TrackFilterChip(
                            label: track.name,
                            color: track.color,
                            selected: _selectedTrackId == track.id,
                            onTap: () =>
                                setState(() => _selectedTrackId = track.id),
                          ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    for (final track in tracks)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: track == tracks.last ? 0 : AppSpacing.md,
                        ),
                        child: _CompetencyCard(
                          track: track,
                          progress: _kTrackProgress[track.id],
                        ),
                      ),
                    SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        const Expanded(child: _SectionTitle('Focus Areas')),
                        OutlinedButton.icon(
                          onPressed: () => _comingSoon('Add focus area'),
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
                    for (var i = 0; i < _kFocusAreas.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == _kFocusAreas.length - 1
                              ? 0
                              : AppSpacing.sm,
                        ),
                        child: _FocusAreaCard(
                          area: _kFocusAreas[i],
                          onTap: () => _comingSoon(_kFocusAreas[i].title),
                        ),
                      ),
                  ],
                ),
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
                    MaterialPageRoute(builder: (_) => const PracticeScreen()),
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
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
  const _CommitmentEngineCard();

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
                  value: '14',
                  suffix: ' DAYS',
                ),
              ),
              Expanded(
                child: _StatColumn(label: 'TOTAL SESSIONS', value: '284'),
              ),
              Expanded(
                child: _StatColumn(
                  label: 'READINESS SCORE',
                  value: '87',
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
  const _SystemMasteryCard();

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
                '72%',
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
              value: 0.72,
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
                'TARGET: 90%',
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
  const _CompetencyCard({required this.track, required this.progress});

  final StackTrack track;
  final _TrackProgress? progress;

  @override
  Widget build(BuildContext context) {
    final score = progress?.score ?? 0;
    final level = progress?.level ?? 'UNRATED';
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
                    value: score / 100,
                    strokeWidth: 6,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation(track.color),
                  ),
                ),
                Text(
                  '$score',
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
            level,
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

  final _FocusArea area;
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
                  area.trendIcon,
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
