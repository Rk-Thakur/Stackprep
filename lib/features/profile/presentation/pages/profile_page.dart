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
import '../../../../core/widgets/track_pill.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/auth_page.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../onboarding/data/datasources/onboarding_local_data_source.dart';
import '../../../onboarding/presentation/pages/select_stack_page.dart';
import '../../../practice/presentation/pages/practice_page.dart';
import '../../../progress/presentation/cubit/progress_cubit.dart';
import '../../../progress/presentation/cubit/progress_state.dart';
import '../../../progress/presentation/pages/progress_page.dart';
import '../../../../injection_container.dart' show sl;
import 'account_settings_page.dart';
import 'security_privacy_page.dart';

/// Engineer ladder title derived from the onboarding-selected runtime level.
String _engineerTitleFor(String levelId) {
  switch (levelId) {
    case 'junior':
      return 'L1_ENGINEER';
    case 'mid':
      return 'L2_ENGINEER';
    case 'senior':
      return 'L3_ENGINEER';
    default:
      return 'L2_ENGINEER';
  }
}

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
  _PreferenceItem(icon: Icons.shield_outlined, title: 'Security & Privacy'),
];

/// Profile tab: identity card, mastery/streak summary, linked tracks, and
/// account preferences.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$feature coming soon.')));
  }

  void _logout(BuildContext context) {
    context.read<AuthBloc>().add(const AuthSignOutRequested());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthPage()),
      (route) => false,
    );
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
              child: BlocProvider(
                create: (_) => sl<ProgressCubit>()..load(),
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
                      const _LinkedTracksCard(),
                      SizedBox(height: AppSpacing.md),
                      _PreferencesCard(
                        onTapItem: (title) {
                          if (title == 'Account Settings') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AccountSettingsPage(),
                              ),
                            );
                            return;
                          }
                          if (title == 'Security & Privacy') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SecurityPrivacyPage(),
                              ),
                            );
                            return;
                          }
                          _comingSoon(context, title);
                        },
                      ),
                      SizedBox(height: AppSpacing.md),
                      _LogoutButton(onTap: () => _logout(context)),
                    ],
                  ),
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
                    MaterialPageRoute(builder: (_) => const PracticePage()),
                  );
                  return;
                }
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ProgressPage()));
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
    final user = context.select<AuthBloc, AppUser?>((bloc) => bloc.state.user);
    final email = user?.email;
    final engineerTitle = _engineerTitleFor(
      sl<OnboardingLocalDataSource>().selectedRuntimeLevel,
    );

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
            engineerTitle,
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (email != null && email.isNotEmpty) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              email,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
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
    return BlocBuilder<ProgressCubit, ProgressState>(
      buildWhen: (previous, current) =>
          previous.summary?.globalReadinessScore !=
              current.summary?.globalReadinessScore ||
          previous.status != current.status,
      builder: (context, state) {
        final score = state.summary?.globalReadinessScore ?? 0;
        final displayPercent = (score * 100).clamp(0, 100).round();
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
                          value: score.clamp(0.0, 1.0),
                          strokeWidth: 9,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        '$displayPercent%',
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
      },
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressCubit, ProgressState>(
      buildWhen: (previous, current) =>
          previous.summary?.currentStreakDays !=
              current.summary?.currentStreakDays ||
          previous.status != current.status,
      builder: (context, state) {
        final streak = state.summary?.currentStreakDays ?? 0;
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
                          text: '$streak',
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
        },
      );
  }
}

class _LinkedTracksCard extends StatefulWidget {
  const _LinkedTracksCard();

  @override
  State<_LinkedTracksCard> createState() => _LinkedTracksCardState();
}

class _LinkedTracksCardState extends State<_LinkedTracksCard> {
  Future<void> _addTrack() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SelectStackPage(manageTracks: true),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds = sl<OnboardingLocalDataSource>().selectedTrackIds;
    final tracks = sl<OnboardingLocalDataSource>().stackTracks
        .where((t) => selectedIds.contains(t.id))
        .toList();

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
          if (tracks.isEmpty)
            Text(
              'No tracks linked yet.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final track in tracks)
                  TrackPill(label: track.name, dotColor: track.color),
              ],
            ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addTrack,
              icon: Icon(Icons.add_rounded, size: 16.r),
              label: const Text('ADD_TRACK'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onSurface,
                side: const BorderSide(color: AppColors.outlineVariant),
                padding: EdgeInsets.symmetric(vertical: 12.r),
                textStyle: AppTypography.labelMono,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
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

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.logout_rounded, size: 18.r, color: AppColors.error),
        label: Text(
          'Log Out',
          style: AppTypography.bodyLg.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
          padding: EdgeInsets.symmetric(vertical: 14.r),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        ),
      ),
    );
  }
}
