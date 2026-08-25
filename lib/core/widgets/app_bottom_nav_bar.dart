import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class AppNavItem {
  const AppNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const List<AppNavItem> kAppNavItems = [
  AppNavItem(icon: Icons.home_rounded, label: 'Home'),
  AppNavItem(icon: Icons.terminal_rounded, label: 'Practice'),
  AppNavItem(icon: Icons.bar_chart_rounded, label: 'Progress'),
  AppNavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
];

/// Bottom tab bar: the active tab gets a solid amber pill, inactive tabs
/// stay muted icon-over-label.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              for (var i = 0; i < kAppNavItems.length; i++)
                Expanded(
                  child: _NavTab(
                    item: kAppNavItems[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.onPrimary : AppColors.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMd,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.r),
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.radiusMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 22.r, color: color),
            SizedBox(height: 2.r),
            Text(
              item.label,
              style: AppTypography.bodyMd.copyWith(
                fontSize: 11.sp,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
