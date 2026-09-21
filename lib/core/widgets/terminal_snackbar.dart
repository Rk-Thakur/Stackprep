import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Severity of a [TerminalSnackbar] — drives its color, `[LABEL]` prefix,
/// and the accent used on its pulsing status bar.
enum SnackLevel { success, error, warning, info }

extension on SnackLevel {
  String get label => switch (this) {
    SnackLevel.success => 'SUCCESS',
    SnackLevel.error => 'ERROR',
    SnackLevel.warning => 'WARNING',
    SnackLevel.info => 'INFO',
  };

  Color get color => switch (this) {
    SnackLevel.success => AppColors.primaryFixedDim,
    SnackLevel.error => AppColors.errorRed,
    SnackLevel.warning => AppColors.warningOrange,
    SnackLevel.info => AppColors.infoBlue,
  };
}

/// "Obsidian Terminal" semantic snackbar: a bordered, terminal-styled toast
/// with a `[LEVEL] MESSAGE` line, a pulsing status bar, and an optional
/// mono action button (e.g. RETRY, SYNC, ACK).
class TerminalSnackbar {
  const TerminalSnackbar._();

  static void show(
    BuildContext context, {
    required SnackLevel level,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusBase),
          content: _TerminalSnackbarContent(
            level: level,
            message: message,
            actionLabel: actionLabel,
            onAction: onAction,
          ),
        ),
      );
  }
}

class _TerminalSnackbarContent extends StatefulWidget {
  const _TerminalSnackbarContent({
    required this.level,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final SnackLevel level;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<_TerminalSnackbarContent> createState() =>
      _TerminalSnackbarContentState();
}

class _TerminalSnackbarContentState extends State<_TerminalSnackbarContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.level.color;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: color),
        borderRadius: AppRadius.radiusBase,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.1),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.terminal_rounded, size: 18.r, color: color),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[${widget.level.label}] ${widget.message}',
                  style: AppTypography.labelMono.copyWith(color: color),
                ),
                SizedBox(height: 4.r),
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) => Container(
                    height: 2.r,
                    width: double.infinity,
                    color: color.withValues(
                      alpha: 0.1 + _pulse.value * 0.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.actionLabel != null) ...[
            SizedBox(width: AppSpacing.sm),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onAction,
                borderRadius: AppRadius.radiusSm,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 4.r,
                  ),
                  child: Text(
                    widget.actionLabel!,
                    style: AppTypography.labelMono.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
