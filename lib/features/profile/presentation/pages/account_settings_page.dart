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
import '../../../auth/domain/usecases/delete_account.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../practice/presentation/pages/practice_page.dart';
import '../../../progress/presentation/pages/progress_page.dart';
import '../../../splash/presentation/pages/splash_page.dart';
import '../../../../core/theme/app_theme_scope.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart' as di;
import '../../../export/data/progress_report_exporter.dart';
import '../../../export/presentation/pages/export_data_sheet.dart';
import '../widgets/delete_account_confirm_dialog.dart';

/// Account Settings page, reached from the Profile tab.
class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  String? _username;
  bool _deleting = false;

  String _themeCaption(BuildContext context) {
    final mode = context.select<ThemeCubit, ThemeMode>((c) => c.state.mode);
    return switch (mode) {
      ThemeMode.system => 'Follows your device setting',
      ThemeMode.light => 'Always light',
      ThemeMode.dark => 'Always dark',
    };
  }

  Future<void> _showThemePicker(BuildContext context) async {
    final cubit = context.read<ThemeCubit>();
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => _ThemePickerSheet(
        mode: cubit.state.mode,
        onSelect: (mode) => Navigator.of(sheetContext).pop(mode),
      ),
    );
    if (selected == null) return;
    await cubit.setMode(selected);
  }

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$feature coming soon.')));
  }

  /// Opens the export sheet and reports where the report landed, since the
  /// save is silent otherwise and the file is not on screen anywhere. A null
  /// result covers both a dismissed sheet and a cancelled save picker.
  Future<void> _exportData() async {
    final saved = await ExportDataSheet.show(
      context,
      exporter: di.sl<ProgressReportExporter>(),
    );
    if (saved == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(saved.location)));
  }

  String _resolveUsername(String displayName, String email) {
    if (_username != null && _username!.isNotEmpty) return _username!;
    if (displayName.isNotEmpty) return displayName;
    return email.isEmpty ? 'Not set' : email;
  }

  /// Wipes the account for good and drops the user back at the splash screen,
  /// which will route them to sign-in now that nobody is authenticated.
  Future<void> _deleteAccount() async {
    final email = context.read<AuthBloc>().state.user?.email;
    final confirmed = await DeleteAccountConfirmDialog.show(
      context,
      email: email,
    );
    if (!confirmed || !mounted) return;

    setState(() => _deleting = true);
    final result = await di.sl<DeleteAccount>()(const NoParams());
    if (!mounted) return;

    // Undo the spinner on the way out: either the account is gone and the
    // navigator takes over, or the failure is reported on this page.
    setState(() => _deleting = false);
    final failure = result.fold((failure) => failure, (_) => null);
    if (failure != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(failure.message)));
      return;
    }

    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashPage()),
      (route) => false,
    );
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

    return Themed(
      child: Scaffold(
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
                            icon: Icons.palette_outlined,
                            title: 'Theme',
                            subtitle: _themeCaption(context),
                            trailing: const _Chevron(),
                            onTap: () => _showThemePicker(context),
                          ),
                          _SettingsRow(
                            icon: Icons.file_download_outlined,
                            title: 'Export Data',
                            subtitle: 'Save your progress as a PDF report',
                            trailing: const _Chevron(),
                            onTap: _exportData,
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
                                onPressed: _deleting
                                    ? null
                                    : () => _deleteAccount(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: BorderSide(
                                    color: AppColors.error.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12.r),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.radiusMd,
                                  ),
                                ),
                                child: _deleting
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Delete Account'),
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

/// Bottom sheet offering the three theme choices. Applies the selection on
/// tap, which repaints the whole app through `ThemeCubit`.
class _ThemePickerSheet extends StatelessWidget {
  const _ThemePickerSheet({required this.mode, required this.onSelect});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onSelect;

  @override
  Widget build(BuildContext context) {
    const options = <(ThemeMode, String, IconData, String)>[
      (
        ThemeMode.system,
        'System',
        Icons.brightness_auto_rounded,
        'Follow your device setting',
      ),
      (
        ThemeMode.light,
        'Light',
        Icons.light_mode_rounded,
        'Warm paper background',
      ),
      (
        ThemeMode.dark,
        'Dark',
        Icons.dark_mode_rounded,
        "The original engineer's notebook",
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.r),
              child: Container(
                width: 40.r,
                height: 4.r,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: AppRadius.radiusFull,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.margin,
                0,
                AppSpacing.margin,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    'APPEARANCE',
                    style: AppTypography.labelMono.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.margin,
                0,
                AppSpacing.margin,
                AppSpacing.md,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < options.length; i++) ...[
                      _ThemeOption(
                        title: options[i].$2,
                        subtitle: options[i].$4,
                        icon: options[i].$3,
                        selected: mode == options[i].$1,
                        onTap: () => onSelect(options[i].$1),
                      ),
                      if (i != options.length - 1)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: Container(
                            height: 1,
                            color: AppColors.outlineVariant,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.margin,
                0,
                AppSpacing.margin,
                AppSpacing.md,
              ),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

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
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.r),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, size: 20.r, color: AppColors.primary),
          ],
        ),
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
        side: BorderSide(color: AppColors.outlineVariant),
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
