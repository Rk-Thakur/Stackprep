import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class McqPage extends StatelessWidget {
  const McqPage({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context) {
    return const _McqView();
  }
}

class _McqView extends StatefulWidget {
  const _McqView();

  @override
  State<_McqView> createState() => _McqViewState();
}

class _McqViewState extends State<_McqView> {
  int _currentQuestion = 0;
  int? _selectedOption;
  bool _answered = false;
  int _correctCount = 0;

  final List<_McqQuestion> _questions = const [
    _McqQuestion(
      question: 'Which keyword is used to call a suspend function in Kotlin?',
      options: ['async', 'suspend', 'launch', 'runBlocking'],
      correctIndex: 2,
    ),
    _McqQuestion(
      question: 'What is the default dispatcher for UI-related work?',
      options: [
        'Dispatchers.IO',
        'Dispatchers.Default',
        'Dispatchers.Main',
        'Dispatchers.Unconfined',
      ],
      correctIndex: 2,
    ),
    _McqQuestion(
      question: 'Which construct provides structured concurrency?',
      options: [
        'GlobalScope.launch',
        'coroutineScope',
        'Thread',
        'Future',
      ],
      correctIndex: 1,
    ),
    _McqQuestion(
      question: 'What does "suspend" mean in Kotlin coroutines?',
      options: [
        'Runs on a background thread',
        'Can be paused and resumed',
        'Blocks the current thread',
        'Terminates the coroutine',
      ],
      correctIndex: 1,
    ),
    _McqQuestion(
      question: 'Which exception handler catches all child failures?',
      options: [
        'try-catch',
        'SupervisorJob',
        'runBlocking',
        'launch',
      ],
      correctIndex: 1,
    ),
  ];

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == _questions[_currentQuestion].correctIndex) {
        _correctCount++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    final percentage = (_correctCount / _questions.length * 100).round();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(AppSpacing.margin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppSpacing.md),
            Icon(
              _correctCount >= 4
                  ? Icons.emoji_events_rounded
                  : _correctCount >= 2
                      ? Icons.thumb_up_rounded
                      : Icons.refresh_rounded,
              size: 48.r,
              color: _correctCount >= 4
                  ? AppColors.primary
                  : _correctCount >= 2
                      ? Colors.amber
                      : AppColors.onSurfaceVariant,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              _correctCount >= 4
                  ? 'Great Job!'
                  : _correctCount >= 2
                      ? 'Good Effort!'
                      : 'Keep Practicing!',
              style: AppTypography.headlineLg.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              '$_correctCount / ${_questions.length} correct ($percentage%)',
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _currentQuestion = 0;
                    _selectedOption = null;
                    _answered = false;
                    _correctCount = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.r),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                ),
                child: Text(
                  'Retry',
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onSurface,
                  side: const BorderSide(color: AppColors.outlineVariant),
                  padding: EdgeInsets.symmetric(vertical: 14.r),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                ),
                child: Text(
                  'Back to Topic',
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.margin,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: AppRadius.radiusSm,
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_rounded,
                          size: 18.r,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Back',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_currentQuestion + 1}/${_questions.length}',
                    style: AppTypography.labelMono.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.margin),
              child: ClipRRect(
                borderRadius: AppRadius.radiusSm,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 4.r,
                ),
              ),
            ),
            // Question content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.margin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question number
                    Text(
                      'QUESTION ${_currentQuestion + 1}',
                      style: AppTypography.labelMono.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    // Question text
                    Text(
                      question.question,
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    // Options
                    for (var i = 0; i < question.options.length; i++)
                      Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _OptionTile(
                          label: String.fromCharCode(65 + i),
                          text: question.options[i],
                          isSelected: _selectedOption == i,
                          isCorrect: _answered && i == question.correctIndex,
                          isWrong: _answered &&
                              _selectedOption == i &&
                              i != question.correctIndex,
                          onTap: () => _selectOption(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Next / Finish button
            if (_answered)
              Padding(
                padding: EdgeInsets.all(AppSpacing.margin),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 14.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                    child: Text(
                      _currentQuestion < _questions.length - 1
                          ? 'Next Question'
                          : 'See Results',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
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

class _McqQuestion {
  const _McqQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color backgroundColor;

    if (isCorrect) {
      borderColor = Colors.green;
      backgroundColor = Colors.green.withValues(alpha: 0.1);
    } else if (isWrong) {
      borderColor = Colors.red;
      backgroundColor = Colors.red.withValues(alpha: 0.1);
    } else if (isSelected) {
      borderColor = AppColors.primary;
      backgroundColor = AppColors.primaryContainer;
    } else {
      borderColor = AppColors.outlineVariant;
      backgroundColor = AppColors.surfaceContainer;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusLg,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: isSelected || isCorrect || isWrong
                    ? borderColor
                    : AppColors.outlineVariant,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTypography.labelMono.copyWith(
                  color: isSelected || isCorrect || isWrong
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            if (isCorrect)
              Icon(Icons.check_circle_rounded, size: 20.r, color: Colors.green)
            else if (isWrong)
              Icon(Icons.cancel_rounded, size: 20.r, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
