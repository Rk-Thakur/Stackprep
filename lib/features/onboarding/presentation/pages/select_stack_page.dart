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
  const SelectStackPage({super.key});

  @override
  State<SelectStackPage> createState() => _SelectStackPageState();
}

class _SelectStackPageState extends State<SelectStackPage> {
  @override
  void initState() {
    super.initState();
    context.read<OnboardingCubit>().loadCatalogs();
  }

  void _toggle(String id) => context.read<OnboardingCubit>().toggleTrack(id);

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
                    BlocBuilder<OnboardingCubit, OnboardingState>(
                      buildWhen: (previous, current) =>
                          previous.tracks != current.tracks ||
                          previous.selectedTrackIds !=
                              current.selectedTrackIds,
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
