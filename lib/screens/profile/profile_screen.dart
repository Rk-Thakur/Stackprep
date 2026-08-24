import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/activity_heatmap.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/track_pill.dart';
import '../practice/practice_screen.dart';
import '../progress/progress_screen.dart';
import 'account_settings_screen.dart';
import 'security_privacy_screen.dart';

class _LinkedTrack {
  const _LinkedTrack(this.label, this.dotColor);

  final String label;
  final Color dotColor;
}

const List<_LinkedTrack> _kLinkedTracks = [
  _LinkedTrack('Kotlin', Color(0xFF8B5CF6)),
  _LinkedTrack('Swift', Color(0xFFF14C33)),
];

class _PreferenceItem {
  const _PreferenceItem({required this.icon, required this.title, this.tag});

  final IconData icon;
  final String title;
  final String? tag;
}

const List<_PreferenceItem> _kPreferences = [
  _PreferenceItem(icon: Icons.settings_rounded, title: 'Account Settings'),
  _PreferenceItem(
    icon: Icons.credit_card_rounded,
    title: 'Subscription',
    tag: 'PRO',
  ),
  _PreferenceItem(
    icon: Icons.shield_outlined,
    title: 'Security & Privacy',
  ),
];

/// Profile tab: identity card, mastery/streak summary, linked tracks, and
/// account preferences.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            AppTopBar(onMenuTap: () => _comingSoon(context, 'Menu')),
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
                    const _ProfileHeaderCard(),
                    SizedBox(height: AppSpacing.md),
                    const _MasteryScoreCard(),
                    SizedBox(height: AppSpacing.md),
                    const _StreakCard(),
                    SizedBox(height: AppSpacing.md),
                    _LinkedTracksCard(
                      onAddTrack: () => _comingSoon(context, 'Add track'),
                    ),
                    SizedBox(height: AppSpacing.md),
                    _PreferencesCard(
                      onTapItem: (title) {
                        if (title == 'Account Settings') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AccountSettingsScreen(),
                            ),
                          );
                          return;
                        }
                        if (title == 'Security & Privacy') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SecurityPrivacyScreen(),
                            ),
                          );
                          return;
                        }
                        _comingSoon(context, title);
                      },
                    ),
                  ],
                ),
              ),
            ),
            AppBottomNavBar(
              currentIndex: 3,
              onTap: (i) {
                if (i == 3) return;
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
                  MaterialPageRoute(builder: (_) => const ProgressScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared card chrome matching the app's other screens.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

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

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard();

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: CircleAvatar(
              radius: 44.r,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: Icon(
                Icons.person_rounded,
                size: 48.r,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'L3_ENGINEER',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.badge_outlined,
                size: 14.r,
                color: AppColors.onSurfaceVariant,
              ),
              SizedBox(width: 4.r),
              Text(
                'ID: #0x42F',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4.r,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Text(
              'PRO_STATUS_ACTIVE',
              style: AppTypography.labelMono.copyWith(
                color: AppColors.primary,
                fontSize: 11.sp,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Last login: 2023-10-27 14:32:01',
            style: AppTypography.labelMono.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _MasteryScoreCard extends StatelessWidget {
  const _MasteryScoreCard();

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MASTERY_SCORE',
            style: AppTypography.labelMono.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Center(
            child: SizedBox(
              width: 140.r,
              height: 140.r,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140.r,
                    height: 140.r,
                    child: CircularProgressIndicator(
                      value: 0.72,
                      strokeWidth: 9,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    '72%',
                    style: AppTypography.numeralLg.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 32.sp,
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

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT_STREAK',
            style: AppTypography.labelMono.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '47',
                    style: AppTypography.numeralLg.copyWith(
                      color: AppColors.primary,
                      fontSize: 34.sp,
                    ),
                  ),
                  TextSpan(
                    text: ' days',
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (var i = 0; i < 4; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 3 ? 0 : 4.r),
                    child: Container(
                      height: 8.r,
                      decoration: BoxDecoration(
                        color: kReadinessScale[i + 1],
                        borderRadius: AppRadius.radiusSm,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Optimal Readiness',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedTracksCard extends StatelessWidget {
  const _LinkedTracksCard({required this.onAddTrack});

  final VoidCallback onAddTrack;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link_rounded,
                size: 16.r,
                color: AppColors.onSurfaceVariant,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'LINKED_TRACKS',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (final track in _kLinkedTracks)
                Padding(
                  padding: EdgeInsets.only(
                    right: track == _kLinkedTracks.last ? 0 : AppSpacing.xs,
                  ),
                  child: TrackPill(
                    label: track.label,
                    dotColor: track.dotColor,
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAddTrack,
              icon: Icon(Icons.add_rounded, size: 16.r),
              label: const Text('ADD_TRACK'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onSurface,
                side: const BorderSide(color: AppColors.outlineVariant),
                padding: EdgeInsets.symmetric(vertical: 12.r),
                textStyle: AppTypography.labelMono,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusMd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({required this.onTapItem});

  final ValueChanged<String> onTapItem;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              'SYSTEM_PREFERENCES',
              style: AppTypography.labelMono.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(height: 1, color: AppColors.outlineVariant),
          ),
          for (final item in _kPreferences)
            InkWell(
              onTap: () => onTapItem(item.title),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 20.r,
                      color: AppColors.onSurfaceVariant,
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.tag != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.r,
                          vertical: 2.r,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadius.radiusSm,
                        ),
                        child: Text(
                          item.tag!,
                          style: AppTypography.labelMono.copyWith(
                            color: AppColors.onPrimary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs),
                    ],
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20.r,
                      color: AppColors.onSurfaceVariant,
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
