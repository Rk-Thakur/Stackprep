import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// The terminal-style boot log: three lines that type themselves out in
/// sequence, the last one landing in amber with a blinking cursor.
class BootTerminal extends StatelessWidget {
  const BootTerminal({super.key, required this.progress});

  /// 0..1 across the whole boot sequence (not looping).
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.r,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _BootLine(
            text: '> Initializing kernel...',
            reveal: _stage(progress, 0.10, 0.40),
            color: AppColors.onSurfaceVariant,
          ),
          SizedBox(height: 4.r),
          _BootLine(
            text: '> Loading modules...',
            reveal: _stage(progress, 0.40, 0.70),
            color: AppColors.onSurfaceVariant,
          ),
          SizedBox(height: 4.r),
          _BootLine(
            text: '> Status: READY',
            reveal: _stage(progress, 0.70, 1.0),
            color: AppColors.primaryContainer,
            bold: true,
            showCursorWhenDone: true,
          ),
        ],
      ),
    );
  }

  double _stage(double t, double start, double end) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    return (t - start) / (end - start);
  }
}

class _BootLine extends StatelessWidget {
  const _BootLine({
    required this.text,
    required this.reveal,
    required this.color,
    this.bold = false,
    this.showCursorWhenDone = false,
  });

  final String text;
  final double reveal;
  final Color color;
  final bool bold;
  final bool showCursorWhenDone;

  @override
  Widget build(BuildContext context) {
    final visibleChars = (text.length * reveal).round();
    final visible = text.substring(0, visibleChars);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          visible,
          style: AppTypography.codeSm.copyWith(
            color: color,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        if (showCursorWhenDone && reveal >= 1) _BlinkingCursor(color: color),
      ],
    );
  }
}

/// A self-contained blinking caret — runs its own ticker so the parent
/// doesn't need to manage a second AnimationController just for this.
class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor({required this.color});

  final Color color;

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 7.r,
        height: 14.r,
        margin: EdgeInsets.only(left: 4.r),
        color: widget.color,
      ),
    );
  }
}
