import 'package:flutter/material.dart';

import '../widgets/track_icon.dart';

/// A selectable mobile-development track (e.g. Kotlin, Swift).
class StackTrack {
  const StackTrack({
    required this.id,
    required this.name,
    required this.category,
    required this.shape,
    required this.color,
    this.gradient,
  });

  final String id;
  final String name;
  final String category;
  final TrackShapeType shape;
  final Color color;
  final Gradient? gradient;
}
