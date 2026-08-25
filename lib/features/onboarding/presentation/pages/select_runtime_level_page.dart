import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/runtime_level_card.dart';
import 'system_initialized_page.dart';

/// Onboarding step 2: calibrate the user's experience level.
class SelectRuntimeLevelPage extends StatelessWidget {
  const SelectRuntimeLevelPage({super.key});

  void _continue(BuildContext context) async {
    final cubit = context.read<OnboardingCubit>();
    final summary = await cubit.submit();
    if (summary == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            SystemInitializedPage(onboardingSummary: summary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.lg,
                  AppSpacing.margin,
                  AppSpacing.lg,
                ),
                // A plain (non-scrolling) column: every child below is sized
                // to fit the available height, so this step never scrolls.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Step 2 of 2',
                          style: AppTypography.labelMono.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.outlineVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      'Set Your Runtime Level',
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Calibration helps us serve high-signal questions at '
                      'your current level of expertise.',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    // Cards share the remaining height evenly, so exactly
                    // levels.length cards always fit without overflow.
                    Expanded(
                      child: BlocBuilder<OnboardingCubit, OnboardingState>(
                        buildWhen: (previous, current) =>
                            previous.levels != current.levels ||
                            previous.selectedLevelId !=
                                current.selectedLevelId,
                        builder: (context, state) {
                          final levels = state.levels;
                          return Column(
                            children: [
                              for (final level in levels)
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: level == levels.last
                                          ? 0
                                          : AppSpacing.md,
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: RuntimeLevelCard(
                                        level: level,
                                        selected:
                                            state.selectedLevelId == level.id,
                                        onTap: () => context
                                            .read<OnboardingCubit>()
                                            .selectLevel(level.id),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.margin,
                AppSpacing.md,
                AppSpacing.margin,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurface,
                        side: const BorderSide(color: AppColors.outlineVariant),
                        padding: EdgeInsets.symmetric(vertical: 14.r),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusMd,
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _continue(context),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.r),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusMd,
                        ),
                      ),
                      child: const Text('Continue'),
                    ),
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
