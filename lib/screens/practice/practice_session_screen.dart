import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'session_summary_screen.dart';

class _CodeSnippet {
  const _CodeSnippet({
    required this.header,
    required this.language,
    required this.lines,
  });

  final String header;
  final String language;
  final List<String> lines;
}

class _PracticeQuestion {
  const _PracticeQuestion({
    required this.refId,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.code,
  });

  final String refId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final _CodeSnippet? code;
}

const List<_PracticeQuestion> _kQuestions = [
  _PracticeQuestion(
    refId: 'MCQ_772',
    question:
        'What is the primary difference between `launch` and `async` in '
        'Kotlin coroutines?',
    code: _CodeSnippet(
      header: '[DATA_SYNC]',
      language: 'Kotlin',
      lines: [
        'fun main() = runBlocking {',
        '    val job = launch {',
        '        // Do some work',
        '    }',
        '',
        '    val deferred = async {',
        '        // Return a result',
        '        "Hello"',
        '    }',
        '}',
      ],
    ),
    options: [
      '`launch` creates a new thread, while `async` reuses the current '
          'thread.',
      '`launch` returns a `Deferred` and does not return a result, while '
          '`async` returns a `Deferred` which provides a future result.',
      '`launch` is used for suspend functions, while `async` is used for '
          'regular blocking functions.',
      '`launch` handles exceptions automatically, whereas exceptions in '
          '`async` will always crash the application immediately.',
    ],
    correctIndex: 1,
  ),
  _PracticeQuestion(
    refId: 'CNCR_03',
    question:
        'In the context of Structured Concurrency, which statement '
        'accurately describes the primary purpose of a coroutine scope?',
    options: [
      'It executes tasks in parallel across multiple physical CPU threads '
          'to maximize performance.',
      'It defines the lifetime of new coroutines and guarantees that the '
          'scope will not complete until all its child coroutines have '
          'completed.',
      'It acts as an isolated sandbox that prevents child coroutines from '
          'accessing shared mutable state.',
      'It automatically cancels parent coroutines if any child coroutine '
          'encounters a minor exception during execution.',
    ],
    correctIndex: 1,
  ),
  _PracticeQuestion(
    refId: 'DISP_04',
    question:
        'Which dispatcher should be used for CPU-intensive work, such as '
        'sorting a large in-memory list?',
    options: [
      '`Dispatchers.Main`',
      '`Dispatchers.IO`',
      '`Dispatchers.Default`',
      '`Dispatchers.Unconfined`',
    ],
    correctIndex: 2,
  ),
  _PracticeQuestion(
    refId: 'EXC_05',
    question: 'What is the purpose of a `SupervisorJob` in a coroutine scope?',
    code: _CodeSnippet(
      header: '[DATA_SYNC]',
      language: 'Kotlin',
      lines: [
        'val scope = CoroutineScope(SupervisorJob())',
        '',
        'scope.launch {',
        '    // A failure here will not cancel',
        '    // the sibling coroutine below.',
        '}',
      ],
    ),
    options: [
      'It prevents any coroutine in the scope from ever being cancelled.',
      'A failure in one child coroutine does not cancel its siblings, '
          'unlike a regular `Job`.',
      'It merges all child coroutines onto a single background thread.',
      'It automatically retries a failed coroutine up to three times.',
    ],
    correctIndex: 1,
  ),
  _PracticeQuestion(
    refId: 'FLOW_06',
    question:
        'Which builder creates a cold, asynchronous stream that only starts '
        'producing values once it is collected?',
    options: ['`Flow`', '`Channel`', '`LiveData`', '`Sequence`'],
    correctIndex: 0,
  ),
];

/// A single practice question flow, reached via "Start Practice" from a
/// topic detail screen.
class PracticeSessionScreen extends StatefulWidget {
  const PracticeSessionScreen({super.key, this.topicCode = 'KTN_COROUTINES'});

  final String topicCode;

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  int _questionIndex = 0;
  int? _selectedIndex;
  bool _checked = false;
  int _correctCount = 0;

