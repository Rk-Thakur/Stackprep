import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/stack_tracks.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/platform_option_card.dart';
import 'select_runtime_level_screen.dart';

/// Onboarding step 1: pick the mobile platforms to prep for.
class SelectStackScreen extends StatefulWidget {
  const SelectStackScreen({super.key});

  @override
  State<SelectStackScreen> createState() => _SelectStackScreenState();
}

class _SelectStackScreenState extends State<SelectStackScreen> {
  final Set<String> _selectedIds = {};

  void _toggle(String id) {
    setState(() {
      if (!_selectedIds.add(id)) {
        _selectedIds.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.lg,
                  AppSpacing.margin,
                  AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    Text(
                      'STEP 1 OF 2',
                      style: AppTypography.labelMono.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: AppRadius.radiusSm,
                          ),
                          child: Icon(
                            Icons.terminal_rounded,
                            size: 14.r,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          "ENGINEER'S NOTEBOOK",
                          style: AppTypography.labelMono.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Initialize Your Stack',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Select the mobile platforms you want to master. '
                      'You can add more later.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    ...kStackTracks.map(
                      (track) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: SizedBox(
                          width: double.infinity,
                          child: PlatformOptionCard(
                            track: track,
                            selected: _selectedIds.contains(track.id),
                            onTap: () => _toggle(track.id),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.margin,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'SKIP FOR NOW',
                      style: AppTypography.labelMono.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SelectRuntimeLevelScreen(
                            selectedTrackIds: _selectedIds.toList(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: 12.r,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
