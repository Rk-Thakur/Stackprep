import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Terminal-style syntax-highlighted code sample: numbered lines, a header
/// row (label + language + copy button), and a keyword highlighter.
class CodeBlock extends StatelessWidget {
  const CodeBlock({
    super.key,
    required this.header,
    required this.language,
    required this.lines,
    this.keywords = defaultKotlinKeywords,
  });

  static const Set<String> defaultKotlinKeywords = {
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
    'coroutineScope',
    'supervisorScope',
    'CoroutineScope',
    'SupervisorJob',
    'delay',
    'println',
  };

  final String header;
  final String language;
  final List<String> lines;
  final Set<String> keywords;

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: lines.join('\n')));
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
      } else if (keywords.contains(token)) {
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
                  header,
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
                const Spacer(),
                Text(
                  language,
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
                for (var i = 0; i < lines.length; i++)
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
                            TextSpan(children: _highlightLine(lines[i])),
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