  _PracticeQuestion get _question => _kQuestions[_questionIndex];
  bool get _isLast => _questionIndex == _kQuestions.length - 1;
  int get _percent =>
      (((_questionIndex + 1) / _kQuestions.length) * 100).round();

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature coming soon.')));
  }

  void _selectOption(int index) {
    if (_checked) return;
    setState(() => _selectedIndex = index);
  }

  void _finishSession() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SessionSummaryScreen(
          correctCount: _correctCount,
          totalQuestions: _kQuestions.length,
        ),
      ),
    );
  }

  void _onPrimaryAction() {
    if (!_checked) {
      if (_selectedIndex == _question.correctIndex) _correctCount++;
      setState(() => _checked = true);
      return;
    }
    if (_isLast) {
      _finishSession();
      return;
    }
    setState(() {
      _questionIndex++;
      _selectedIndex = null;
      _checked = false;
    });
  }

  void _skip() {
    if (_isLast) {
      _finishSession();
      return;
    }
    setState(() {
      _questionIndex++;
      _selectedIndex = null;
      _checked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _question;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_questionIndex + 1) / _kQuestions.length,
              minHeight: 4.r,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.margin,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: AppRadius.radiusFull,
                    child: Padding(
                      padding: EdgeInsets.all(4.r),
                      child: Icon(
                        Icons.close_rounded,
                        size: 22.r,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 6.r,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: AppRadius.radiusFull,
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '[SYSTEM_STATUS: $_percent%]',
                                style: AppTypography.labelMono.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10.sp,
                                ),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                widget.topicCode,
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
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.sm,
                  AppSpacing.margin,
                  AppSpacing.lg,
                ),
                child: Column(
                  key: ValueKey(_questionIndex),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        children: _parseInlineCode(
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
                    if (question.code != null) ...[
                      SizedBox(height: AppSpacing.md),
                      _CodeBlock(snippet: question.code!),
                    ],
                    SizedBox(height: AppSpacing.md),
                    for (var i = 0; i < question.options.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == question.options.length - 1
                              ? 0
                              : AppSpacing.sm,
                        ),
                        child: _AnswerOption(
                          letter: String.fromCharCode(65 + i),
                          text: question.options[i],
                          selected: _selectedIndex == i,
                          checked: _checked,
                          isCorrect: i == question.correctIndex,
                          onTap: () => _selectOption(i),
                        ),
                      ),
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
                    child: OutlinedButton(
                      onPressed: _checked ? null : _skip,
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
                      onPressed: _selectedIndex == null && !_checked
                          ? null
                          : _onPrimaryAction,
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
                        !_checked
                            ? 'Check Answer'
                            : (_isLast ? 'Finish' : 'Next Question'),
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

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.snippet});

  final _CodeSnippet snippet;

  static const Set<String> _kKeywords = {
    'fun',
    'val',
    'var',
    'return',
    'if',
    'else',
    'for',
    'while',
    'class',
    'object',
    'suspend',
    'launch',
    'async',
    'runBlocking',
    'coroutineScope',
    'supervisorScope',
    'CoroutineScope',
    'SupervisorJob',
  };

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: snippet.lines.join('\n')));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard.')));
  }

  List<InlineSpan> _highlightLine(String line) {
    final spans = <InlineSpan>[];
    final tokenPattern = RegExp(r'//.*$|"[^"]*"|\w+|[^\w\s]+|\s+');
    for (final match in tokenPattern.allMatches(line)) {
      final token = match.group(0)!;
      Color color;
      if (token.startsWith('//')) {
        color = AppColors.onSurfaceVariant;
      } else if (token.startsWith('"')) {
        color = AppColors.primary.withValues(alpha: 0.75);
      } else if (_kKeywords.contains(token)) {
        color = AppColors.primary;
      } else {
        color = AppColors.onSurface;
      }
      spans.add(
        TextSpan(
          text: token,
          style: AppTypography.codeSm.copyWith(color: color, fontSize: 13.sp),
        ),
      );
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.codeBlockBackground,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(
                  snippet.header,
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
                const Spacer(),
                Text(
                  snippet.language,
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                InkWell(
                  onTap: () => _copy(context),
                  borderRadius: AppRadius.radiusSm,
                  child: Icon(
                    Icons.copy_rounded,
                    size: 15.r,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.outlineVariant),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < snippet.lines.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.r),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20.r,
                          child: Text(
                            '${i + 1}',
                            style: AppTypography.codeSm.copyWith(
                              color: AppColors.codeLineNumber,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text.rich(
                            TextSpan(children: _highlightLine(snippet.lines[i])),
                          ),
                        ),
                      ],
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

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
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
                  children: _parseInlineCode(
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

/// Parses `code`-delimited segments out of [source] into a mix of plain
/// [TextSpan]s (styled with [baseStyle]) and small pill [WidgetSpan]s
/// (styled with [codeStyle]) — the inline code chips seen throughout the
/// question and answer text.
List<InlineSpan> _parseInlineCode(
  String source,
  TextStyle baseStyle,
  TextStyle codeStyle,
) {
  final spans = <InlineSpan>[];
  final pattern = RegExp('`([^`]+)`');
  var last = 0;
  for (final match in pattern.allMatches(source)) {
    if (match.start > last) {
      spans.add(
        TextSpan(text: source.substring(last, match.start), style: baseStyle),
      );
    }
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.r, vertical: 1.r),
          margin: EdgeInsets.symmetric(horizontal: 1.r),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: AppRadius.radiusSm,
          ),
          child: Text(match.group(1)!, style: codeStyle),
        ),
      ),
    );
    last = match.end;
  }
  if (last < source.length) {
    spans.add(TextSpan(text: source.substring(last), style: baseStyle));
  }
  return spans;
}
