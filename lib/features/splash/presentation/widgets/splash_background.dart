import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A technical-feeling ambient backdrop: a faint amber dot grid, a slow
/// scanline sweep, and a vignette — a native re-interpretation of the
/// reference's WebGL shader.
class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key, required this.progress});

  /// 0..1, looping continuously.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SplashBackgroundPainter(progress));
  }
}

class _SplashBackgroundPainter extends CustomPainter {
  _SplashBackgroundPainter(this.t);

  final double t;

  static const double _spacing = 26;

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = AppColors.primaryContainer.withValues(alpha: 0.06);
    for (double y = 0; y < size.height; y += _spacing) {
      for (double x = 0; x < size.width; x += _spacing) {
        canvas.drawCircle(Offset(x, y), 1.1, dotPaint);
      }
    }

    const bandHeight = 140.0;
    final sweepY = size.height * t;
    final sweepPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primaryContainer.withValues(alpha: 0),
          AppColors.primaryContainer.withValues(alpha: 0.05),
          AppColors.primaryContainer.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromLTWH(0, sweepY - bandHeight / 2, size.width, bandHeight),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, sweepY - bandHeight / 2, size.width, bandHeight),
      sweepPaint,
    );

    final vignettePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          AppColors.surface.withValues(alpha: 0.9),
        ],
        stops: const [0.45, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignettePaint);
  }

  @override
  bool shouldRepaint(covariant _SplashBackgroundPainter oldDelegate) =>
      oldDelegate.t != t;
}
