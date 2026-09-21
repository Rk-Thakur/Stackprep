import 'package:equatable/equatable.dart';

import 'runtime_level.dart';
import 'stack_track.dart';

/// Everything the onboarding recap screen needs after configuration is
/// saved: the resolved tracks plus the chosen runtime level.
class OnboardingSummary extends Equatable {
  const OnboardingSummary({
    required this.selectedTracks,
    required this.runtimeLevel,
  });

  final List<StackTrack> selectedTracks;
  final RuntimeLevel runtimeLevel;

  @override
  List<Object?> get props => [selectedTracks, runtimeLevel];
}
