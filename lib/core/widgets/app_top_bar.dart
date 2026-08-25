import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// The app's shared top bar with the "StackPrep" title.
/// Used across the main tab screens.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.onMenuTap,
    this.showBottomDivider = false,
  });

  final VoidCallback? onMenuTap;
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
            Expanded(
              child: Text(
                'StackPrep',
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.primary,
                  fontSize: 20.sp,
                ),
              ),
            ),
            if (onMenuTap != null)
              IconButton(
                onPressed: onMenuTap,
                icon: Icon(
                  Icons.menu_rounded,
                  size: 22.r,
                  color: AppColors.onSurface,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
