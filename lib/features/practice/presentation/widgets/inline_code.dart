import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

/// Parses `code`-delimited segments out of [source] into a mix of plain
/// [TextSpan]s (styled with [baseStyle]) and small pill [WidgetSpan]s
/// (styled with [codeStyle]) — the inline code chips seen throughout the
/// question and answer text.
List<InlineSpan> parseInlineCode(
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
