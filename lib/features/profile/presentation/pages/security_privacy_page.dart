import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../practice/presentation/pages/practice_page.dart';
import '../../../progress/presentation/pages/progress_page.dart';

/// Security & Privacy page, reached from the Profile tab.
class SecurityPrivacyPage extends StatelessWidget {
  const SecurityPrivacyPage({super.key});

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
                      'Security Settings',
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 26.sp,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Manage your credentials, active sessions, and data '
                      'privacy controls.',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    const _SectionLabel('CREDENTIALS'),
                    SizedBox(height: AppSpacing.sm),
                    _SettingsCard(
                      rows: [
                        _SettingsRow(
                          icon: Icons.password_rounded,
                          title: 'Change Password',
                          subtitle: 'Last updated 45 days ago',
                          trailing: const _Chevron(),
                          onTap: () =>
                              _comingSoon(context, 'Change Password'),
                        ),
                        _SettingsRow(
                          icon: Icons.phonelink_lock_rounded,
                          title: 'Two-Factor Authentication',
                          subtitle: 'Authenticator app configured',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _FilledBadge('ENABLED'),
                              SizedBox(width: AppSpacing.xs),
                              const _Chevron(),
                            ],
                          ),
                          onTap: () =>
                              _comingSoon(context, 'Two-Factor Authentication'),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'ACTIVE_SESSIONS',
                            style: AppTypography.labelMono.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _comingSoon(context, 'Revoke all'),
                          child: Text(
                            'REVOKE_ALL',
                            style: AppTypography.labelMono.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Container(height: 1, color: AppColors.outlineVariant),
                    SizedBox(height: AppSpacing.sm),
                    _SettingsCard(
                      rows: [
                        _SessionRow(
                          icon: Icons.smartphone_rounded,
                          title: 'iPhone 15',
                          badge: 'CURRENT DEVICE',
                          location: 'New York, US • Active now',
                          ip: '192.168.1.104',
                        ),
                        _SessionRow(
                          icon: Icons.laptop_rounded,
                          title: 'MacBook Pro 14"',
                          location: 'London, UK • Last active 2h ago',
                          ip: '203.0.113.42',
                          onRevoke: () =>
                              _comingSoon(context, 'Revoke MacBook Pro 14"'),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                    const _SectionLabel('PRIVACY_CONTROLS'),
                    SizedBox(height: AppSpacing.sm),
                    _SettingsCard(
                      rows: [
                        _SettingsRow(
                          icon: Icons.download_rounded,
                          title: 'Data Export',
                          subtitle: 'Download an archive of your account data',
                          trailing: const _Chevron(),
                          onTap: () => _comingSoon(context, 'Data Export'),
                        ),
                        _SettingsRow(
                          icon: Icons.extension_rounded,
                          title: 'Third-party Integrations',
                          subtitle: 'Manage connected apps and services',
                          trailing: const _Chevron(),
                          onTap: () =>
                              _comingSoon(context, 'Third-party Integrations'),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Container(
                      height: 1,
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14.r,
                          color: AppColors.error,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'DANGER_ZONE',
                          style: AppTypography.labelMono.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: AppRadius.radiusLg,
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete Account',
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4.r),
                          Text(
                            'Permanently delete your account and all '
                            'associated data. This action cannot be undone.',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _comingSoon(context, 'Delete account'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.errorContainer,
                                foregroundColor: AppColors.onErrorContainer,
                                padding: EdgeInsets.symmetric(vertical: 14.r),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.radiusMd,
                                ),
                                textStyle: AppTypography.labelMono.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('DELETE_ACCOUNT'),
                            ),
                          ),
                        ],
                      ),
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
                    MaterialPageRoute(builder: (_) => const PracticePage()),
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProgressPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMono.copyWith(color: AppColors.primary),
        ),
        SizedBox(height: AppSpacing.xs),
        Container(height: 1, color: AppColors.outlineVariant),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Container(height: 1, color: AppColors.outlineVariant),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2.r,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2.r),
              child: Icon(icon, size: 20.r, color: AppColors.onSurfaceVariant),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.r),
                    Text(
                      subtitle!,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.icon,
    required this.title,
    required this.location,
    required this.ip,
    this.badge,
    this.onRevoke,
  });

  final IconData icon;
  final String title;
  final String location;
  final String ip;
  final String? badge;
  final VoidCallback? onRevoke;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2.r,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.r),
            child: Icon(icon, size: 20.r, color: AppColors.onSurfaceVariant),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.xs,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (badge != null) _OutlinedBadge(badge!),
                  ],
                ),
                SizedBox(height: 2.r),
                Text(
                  location,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 2.r),
                Text(
                  'IP: $ip',
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          if (onRevoke != null)
            InkWell(
              onTap: onRevoke,
              borderRadius: AppRadius.radiusSm,
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: Icon(
                  Icons.logout_rounded,
                  size: 20.r,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      size: 20.r,
      color: AppColors.onSurfaceVariant,
    );
  }
}

class _FilledBadge extends StatelessWidget {
  const _FilledBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Text(
        label,
        style: AppTypography.labelMono.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}

class _OutlinedBadge extends StatelessWidget {
  const _OutlinedBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: AppRadius.radiusFull,
      ),
      child: Text(
        label,
        style: AppTypography.labelMono.copyWith(
          color: AppColors.onSurfaceVariant,
          fontSize: 9.sp,
        ),
      ),
    );
  }
}
