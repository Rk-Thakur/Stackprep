import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// The pill-shaped call to action, with a slow amber glow pulse — matches
/// the reference's `.glow-amber` treatment.
class SystemStartButton extends StatefulWidget {
  const SystemStartButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<SystemStartButton> createState() => _SystemStartButtonState();
}

class _SystemStartButtonState extends State<SystemStartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        final glowAlpha = 0.35 + 0.35 * _glow.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusFull,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(
                  alpha: glowAlpha,
                ),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Material(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.radiusFull,
        child: InkWell(
          borderRadius: AppRadius.radiusFull,
          onTap: widget.onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SYSTEM START',
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.rocket_launch_rounded,
                  size: 16.r,
                  color: AppColors.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
