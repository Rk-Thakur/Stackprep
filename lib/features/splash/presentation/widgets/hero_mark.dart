import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A point in 3D space, used only for the hand-rolled wireframe projection
/// below — no 3D engine dependency, just enough linear algebra for a
/// convincing rotating-octahedron effect.
class _Vec3 {
  const _Vec3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;
}

/// The animated hero mark: a glowing halo behind a rotating wireframe
/// octahedron, tumbling orbital rings, and drifting particles — a native
/// re-interpretation of the reference's Three.js scene.
class HeroMark extends StatelessWidget {
  const HeroMark({super.key, required this.progress, this.size = 240});

  /// 0..1, looping continuously.
  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final pulse = 1 + 0.06 * sin(progress * 2 * pi * 1.4);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: pulse,
            child: Container(
              width: size * 0.56,
              height: size * 0.56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.4),
                    blurRadius: 70,
                    spreadRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          CustomPaint(
            size: Size(size, size),
            painter: _HeroMarkPainter(progress),
          ),
        ],
      ),
    );
  }
}

class _HeroMarkPainter extends CustomPainter {
  _HeroMarkPainter(this.t);

  final double t;

  static const List<_Vec3> _vertices = [
    _Vec3(1, 0, 0),
    _Vec3(-1, 0, 0),
    _Vec3(0, 1, 0),
    _Vec3(0, -1, 0),
    _Vec3(0, 0, 1),
    _Vec3(0, 0, -1),
  ];

  // Every pair of vertices not sharing an axis — the octahedron's 12 edges.
  static const List<List<int>> _edges = [
    [0, 2], [0, 3], [0, 4], [0, 5],
    [1, 2], [1, 3], [1, 4], [1, 5],
    [2, 4], [2, 5], [3, 4], [3, 5],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final baseRadius = size.shortestSide * 0.3;

    _paintOrbitalRings(canvas, center, baseRadius);
    _paintParticles(canvas, center, baseRadius);
    _paintWireframe(canvas, center, baseRadius);
    _paintCore(canvas, center);
  }

  void _paintOrbitalRings(Canvas canvas, Offset center, double baseRadius) {
    for (var i = 0; i < 3; i++) {
      final speed = 0.15 + i * 0.07;
      final phase = i * 2.1;
      final angle = t * 2 * pi * speed + phase;
      final squash = 0.28 + 0.18 * sin(t * 2 * pi * (0.2 + i * 0.05) + phase);
      final ringRadius = baseRadius * (1.35 + i * 0.22);
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.primaryContainer.withValues(alpha: 0.35 - i * 0.08);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.scale(1.0, squash);
      canvas.drawCircle(Offset.zero, ringRadius, ringPaint);
      canvas.restore();
    }
  }

  void _paintParticles(Canvas canvas, Offset center, double baseRadius) {
    final particlePaint = Paint();
    for (var i = 0; i < 14; i++) {
      final seedAngle = i * 0.45;
      final speed = 0.08 + (i % 5) * 0.02;
      final radius = baseRadius * (1.1 + (i % 4) * 0.25);
      final angle = t * 2 * pi * speed + seedAngle;
      final px = center.dx + cos(angle) * radius;
      final py = center.dy + sin(angle) * radius * 0.55;
      final twinkle =
          0.3 + 0.5 * ((sin(t * 2 * pi * (1 + i * 0.1) + seedAngle) + 1) / 2);
      particlePaint.color = AppColors.primaryContainer.withValues(
        alpha: twinkle,
      );
      canvas.drawCircle(Offset(px, py), 1.6, particlePaint);
    }
  }

  void _paintWireframe(Canvas canvas, Offset center, double baseRadius) {
    final angleY = t * 2 * pi;
    final angleX = 0.5 + sin(t * 2 * pi * 0.6) * 0.35;
    const focal = 3.2;

    final projected = <Offset>[];
    for (final v in _vertices) {
      final rotated = _rotateX(_rotateY(v, angleY), angleX);
      final scale = focal / (focal + rotated.z);
      projected.add(
        Offset(
          center.dx + rotated.x * baseRadius * scale,
          center.dy + rotated.y * baseRadius * scale,
        ),
      );
    }

    final wirePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.primaryContainer.withValues(alpha: 0.85);
    for (final edge in _edges) {
      canvas.drawLine(projected[edge[0]], projected[edge[1]], wirePaint);
    }
  }

  void _paintCore(Canvas canvas, Offset center) {
    final pulse = 1 + 0.15 * sin(t * 2 * pi * 2.5);
    canvas.drawCircle(
      center,
      6 * pulse,
      Paint()..color = AppColors.primaryContainer,
    );
  }

  _Vec3 _rotateY(_Vec3 p, double a) {
    final c = cos(a), s = sin(a);
    return _Vec3(p.x * c + p.z * s, p.y, -p.x * s + p.z * c);
  }

  _Vec3 _rotateX(_Vec3 p, double a) {
    final c = cos(a), s = sin(a);
    return _Vec3(p.x, p.y * c - p.z * s, p.y * s + p.z * c);
  }

  @override
  bool shouldRepaint(covariant _HeroMarkPainter oldDelegate) =>
      oldDelegate.t != t;
}
