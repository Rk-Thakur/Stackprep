import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// The app's shared top bar with the StackPrep terminal icon and title.
/// Used across the main tab screens.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.trailing,
    this.showBottomDivider = false,
  });

  final Widget? trailing;
  final bool showBottomDivider;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: showBottomDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.outlineVariant),
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.margin,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Icon(
                Icons.terminal_rounded,
                size: 18.r,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'StackPrep',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.primary,
                  fontSize: 13.sp,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
