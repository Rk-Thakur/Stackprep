import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// The app's shared top bar: hamburger menu, "Engineer's Notebook" title,
/// and a profile avatar. Used across the main tab screens.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.onMenuTap,
    this.onAvatarTap,
    this.showBottomDivider = false,
  });

  final VoidCallback onMenuTap;
  final VoidCallback? onAvatarTap;
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
            InkWell(
              onTap: onMenuTap,
              borderRadius: AppRadius.radiusSm,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xs),
                child: Icon(
                  Icons.menu_rounded,
                  size: 24.r,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                "Engineer's Notebook",
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.primary,
                  fontSize: 20.sp,
                ),
              ),
            ),
            InkWell(
              onTap: onAvatarTap,
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: Icon(
                  Icons.person_rounded,
                  size: 20.r,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
