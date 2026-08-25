import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'inline_code.dart';

/// A single multiple-choice option with letter badge and correct/wrong
/// feedback states once the answer has been checked.
class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.letter,
    required this.text,
    required this.selected,
    required this.checked,
    required this.isCorrect,
    required this.onTap,
  });

  final String letter;
  final String text;
  final bool selected;
  final bool checked;
  final bool isCorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final showCorrect = checked && isCorrect;
    final showWrong = checked && selected && !isCorrect;

    final accentColor = showCorrect
        ? AppColors.primary
        : showWrong
        ? AppColors.error
        : (selected ? AppColors.primary : AppColors.outlineVariant);
    final badgeColor = showCorrect
        ? AppColors.primary
        : showWrong
        ? AppColors.error
        : (selected ? AppColors.primary : AppColors.surfaceContainerHigh);
    final badgeTextColor = (showCorrect || showWrong || selected)
        ? AppColors.onPrimary
        : AppColors.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusLg,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(
            color: accentColor,
            width: (selected || showCorrect || showWrong) ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26.r,
              height: 26.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: AppRadius.radiusSm,
              ),
              child: Text(
                letter,
                style: AppTypography.labelMono.copyWith(
                  color: badgeTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: parseInlineCode(
                    text,
                    AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurface,
                      height: 1.4,
                    ),
                    AppTypography.codeSm.copyWith(
                      color: AppColors.primary,
                      fontSize: 13.sp,
                    ),
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
