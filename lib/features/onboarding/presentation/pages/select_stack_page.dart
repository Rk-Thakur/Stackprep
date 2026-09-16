import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/platform_option_card.dart';
import 'select_runtime_level_page.dart';

/// Onboarding step 1: pick the mobile platforms to prep for.
class SelectStackPage extends StatefulWidget {
  const SelectStackPage({super.key, this.manageTracks = false});

  /// When true, this page acts as a "manage tracks" screen reached from the
  /// profile: existing selections are pre-filled and saving pops back instead
  /// of advancing to the runtime-level step.
  final bool manageTracks;

  @override
  State<SelectStackPage> createState() => _SelectStackPageState();
}

class _SelectStackPageState extends State<SelectStackPage> {
  @override
  void initState() {
    super.initState();
    context.read<OnboardingCubit>().loadCatalogs();
    if (widget.manageTracks) {
      context.read<OnboardingCubit>().restoreSelection();
    }
  }

  void _toggle(String id) => context.read<OnboardingCubit>().toggleTrack(id);

  Future<void> _saveAndClose() async {
    final cubit = context.read<OnboardingCubit>();
    await cubit.saveTrackSelection();
    if (!mounted) return;
    Navigator.of(context).pop();
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
                      widget.manageTracks
                          ? 'Manage Your Stack'
                          : 'Initialize Your Stack',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.manageTracks
                          ? 'Update the mobile platforms you want to master.'
                          : 'Select the mobile platforms you want to master. '
                                'You can add more later.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    BlocBuilder<OnboardingCubit, OnboardingState>(
                      buildWhen: (previous, current) =>
                          previous.tracks != current.tracks ||
                          previous.selectedTrackIds != current.selectedTrackIds,
                      builder: (context, state) {
                        return Column(
                          children: [
                            ...state.tracks.map(
                              (track) => Padding(
                                padding: EdgeInsets.only(bottom: AppSpacing.md),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: PlatformOptionCard(
                                    track: track,
                                    selected: state.selectedTrackIds.contains(
                                      track.id,
                                    ),
                                    onTap: () => _toggle(track.id),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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
                    onPressed: widget.manageTracks
                        ? () => Navigator.of(context).pop()
                        : () {},
                    child: Text(
                      widget.manageTracks ? 'Cancel' : 'SKIP FOR NOW',
                      style: AppTypography.labelMono.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: widget.manageTracks
                        ? _saveAndClose
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SelectRuntimeLevelPage(),
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
                    child: Text(widget.manageTracks ? 'Save' : 'Continue'),
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
