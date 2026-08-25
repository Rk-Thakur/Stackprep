import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pill_badge.dart';
import '../../../../core/widgets/track_icon.dart';
import '../../domain/entities/stack_track.dart';

/// A full-width selectable card representing one [StackTrack].
class PlatformOptionCard extends StatelessWidget {
  const PlatformOptionCard({
    super.key,
    required this.track,
    required this.selected,
    required this.onTap,
  });

  final StackTrack track;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.radiusLg,
            child: Stack(
              children: [
                Positioned(
                  top: -18.r,
                  right: -18.r,
                  child: TrackShapeAccent(
                    shape: track.shape,
                    color: track.color,
                    selected: selected,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TrackIcon(
                        shape: track.shape,
                        color: track.color,
                        gradient: track.gradient,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        track.name,
                        style: AppTypography.headlineMd.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      PillBadge(label: track.category),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
