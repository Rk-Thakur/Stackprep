import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/activity_heatmap.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/track_pill.dart';
import '../../../onboarding/data/datasources/onboarding_local_data_source.dart';
import '../../../practice/presentation/pages/practice_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../progress/presentation/pages/progress_page.dart';
import '../../../topics/presentation/pages/topic_detail_page.dart';
import '../../../../injection_container.dart' show sl;

/// Title-cased display name for a runtime level ID.
const Map<String, String> _kLevelDisplayNames = {
  'junior': 'Junior',
  'mid': 'Mid-Level',
  'senior': 'Senior',
};

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

  String get _levelLabel {
    final levelId = sl<OnboardingLocalDataSource>().selectedRuntimeLevel;
    return _kLevelDisplayNames[levelId] ?? 'Dev';
  }

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
                      '$_greeting, $_levelLabel Dev.',
                      style: AppTypography.headlineLgResponsive(
                        context,
                      ).copyWith(color: AppColors.onSurface),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Row(
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
                          '12',
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
                    ),
                    SizedBox(height: AppSpacing.lg),
                    const _ActivityCard(),
                    SizedBox(height: AppSpacing.md),
                    _DailyChallengeCard(
                      onStart: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TopicDetailPage()),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    _ContinueCard(
                      onResume: () => _comingSoon(context, 'Resume'),
                    ),
                    SizedBox(height: AppSpacing.md),
                    const _WeakTopicsCard(),
                  ],
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
    );
  }
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
    return _HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Activity (35 Days)',
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
          const ActivityHeatmap(days: 35, columns: 7),
        ],
      ),
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard({required this.onStart});

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
                Icons.hub_rounded,
                size: 20.r,
                color: AppColors.primary,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Offline-first sync strategy',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 2.r),
          Text(
            'System Design Module',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: const [
              TrackPill(label: 'Kotlin', dotColor: Color(0xFF8B5CF6)),
              SizedBox(width: 8),
              TrackPill(label: 'Swift', dotColor: Color(0xFFF14C33)),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.r),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusMd,
                ),
              ),
              child: const Text('Start Challenge'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.onResume});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
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
            'Flutter Layout Constraints',
            style: AppTypography.bodyLg.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.r),
          Text(
            'Advanced UI Patterns',
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
                        value: 0.65,
                        strokeWidth: 4,
                        backgroundColor: AppColors.outlineVariant,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      '65',
                      style: AppTypography.numeralLg.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Mastery Score',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
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
                child: const Text('Resume Course'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeakTopicRow {
  const _WeakTopicRow(this.label, this.dotColor);

  final String label;
  final Color dotColor;
}

const List<_WeakTopicRow> _kWeakTopics = [
  _WeakTopicRow('Concurrency (iOS)', Color(0xFFF14C33)),
  _WeakTopicRow('State Management (React Native)', Color(0xFF61DAFB)),
  _WeakTopicRow('DI (Kotlin)', Color(0xFF8B5CF6)),
];

class _WeakTopicsCard extends StatelessWidget {
  const _WeakTopicsCard();

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
          for (final topic in _kWeakTopics)
            Padding(
              padding: EdgeInsets.only(
                bottom: topic == _kWeakTopics.last ? 0 : AppSpacing.sm,
              ),
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
                        color: topic.dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        topic.label,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
