import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/track_icon.dart';
import '../../../onboarding/data/stack_tracks.dart';
import '../../../onboarding/domain/entities/stack_track.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../progress/presentation/pages/progress_page.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../topics/presentation/pages/topic_detail_page.dart';

const Map<String, String> _kCategoryDisplayNames = {
  'ANDROID': 'Android',
  'IOS': 'iOS',
  'CROSS-PLATFORM': 'Cross-Platform',
};

class _TrackMastery {
  const _TrackMastery(this.mastered, this.total);

  final int mastered;
  final int total;
}

const Map<String, _TrackMastery> _kTrackMastery = {
  'kotlin': _TrackMastery(42, 120),
  'swift': _TrackMastery(85, 130),
  'flutter': _TrackMastery(12, 115),
  'react_native': _TrackMastery(0, 110),
};

class _ConceptItem {
  const _ConceptItem(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}

const List<_ConceptItem> _kCommonConcepts = [
  _ConceptItem(
    Icons.autorenew_rounded,
    'Lifecycle Management',
    'State transitions across platforms',
  ),
  _ConceptItem(
    Icons.call_split_rounded,
    'Concurrency',
    'Async operations & threading models',
  ),
  _ConceptItem(
    Icons.vaccines_rounded,
    'Dependency Injection',
    'Inversion of control patterns',
  ),
];

/// Practice tab: pick a track to drill, or jump into a cross-platform
/// concept that spans every stack.
class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

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
            AppTopBar(
              onMenuTap: () => _comingSoon(context, 'Menu'),
              showBottomDivider: true,
            ),
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
                    _SearchBar(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SearchPage(),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    _SectionTitle('Tracks'),
                    SizedBox(height: AppSpacing.md),
                    for (final track in kStackTracks)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: track == kStackTracks.last
                              ? 0
                              : AppSpacing.md,
                        ),
                        child: _TrackCard(
                          track: track,
                          mastery: _kTrackMastery[track.id],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TopicDetailPage(),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Icon(
                          Icons.hub_rounded,
                          size: 22.r,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        _SectionTitle('Common Concepts'),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    for (var i = 0; i < _kCommonConcepts.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == _kCommonConcepts.length - 1
                              ? 0
                              : AppSpacing.sm,
                        ),
                        child: _ConceptRow(
                          item: _kCommonConcepts[i],
                          onTap: () =>
                              _comingSoon(context, _kCommonConcepts[i].title),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.headlineMd.copyWith(
        color: AppColors.onSurface,
        fontSize: 22.sp,
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMd,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14.r,
        ),
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
              child: Text(
                'Search topics, concepts, or stacks...',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.track,
    required this.mastery,
    required this.onTap,
  });

  final StackTrack track;
  final _TrackMastery? mastery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusLg,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radiusLg,
          child: Stack(
            children: [
              Positioned(
                top: -8.r,
                right: -8.r,
                child: TrackShapeAccent(shape: track.shape, color: track.color),
              ),
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(
                      child: TrackIcon(
                        shape: track.shape,
                        color: track.color,
                        gradient: track.gradient,
                        size: 44.r,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      track.name,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 19.sp,
                      ),
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      _kCategoryDisplayNames[track.category] ?? track.category,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    if (mastery != null)
                      Row(
                        children: [
                          Text(
                            'MASTERED: ',
                            style: AppTypography.labelMono.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${mastery!.mastered}/${mastery!.total}',
                            style: AppTypography.labelMono.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConceptRow extends StatelessWidget {
  const _ConceptRow({required this.item, required this.onTap});

  final _ConceptItem item;
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
          children: [
            Icon(
              item.icon,
              size: 22.r,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.r),
                  Text(
                    item.subtitle,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22.r,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
