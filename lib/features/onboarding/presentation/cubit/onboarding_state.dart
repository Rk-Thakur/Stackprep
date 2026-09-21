import 'package:equatable/equatable.dart';

import '../../domain/entities/onboarding_summary.dart';
import '../../domain/entities/runtime_level.dart';
import '../../domain/entities/stack_track.dart';

enum OnboardingStatus { initial, ready }

class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.tracks = const [],
    this.levels = const [],
    this.selectedTrackIds = const {},
    this.selectedLevelId = 'mid',
    this.summary,
    this.errorMessage,
  });

  final OnboardingStatus status;
  final List<StackTrack> tracks;
  final List<RuntimeLevel> levels;
  final Set<String> selectedTrackIds;
  final String selectedLevelId;

  /// Set once [OnboardingCubit.submit] succeeds.
  final OnboardingSummary? summary;
  final String? errorMessage;

  bool get canContinue => selectedTrackIds.isNotEmpty;

  OnboardingState copyWith({
    OnboardingStatus? status,
    List<StackTrack>? tracks,
    List<RuntimeLevel>? levels,
    Set<String>? selectedTrackIds,
    String? selectedLevelId,
    OnboardingSummary? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      levels: levels ?? this.levels,
      selectedTrackIds: selectedTrackIds ?? this.selectedTrackIds,
      selectedLevelId: selectedLevelId ?? this.selectedLevelId,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    tracks,
    levels,
    selectedTrackIds,
    selectedLevelId,
    summary,
    errorMessage,
  ];
}
