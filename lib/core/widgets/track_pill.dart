import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A capsule chip pairing a colored dot with a label, e.g. a track name
/// ("Kotlin", "Swift") attached to a challenge or lesson.
class TrackPill extends StatelessWidget {
  const TrackPill({super.key, required this.label, required this.dotColor});

  final String label;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: AppRadius.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}
