import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../bloc/practice_session_state.dart';
import 'practice_session_page.dart';

class _CategoryBreakdown {
  const _CategoryBreakdown({
    required this.title,
    required this.correct,
    required this.incorrect,
  });

  final String title;
  final int correct;
  final int incorrect;

  int get percent {
    final total = correct + incorrect;
    return total == 0 ? 0 : ((correct / total) * 100).round();
  }
}

class _LogLine {
  const _LogLine(this.event, this.status);

  final String event;
  final String status;
}

/// Shown once a practice session finishes — the final score, a breakdown of
/// how each question went, and a terminal-style session log.
class SessionSummaryPage extends StatelessWidget {
  const SessionSummaryPage({
    super.key,
    required this.correctCount,
    required this.totalQuestions,
    this.results = const [],
    this.topicCode = '',
    this.moduleId,
  });

  final int correctCount;
  final int totalQuestions;
  final List<QuestionResult> results;
  final String topicCode;
  final String? moduleId;

  int get _percent =>
      totalQuestions == 0 ? 0 : ((correctCount / totalQuestions) * 100).round();

  /// Real breakdown derived from the session. Each row is independent:
  /// "Correct" shows the share of answered questions that were right;
  /// "Missed" shows the opposite; "Skipped" appears only when some
  /// questions were left unanswered.
  List<_CategoryBreakdown> get _breakdown {
    final answered = results.length;
    final incorrect = answered - correctCount;
    final skipped = totalQuestions - answered;
    return [
      _CategoryBreakdown(
        title: 'Correct',
        correct: correctCount,
        incorrect: incorrect + skipped,
      ),
      _CategoryBreakdown(
        title: 'Missed',
        correct: incorrect,
        incorrect: correctCount + skipped,
      ),
      if (skipped > 0)
        _CategoryBreakdown(
          title: 'Skipped',
          correct: skipped,
          incorrect: answered,
        ),
    ];
  }

  List<_LogLine> get _logLines {
    final lines = <_LogLine>[
      _LogLine(
        'SESSION_START: ${topicCode.isEmpty ? 'TRACK' : topicCode}',
        'OK',
      ),
    ];
    for (var i = 0; i < results.length; i++) {
      final q = results[i];
      lines.add(
        _LogLine(
          'Q${i + 1}_SUBMIT: ${q.refId}',
          q.correct ? 'CORRECT' : 'WRONG',
        ),
      );
    }
    if (results.length < totalQuestions) {
      lines.add(
        _LogLine('Q_SKIPPED:', '${totalQuestions - results.length}'),
      );
    }
    lines.add(_LogLine('SESSION_END: ${'$_percent%'}', 'SUCCESS'));
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              trailing: Container(
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
            ),
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
                        'Breakdown',
                        style: AppTypography.headlineMd.copyWith(
                          color: AppColors.onSurface,
                          fontSize: 19.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    for (var i = 0; i < _breakdown.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == _breakdown.length - 1
                              ? 0
                              : AppSpacing.sm,
                        ),
                        child: _CategoryCard(breakdown: _breakdown[i]),
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
                    _SessionLogBox(lines: _logLines),
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
                          builder: (_) => PracticeSessionPage(
                            topicCode: topicCode,
                            moduleId: moduleId,
                          ),
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
  const _SessionLogBox({required this.lines});

  final List<_LogLine> lines;

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
          for (final line in lines)
            Padding(
              padding: EdgeInsets.only(bottom: 4.r),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${line.event} ',
                      style: AppTypography.codeSm.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 12.sp,
                      ),
                    ),
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
