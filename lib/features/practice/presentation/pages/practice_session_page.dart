import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/code_block.dart';
import '../bloc/practice_session_bloc.dart';
import '../bloc/practice_session_event.dart';
import '../bloc/practice_session_state.dart';
import '../widgets/answer_option.dart';
import '../widgets/inline_code.dart';
import 'session_summary_page.dart';

/// A single practice question flow, reached via "Start Practice" from a
/// topic detail page, a module's "Take Quiz", or the daily challenge.
class PracticeSessionPage extends StatelessWidget {
  const PracticeSessionPage({
    super.key,
    this.topicCode = '',
    this.moduleId,
    this.challenge = false,
  });

  final String topicCode;

  /// When set, the session uses only that module's questions (module quiz).
  final String? moduleId;

  /// When true, the session is the daily challenge and rolls into the
  /// 'challenge' activity channel once completed.
  final bool challenge;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PracticeSessionBloc>()
        ..add(
          PracticeSessionStarted(
            topicCode: topicCode,
            moduleId: moduleId,
            challenge: challenge,
          ),
        ),
      child: const _PracticeSessionView(),
    );
  }
}

class _PracticeSessionView extends StatefulWidget {
  const _PracticeSessionView();

  @override
  State<_PracticeSessionView> createState() => _PracticeSessionViewState();
}

class _PracticeSessionViewState extends State<_PracticeSessionView> {
  void _comingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature coming soon.')));
  }

  void _onPrimaryAction(PracticeSessionState state) {
    final bloc = context.read<PracticeSessionBloc>();
    if (!state.checked) {
      bloc.add(const PracticeAnswerChecked());
      return;
    }
    bloc.add(const PracticeNextRequested());
  }

  void _onSkip(PracticeSessionState state) {
    context.read<PracticeSessionBloc>().add(const PracticeQuestionSkipped());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PracticeSessionBloc, PracticeSessionState>(
      listenWhen: (previous, current) =>
          previous.completed != current.completed ||
          previous.status != current.status,
      listener: (context, state) {
        if (state.completed) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => SessionSummaryPage(
                correctCount: state.correctCount,
                totalQuestions: state.totalQuestions,
                results: state.results,
                topicCode: state.topicCode,
                moduleId: state.moduleId,
              ),
            ),
          );
          return;
        }
        if (state.status == PracticeSessionStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final question = state.currentQuestion;
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: state.progress,
                  minHeight: 4.r,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
                AppTopBar(
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 6.r,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: AppRadius.radiusFull,
                          border: Border.all(
                            color: AppColors.outlineVariant,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '[SYSTEM_STATUS: '
                                '${(state.progress * 100).round()}%]',
                                style: AppTypography.labelMono.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10.sp,
                                ),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                state.topicCode,
                                style: AppTypography.labelMono.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _comingSoon('More options'),
                        borderRadius: AppRadius.radiusFull,
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: Icon(
                            Icons.more_vert_rounded,
                            size: 22.r,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: switch (state.status) {
                    PracticeSessionStatus.loading =>
                      const _PracticeQuestionSkeleton(),
                    PracticeSessionStatus.failure => Center(
                      child: Text(
                        state.errorMessage ?? 'Something went wrong.',
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    _ => SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.margin,
                          AppSpacing.sm,
                          AppSpacing.margin,
                          AppSpacing.lg,
                        ),
                        child: Column(
                          key: ValueKey(state.currentIndex),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (question != null) ...[
                              Text(
                                '[LOG_ID: ${question.refId}]',
                                style: AppTypography.labelMono.copyWith(
                                  color: AppColors.outline,
                                  fontSize: 11.sp,
                                ),
                              ),
                              SizedBox(height: AppSpacing.sm),
                              Text.rich(
                                TextSpan(
                                  children: parseInlineCode(
                                    question.question,
                                    AppTypography.headlineMd.copyWith(
                                      color: AppColors.onSurface,
                                      fontSize: 22.sp,
                                      height: 1.3,
                                    ),
                                    AppTypography.codeSm.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ),
                              ),
                              if (question.codeSnippet != null) ...[
                                SizedBox(height: AppSpacing.md),
                                CodeBlock(
                                  header: question.codeSnippet!.header,
                                  language: question.codeSnippet!.language,
                                  lines: question.codeSnippet!.lines,
                                ),
                              ],
                              SizedBox(height: AppSpacing.md),
                              for (var i = 0;
                                  i < question.options.length;
                                  i++)
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        i == question.options.length - 1
                                            ? 0
                                            : AppSpacing.sm,
                                  ),
                                  child: AnswerOption(
                                    letter: String.fromCharCode(65 + i),
                                    text: question.options[i],
                                    selected: state.selectedIndex == i,
                                    checked: state.checked,
                                    isCorrect: i == question.correctIndex,
                                    onTap: () => context
                                        .read<PracticeSessionBloc>()
                                        .add(PracticeAnswerSelected(i)),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                  },
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
                        child: OutlinedButton(
                          onPressed: state.checked ? null : () => _onSkip(state),
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
                          child: const Text('Skip'),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: state.selectedIndex == null && !state.checked
                              ? null
                              : () => _onPrimaryAction(state),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.r),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.radiusMd,
                            ),
                            textStyle: AppTypography.bodyLg.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: Text(
                            !state.checked
                                ? 'Check Answer'
                                : (state.isLastQuestion
                                      ? 'Finish'
                                      : 'Next Question'),
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
      },
    );
  }
}

/// Shimmering placeholder matching the question view's layout while
/// questions are still loading.
class _PracticeQuestionSkeleton extends StatelessWidget {
  const _PracticeQuestionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.margin,
          AppSpacing.sm,
          AppSpacing.margin,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '[LOG_ID: PLACEHOLDER]',
              style: AppTypography.labelMono.copyWith(
                color: AppColors.outline,
                fontSize: 11.sp,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'A placeholder question spanning a couple of lines while '
              'real content loads.',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 22.sp,
                height: 1.3,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            for (var i = 0; i < 4; i++)
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: AppRadius.radiusMd,
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
