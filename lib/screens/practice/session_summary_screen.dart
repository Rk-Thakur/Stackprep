import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'practice_session_screen.dart';

class _CategoryBreakdown {
  const _CategoryBreakdown({
    required this.title,
    required this.correct,
    required this.incorrect,
  });

  final String title;
  final int correct;
  final int incorrect;

  int get percent => ((correct / (correct + incorrect)) * 100).round();
}

const List<_CategoryBreakdown> _kBreakdown = [
  _CategoryBreakdown(title: 'Core Knowledge', correct: 17, incorrect: 3),
  _CategoryBreakdown(title: 'Logic Reasoning', correct: 12, incorrect: 8),
  _CategoryBreakdown(title: 'Practical Skills', correct: 20, incorrect: 0),
];

class _LogLine {
  const _LogLine(this.timestamp, this.event, this.status);

  final String timestamp;
  final String event;
  final String status;
}

const List<_LogLine> _kLogLines = [
  _LogLine('09:00:01', 'SESSION_START: ID_A841_X', ''),
  _LogLine('09:02:14', 'Q1_SUBMIT:', 'SUCCESS (244ms)'),
  _LogLine('09:05:48', 'Q2_SUBMIT:', 'SUCCESS (132ms)'),
  _LogLine('09:07:02', 'Q3_SUBMIT:', 'SUCCESS (198ms)'),
  _LogLine('09:09:15', 'Q4_SUBMIT:', 'SUCCESS (176ms)'),
  _LogLine('09:11:30', 'SESSION_END:', 'SUCCESS'),
];

/// Shown once a practice session finishes — the final score, a category
/// breakdown, and a terminal-style session log.
class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({
    super.key,
    required this.correctCount,
    required this.totalQuestions,
  });

  final int correctCount;
  final int totalQuestions;

  int get _percent =>
      totalQuestions == 0 ? 0 : ((correctCount / totalQuestions) * 100).round();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.md,
                  AppSpacing.margin,
                  AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40.r,
                        height: 4.r,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant,
                          borderRadius: AppRadius.radiusFull,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      'Session Summary',
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.primary,
                        fontSize: 20.sp,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: 168.r,
                      height: 168.r,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 168.r,
                            height: 168.r,
                            child: CircularProgressIndicator(
                              value: _percent / 100,
                              strokeWidth: 8,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                            ),
                          ),
                          Text(
                            '$_percent%',
                            style: AppTypography.headlineLg.copyWith(
                              color: AppColors.onSurface,
                              fontSize: 40.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Final Score',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Breakdown by Category',
                        style: AppTypography.headlineMd.copyWith(
                          color: AppColors.onSurface,
                          fontSize: 19.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    for (var i = 0; i < _kBreakdown.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == _kBreakdown.length - 1
                              ? 0
                              : AppSpacing.sm,
                        ),
                        child: _CategoryCard(breakdown: _kBreakdown[i]),
                      ),
                    SizedBox(height: AppSpacing.xl),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Session Logs',
                        style: AppTypography.headlineMd.copyWith(
                          color: AppColors.onSurface,
                          fontSize: 19.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    const _SessionLogBox(),
                  ],
                ),
              ),
            ),
            Container(height: 1, color: AppColors.outlineVariant),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.margin,
                AppSpacing.sm,
                AppSpacing.margin,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const PracticeSessionScreen(),
                        ),
                      ),
                      icon: Icon(Icons.refresh_rounded, size: 18.r),
                      label: const Text('Retry Session'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurface,
                        side: const BorderSide(
                          color: AppColors.outlineVariant,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.r),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusMd,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.check_circle_outline_rounded, size: 18.r),
                      label: const Text('Done'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.r),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusMd,
                        ),
                        textStyle: AppTypography.bodyLg.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.margin,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Icon(
                Icons.terminal_rounded,
                size: 16.r,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'ENGINEER_NOTEBOOK',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4.r,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Text(
                '[SYSTEM.STATUS: OK]',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.breakdown});

  final _CategoryBreakdown breakdown;

  static const int _goodThreshold = 70;

  @override
  Widget build(BuildContext context) {
    final isGood = breakdown.percent >= _goodThreshold;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Stack(
        children: [
          if (isGood)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4.r,
              child: const ColoredBox(color: AppColors.primary),
            ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        breakdown.title,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.r),
                      Text(
                        '${breakdown.correct} Correct / '
                        '${breakdown.incorrect} Incorrect',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${breakdown.percent}%',
                  style: AppTypography.numeralLg.copyWith(
                    color: isGood ? AppColors.primary : AppColors.error,
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionLogBox extends StatelessWidget {
  const _SessionLogBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.codeBlockBackground,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in _kLogLines)
            Padding(
              padding: EdgeInsets.only(bottom: 4.r),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '[${line.timestamp}] ',
                      style: AppTypography.codeSm.copyWith(
                        color: AppColors.codeLineNumber,
                        fontSize: 12.sp,
                      ),
                    ),
                    TextSpan(
                      text: '${line.event} ',
                      style: AppTypography.codeSm.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 12.sp,
                      ),
                    ),
                    if (line.status.isNotEmpty)
                      TextSpan(
                        text: line.status,
                        style: AppTypography.codeSm.copyWith(
                          color: AppColors.primary,
                          fontSize: 12.sp,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
