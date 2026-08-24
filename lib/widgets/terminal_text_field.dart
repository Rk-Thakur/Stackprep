import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// A dark, monospaced input field styled for the terminal-themed auth screen.
class TerminalTextField extends StatelessWidget {
  const TerminalTextField({
    super.key,
    required this.controller,
    required this.icon,
    this.obscureText = false,
    this.hintText,
    this.keyboardType,
    this.enabled = true,
  });

  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.elevationLevel0,
        borderRadius: AppRadius.radiusBase,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        keyboardType: keyboardType,
        style: AppTypography.codeSm.copyWith(color: AppColors.onSurface),
        cursorColor: AppColors.primaryContainer,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18.r, color: AppColors.onSurfaceVariant),
          hintText: hintText,
          hintStyle: AppTypography.codeSm.copyWith(color: AppColors.outline),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 16.r),
        ),
      ),
    );
  }
}
