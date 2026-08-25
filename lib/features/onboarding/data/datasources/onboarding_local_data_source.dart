import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/widgets/track_icon.dart';
import '../../domain/entities/onboarding_summary.dart';
import '../../domain/entities/runtime_level.dart';
import '../../domain/entities/stack_track.dart';

const _kOnboardingCompletedKey = 'onboarding_completed';
const _kSelectedTrackIdsKey = 'selected_track_ids';
const _kSelectedRuntimeLevelKey = 'selected_runtime_level';

/// The bundled catalogs of tracks and runtime levels, plus the in-memory
/// store for the completed onboarding selection and SharedPreferences-backed
/// persistence for the onboarding completion flag.
abstract interface class OnboardingLocalDataSource {
  List<StackTrack> get stackTracks;

  List<RuntimeLevel> get runtimeLevels;

  OnboardingSummary? get savedSummary;

  set savedSummary(OnboardingSummary? value);

  bool isOnboardingCompleted();

  Future<void> setOnboardingCompleted();

  List<String> get selectedTrackIds;

  String get selectedRuntimeLevel;

  Future<void> saveSelections({
    required List<String> trackIds,
    required String runtimeLevelId,
  });
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  OnboardingLocalDataSourceImpl({required SharedPreferences this._prefs});

  final SharedPreferences _prefs;

  static const List<StackTrack> _kStackTracks = [
    StackTrack(
      id: 'kotlin',
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
      id: 'swift',
      name: 'Swift',
      category: 'IOS',
      shape: TrackShapeType.circle,
      color: Color(0xFFF14C33),
    ),
    StackTrack(
      id: 'flutter',
      name: 'Flutter',
      category: 'CROSS-PLATFORM',
      shape: TrackShapeType.roundedSquare,
      color: Color(0xFF2F6FED),
    ),
    StackTrack(
      id: 'react_native',
      name: 'React Native',
      category: 'CROSS-PLATFORM',
      shape: TrackShapeType.hexagon,
      color: Color(0xFF61DAFB),
    ),
  ];

  static const List<RuntimeLevel> _kRuntimeLevels = [
    RuntimeLevel(
      id: 'junior',
      title: 'JUNIOR',
      description: 'Focus on syntax, basic components, and lifecycle management.',
      focus: 'Syntax & Lifecycle Fundamentals',
    ),
    RuntimeLevel(
      id: 'mid',
      title: 'MID-LEVEL',
      description:
          'Deep dive into state management, dependency injection, and '
          'performance.',
      focus: 'State Management & Performance',
    ),
    RuntimeLevel(
      id: 'senior',
      title: 'SENIOR',
      description:
          'Master concurrency, memory management, and system architecture.',
      focus: 'Advanced Architecture & Concurrency',
    ),
  ];

  @override
  List<StackTrack> get stackTracks => _kStackTracks;

  @override
  List<RuntimeLevel> get runtimeLevels => _kRuntimeLevels;

  @override
  OnboardingSummary? savedSummary;

  @override
  bool isOnboardingCompleted() => _prefs.getBool(_kOnboardingCompletedKey) ?? false;

  @override
  Future<void> setOnboardingCompleted() =>
      _prefs.setBool(_kOnboardingCompletedKey, true);

  @override
  List<String> get selectedTrackIds =>
      _prefs.getStringList(_kSelectedTrackIdsKey) ?? [];

  @override
  String get selectedRuntimeLevel =>
      _prefs.getString(_kSelectedRuntimeLevelKey) ?? 'mid';

  @override
  Future<void> saveSelections({
    required List<String> trackIds,
    required String runtimeLevelId,
  }) async {
    await _prefs.setStringList(_kSelectedTrackIdsKey, trackIds);
    await _prefs.setString(_kSelectedRuntimeLevelKey, runtimeLevelId);
  }
}
