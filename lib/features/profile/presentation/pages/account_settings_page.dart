import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/terminal_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../practice/presentation/pages/practice_page.dart';
import '../../../progress/presentation/pages/progress_page.dart';

/// Account Settings page, reached from the Profile tab.
class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  String? _username;

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$feature coming soon.')));
  }

  String _resolveUsername(String displayName, String email) {
    if (_username != null && _username!.isNotEmpty) return _username!;
    if (displayName.isNotEmpty) return displayName;
    return email.isEmpty ? 'Not set' : email;
  }

  Future<void> _editUsername(String current) async {
    final controller = TextEditingController(text: current);

    final saved = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _EditUsernameDialog(controller: controller),
    );
    if (saved == null || saved.isEmpty) return;

    setState(() => _username = saved);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Username updated.')));
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        context.select<AuthBloc, String?>((b) => b.state.user?.displayName) ??
        '';
    final email =
        context.select<AuthBloc, String?>((b) => b.state.user?.email) ?? '';
    final username = _resolveUsername(displayName, email);

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
                    color: AppColors.onSurface,
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
                    const _SectionLabel('PROFILE CUSTOMIZATION'),
                    SizedBox(height: AppSpacing.sm),
                    _SettingsCard(
                      rows: [
                        _SettingsRow(
                          icon: Icons.badge_outlined,
                          title: 'Edit Username',
                          subtitle: username,
                          trailing: Icon(
                            Icons.edit_rounded,
                            size: 18.r,
                            color: AppColors.primary,
                          ),
                          onTap: () => _editUsername(username),
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
                                color: AppColors.primary.withValues(alpha: 0.5),
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
                          onTap: () => _comingSoon(context, 'Technical Stack'),
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
                          trailing: const _Chevron(),
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
                    Container(
                      height: 1,
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withValues(alpha: 0.12),
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
                                  color: AppColors.error.withValues(alpha: 0.5),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.r),
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

class _EditUsernameDialog extends StatelessWidget {
  const _EditUsernameDialog({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLg,
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EDIT USERNAME',
              style: AppTypography.labelMono.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Update the name shown on your profile.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            TerminalTextField(
              controller: controller,
              icon: Icons.badge_outlined,
              hintText: 'Enter username',
            ),
            SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(controller.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusMd,
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
