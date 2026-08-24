import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class _ConceptCardData {
  const _ConceptCardData({
    required this.icon,
    required this.codeTitle,
    required this.tag,
    required this.description,
    required this.footnote,
  });

  final IconData icon;
  final String codeTitle;
  final String tag;
  final String description;
  final String footnote;
}

const List<_ConceptCardData> _kConcepts = [
  _ConceptCardData(
    icon: Icons.rocket_launch_rounded,
    codeTitle: 'launch { ... }',
    tag: 'FIRE & FORGET',
    description:
        'Starts a new coroutine concurrently without blocking the current '
        'thread and returns a reference to the coroutine as a Job.',
    footnote: "Doesn't return a result",
  ),
  _ConceptCardData(
    icon: Icons.call_split_rounded,
    codeTitle: 'async { ... }',
    tag: 'RETURNS RESULT',
    description:
        'Creates a coroutine and returns its future result as an '
        'implementation of Deferred. You must call .await() to get the '
        'value.',
    footnote: 'Returns Deferred<T>',
  ),
];

const List<String> _kCodeLines = [
  'import kotlinx.coroutines.*',
  '',
  'fun main() = runBlocking { // this: CoroutineScope',
  '    launch { // launch a new coroutine and continue',
  '        delay(1000L) // non-blocking delay',
  '        println("World!")',
  '    }',
  '    println("Hello") // main coroutine continues here',
  '}',
];

/// Module/lesson detail screen, reached by tapping a sub-topic on a
/// topic detail screen (e.g. "Basics & Builders").
class ModuleDetailScreen extends StatelessWidget {
  const ModuleDetailScreen({super.key});

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onSave: () => _comingSoon(context, 'Save')),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.lg,
                  AppSpacing.margin,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 6.r,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.outlineVariant),
                            borderRadius: AppRadius.radiusFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.r,
                                height: 6.r,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                'KOTLIN COROUTINES',
                                style: AppTypography.labelMono.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14.r,
                          color: AppColors.onSurfaceVariant,
                        ),
                        SizedBox(width: 4.r),
                        Text(
                          '8 MIN READ',
                          style: AppTypography.labelMono.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Basics & Builders',
                      style: AppTypography.headlineLgResponsive(
                        context,
                      ).copyWith(color: AppColors.onSurface),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Master the fundamental building blocks of '
                      'asynchronous programming in Kotlin. Understand how '
                      'to launch concurrent tasks without blocking the '
                      'main thread.',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    for (var i = 0; i < _kConcepts.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == _kConcepts.length - 1
                              ? 0
                              : AppSpacing.md,
                        ),
                        child: _ConceptCard(data: _kConcepts[i]),
                      ),
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      'Implementation Example',
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 20.sp,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    const _CodeBlock(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.margin,
          vertical: AppSpacing.md,
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
                    color: AppColors.onSurface,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'BACK TO LIBRARY',
                    style: AppTypography.labelMono.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onSave,
              borderRadius: AppRadius.radiusSm,
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: Icon(
                  Icons.bookmark_rounded,
                  size: 22.r,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConceptCard extends StatelessWidget {
  const _ConceptCard({required this.data});

  final _ConceptCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.icon, size: 22.r, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
              Text(
                data.codeTitle,
                style: AppTypography.codeSm.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                ),
              ),
              const Spacer(),
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
                  data.tag,
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            data.description,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.68,
              child: Container(height: 1, color: AppColors.primary),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              data.footnote,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock();

  static const Set<String> _kKeywords = {
    'import',
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
    'delay',
    'println',
  };

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _kCodeLines.join('\n')));
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
                  'Kotlin',
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
                const Spacer(),
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
                for (final line in _kCodeLines)
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.r),
                    child: line.isEmpty
                        ? SizedBox(height: 16.r)
                        : Text.rich(TextSpan(children: _highlightLine(line))),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
