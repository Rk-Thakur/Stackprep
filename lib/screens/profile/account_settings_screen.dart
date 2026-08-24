import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../practice/practice_screen.dart';
import '../progress/progress_screen.dart';

/// Account Settings screen, reached from the Profile tab.
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

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
            _TopBar(),
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
                    const _SectionLabel('SECURITY'),
                    SizedBox(height: AppSpacing.sm),
                    _SettingsCard(
                      rows: [
                        _SettingsRow(
                          icon: Icons.key_rounded,
                          title: 'Change Password',
                          trailing: _Chevron(),
                          onTap: () =>
                              _comingSoon(context, 'Change Password'),
                        ),
                        _SettingsRow(
                          icon: Icons.gpp_good_outlined,
                          title: 'Two-Factor Authentication',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _StatusBadge('Enabled'),
                              SizedBox(width: AppSpacing.xs),
                              _Chevron(),
                            ],
                          ),
                          onTap: () =>
                              _comingSoon(context, 'Two-Factor Authentication'),
                        ),
                        _SettingsRow(
                          icon: Icons.devices_rounded,
                          title: 'Active Sessions',
                          trailing: _Chevron(),
                          onTap: () =>
                              _comingSoon(context, 'Active Sessions'),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                    const _SectionLabel('PROFILE CUSTOMIZATION'),
                    SizedBox(height: AppSpacing.sm),
                    _SettingsCard(
                      rows: [
                        _SettingsRow(
                          icon: Icons.badge_outlined,
                          title: 'Edit Username',
                          subtitle: '@dev_ops_ninja',
                          trailing: Icon(
                            Icons.edit_rounded,
                            size: 18.r,
                            color: AppColors.primary,
                          ),
                          onTap: () => _comingSoon(context, 'Edit Username'),
                        ),
                        _SettingsRow(
                          icon: Icons.account_circle_outlined,
                          title: 'Profile Avatar',
                          trailing: Container(
                            width: 32.r,
                            height: 32.r,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: AppRadius.radiusSm,
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              size: 18.r,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          onTap: () => _comingSoon(context, 'Profile Avatar'),
                        ),
                        _SettingsRow(
                          icon: Icons.terminal_rounded,
                          title: 'Technical Stack',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              _PlainChip('Kotlin'),
                              SizedBox(width: 6),
                              _PlainChip('Swift'),
                            ],
                          ),
                          onTap: () =>
                              _comingSoon(context, 'Technical Stack'),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                    const _SectionLabel('SYSTEM'),
                    SizedBox(height: AppSpacing.sm),
                    _SettingsCard(
                      rows: [
                        _SettingsRow(
                          icon: Icons.dark_mode_rounded,
                          title: 'Theme',
                          trailing: _ThemeToggle(
                            onSelectLight: () =>
                                _comingSoon(context, 'Light theme'),
                          ),
                        ),
                        _SettingsRow(
                          icon: Icons.auto_delete_outlined,
                          title: 'Clear Cache',
                          trailing: Text(
                            '14.2 MB',
                            style: AppTypography.labelMono.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          onTap: () => _comingSoon(context, 'Clear Cache'),
                        ),
                        _SettingsRow(
                          icon: Icons.file_download_outlined,
                          title: 'Export Data',
                          trailing: _Chevron(),
                          onTap: () => _comingSoon(context, 'Export Data'),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                    const _DashedDivider(),
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      'DANGER ZONE',
                      style: AppTypography.labelMono.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Container(height: 1, color: AppColors.error.withValues(alpha: 0.3)),
                    SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: AppRadius.radiusLg,
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Once you delete your account, there is no '
                            'going back. Please be certain.',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () =>
                                  _comingSoon(context, 'Delete account'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: BorderSide(
                                  color: AppColors.error.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 12.r,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.radiusMd,
                                ),
                              ),
                              child: const Text('Delete Account'),
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

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.margin,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: AppRadius.radiusSm,
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 24.r,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Account Settings',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
              ),
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
          children: [
            Icon(icon, size: 20.r, color: AppColors.onSurfaceVariant),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.r),
                    Text(
                      subtitle!,
                      style: AppTypography.codeSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      size: 20.r,
      color: AppColors.onSurfaceVariant,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.label);

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
        ),
      ),
    );
  }
}

class _PlainChip extends StatelessWidget {
  const _PlainChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 5.r),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: AppRadius.radiusFull,
      ),
      child: Text(
        label,
        style: AppTypography.labelMono.copyWith(
          color: AppColors.onSurfaceVariant,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.onSelectLight});

  final VoidCallback onSelectLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.r),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 5.r),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: AppRadius.radiusSm,
            ),
            child: Text(
              'Dark',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: onSelectLight,
            borderRadius: AppRadius.radiusSm,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 5.r),
              child: Text(
                'Light',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  static const double _dashWidth = 6;
  static const double _dashGap = 4;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute the count from the same scaled units each dash actually
        // renders at — dividing the (already-scaled) constraint by the
        // unscaled dash unit overcounts once `.r` is applied below,
        // overflowing the row by a few px.
        final dashWidth = _dashWidth.r;
        final dashGap = _dashGap.r;
        final count = (constraints.maxWidth / (dashWidth + dashGap)).floor();
        return Row(
          children: List.generate(count, (i) {
            return Padding(
              padding: EdgeInsets.only(right: i == count - 1 ? 0 : dashGap),
              child: Container(
                width: dashWidth,
                height: 1,
                color: AppColors.outlineVariant,
              ),
            );
          }),
        );
      },
    );
  }
}
