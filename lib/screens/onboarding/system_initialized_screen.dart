import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/runtime_levels.dart';
import '../../data/stack_tracks.dart';
import '../../models/runtime_level.dart';
import '../../models/stack_track.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../home/home_screen.dart';

/// Title-cased display name for a [RuntimeLevel.id], for prose contexts
/// where [RuntimeLevel.title]'s all-caps styling (used on the level-select
/// cards) would look shouty.
const Map<String, String> _kLevelDisplayNames = {
  'junior': 'Junior',
  'mid': 'Mid-Level',
  'senior': 'Senior',
};

/// Onboarding step 3: recaps the stack + runtime level chosen in steps 1-2,
/// then hands off into the app.
class SystemInitializedScreen extends StatelessWidget {
  const SystemInitializedScreen({
    super.key,
    required this.selectedTrackIds,
    required this.runtimeLevelId,
  });

  final List<String> selectedTrackIds;
  final String runtimeLevelId;

  List<StackTrack> get _selectedTracks => kStackTracks
      .where((track) => selectedTrackIds.contains(track.id))
      .toList();

  RuntimeLevel get _runtimeLevel => kRuntimeLevels.firstWhere(
    (level) => level.id == runtimeLevelId,
    orElse: () => kRuntimeLevels[1],
  );

  @override
  Widget build(BuildContext context) {
    final tracks = _selectedTracks;
    final level = _runtimeLevel;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.margin,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    SizedBox(height: AppSpacing.xl),
                    _CheckmarkBadge(),
                    SizedBox(height: AppSpacing.xl),
                    Text(
                      'System Initialized',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your personalized curriculum is ready for execution.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    _ConfigurationSummaryCard(tracks: tracks, level: level),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.margin,
                AppSpacing.sm,
                AppSpacing.margin,
                AppSpacing.md,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.r),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusMd,
                    ),
                    textStyle: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Enter Workspace'),
                      SizedBox(width: AppSpacing.sm),
                      Icon(Icons.arrow_forward_rounded, size: 20.r),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckmarkBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128.r,
      height: 128.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: Container(
        width: 72.r,
        height: 72.r,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_rounded,
          size: 36.r,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}

class _ConfigurationSummaryCard extends StatelessWidget {
  const _ConfigurationSummaryCard({required this.tracks, required this.level});

  final List<StackTrack> tracks;
  final RuntimeLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'CONFIGURATION SUMMARY',
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                Icons.settings_rounded,
                size: 18.r,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Container(height: 1, color: AppColors.outlineVariant),
          SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Stack',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final track in tracks)
                          _StackChip(label: track.name),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Runtime',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.military_tech_rounded,
                          size: 18.r,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          _kLevelDisplayNames[level.id] ?? level.title,
                          style: AppTypography.bodyLg.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'Objective Focus',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Center(
            child: Text(
              level.focus,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StackChip extends StatelessWidget {
  const _StackChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6.r),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Text(
        label,
        style: AppTypography.codeSm.copyWith(color: AppColors.primary),
      ),
    );
  }
}
