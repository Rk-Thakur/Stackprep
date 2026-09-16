import 'package:flutter/material.dart';

import '../../../core/widgets/track_icon.dart';
import '../domain/entities/stack_track.dart';

const kStackTracks = <StackTrack>[
  StackTrack(
    id: 'KOTLIN',
    name: 'Kotlin',
    category: 'ANDROID',
    shape: TrackShapeType.diamond,
    color: Color(0xFF8B5CF6),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8B5CF6), Color(0xFFFF7A59)],
    ),
  ),
  StackTrack(
    id: 'SWIFT',
    name: 'Swift',
    category: 'IOS',
    shape: TrackShapeType.circle,
    color: Color(0xFFF14C33),
  ),
  StackTrack(
    id: 'FLUTTER',
    name: 'Flutter',
    category: 'CROSS-PLATFORM',
    shape: TrackShapeType.roundedSquare,
    color: Color(0xFF2F6FED),
  ),
  StackTrack(
    id: 'REACT_NATIVE',
    name: 'React Native',
    category: 'CROSS-PLATFORM',
    shape: TrackShapeType.hexagon,
    color: Color(0xFF61DAFB),
  ),
];
