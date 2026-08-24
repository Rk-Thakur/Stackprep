import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Shape language used to identify tech tracks (see DESIGN.md "Shapes").
enum TrackShapeType { diamond, circle, roundedSquare, hexagon }

/// A neutral rounded-square avatar containing a track's identifying shape,
/// filled with the track's solid color or gradient.
class TrackIcon extends StatelessWidget {
  const TrackIcon({
    super.key,
    required this.shape,
    required this.color,
    this.gradient,
    this.size,
  });

  final TrackShapeType shape;
  final Color color;
  final Gradient? gradient;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final resolvedSize = size ?? 56.r;
    return Container(
      width: resolvedSize,
      height: resolvedSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: AppRadius.radiusMd,
      ),
      child: _shape(resolvedSize * 0.5),
    );
  }

  Widget _shape(double shapeSize) {
    switch (shape) {
      case TrackShapeType.circle:
        return Container(
          width: shapeSize,
          height: shapeSize,
          decoration: BoxDecoration(
            color: gradient == null ? color : null,
            gradient: gradient,
            shape: BoxShape.circle,
          ),
        );
      case TrackShapeType.roundedSquare:
        return Container(
          width: shapeSize,
          height: shapeSize,
          decoration: BoxDecoration(
            color: gradient == null ? color : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(shapeSize * 0.3),
          ),
        );
      case TrackShapeType.diamond:
        return Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: shapeSize * 0.78,
            height: shapeSize * 0.78,
            decoration: BoxDecoration(
              color: gradient == null ? color : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(shapeSize * 0.16),
            ),
          ),
        );
      case TrackShapeType.hexagon:
        return ClipPath(
          clipper: _HexagonClipper(),
          child: Container(
            width: shapeSize,
            height: shapeSize,
            decoration: BoxDecoration(
              color: gradient == null ? color : null,
              gradient: gradient,
            ),
          ),
        );
    }
  }
}

class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _hexagonPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

Path _hexagonPath(Size size) {
  final w = size.width;
  final h = size.height;
  return Path()
    ..moveTo(w * 0.5, 0)
    ..lineTo(w, h * 0.25)
    ..lineTo(w, h * 0.75)
    ..lineTo(w * 0.5, h)
    ..lineTo(0, h * 0.75)
    ..lineTo(0, h * 0.25)
    ..close();
}

/// A faint, outlined version of a track's identifying [shape], meant to be
/// used as a decorative accent bleeding off a card corner (see the "Tracks"
/// list design).
class TrackShapeAccent extends StatelessWidget {
  const TrackShapeAccent({
    super.key,
    required this.shape,
    required this.color,
    this.size,
    this.opacity = 0.2,
    this.selected = false,
  });

  final TrackShapeType shape;
  final Color color;
  final double? size;
  final double opacity;

  /// When true, the outline lights up (brighter + glowing) instead of
  /// sitting faint in the corner.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final resolvedSize = size ?? 64.r;
    final outline = color.withValues(alpha: selected ? 0.9 : opacity);
    final strokeWidth = selected ? 2.0 : 1.5;

    final Widget shapeWidget;
    switch (shape) {
      case TrackShapeType.circle:
        shapeWidget = Container(
          width: resolvedSize,
          height: resolvedSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: outline, width: strokeWidth),
          ),
        );
      case TrackShapeType.roundedSquare:
        shapeWidget = Container(
          width: resolvedSize,
          height: resolvedSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(resolvedSize * 0.28),
            border: Border.all(color: outline, width: strokeWidth),
          ),
        );
      case TrackShapeType.diamond:
        shapeWidget = Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: resolvedSize * 0.78,
            height: resolvedSize * 0.78,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(resolvedSize * 0.14),
              border: Border.all(color: outline, width: strokeWidth),
            ),
          ),
        );
      case TrackShapeType.hexagon:
        shapeWidget = CustomPaint(
          size: Size(resolvedSize, resolvedSize),
          painter: _HexagonOutlinePainter(
            color: outline,
            strokeWidth: strokeWidth,
          ),
        );
    }

    if (!selected) return shapeWidget;
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.6),
            blurRadius: 20.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
      child: shapeWidget,
    );
  }
}

class _HexagonOutlinePainter extends CustomPainter {
  _HexagonOutlinePainter({required this.color, this.strokeWidth = 1.5});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawPath(_hexagonPath(size), paint);
  }

  @override
  bool shouldRepaint(covariant _HexagonOutlinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
