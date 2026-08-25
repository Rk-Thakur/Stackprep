import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Small uppercase label-mono chip, e.g. a track category ("ANDROID").
class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.label,
    this.color,
    this.background,
  });

  final String label;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4.r),
      decoration: BoxDecoration(
        color: background ?? AppColors.surfaceContainerHigh,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Text(
        label,
        style: AppTypography.labelMono.copyWith(
          fontSize: 11.sp,
          color: color ?? AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
