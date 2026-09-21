import 'package:equatable/equatable.dart';

import '../../../onboarding/domain/entities/stack_track.dart';
import '../../domain/entities/focus_area.dart';
import '../../domain/entities/readiness_summary.dart';
import '../../domain/entities/track_competency.dart';

enum ProgressStatus { initial, loading, ready, failure }

class ProgressState extends Equatable {
  const ProgressState({
    this.status = ProgressStatus.initial,
    this.tracks = const [],
    this.summary,
    this.competencies = const [],
    this.focusAreas = const [],
    this.selectedTrackId,
    this.errorMessage,
  });

  final ProgressStatus status;

  /// Track catalog from the onboarding feature — drives the filter chips
  /// and the competency cards.
  final List<StackTrack> tracks;
  final ReadinessSummary? summary;
  final List<TrackCompetency> competencies;
  final List<FocusArea> focusAreas;

  /// Null means "All".
  final String? selectedTrackId;
  final String? errorMessage;

  List<TrackCompetency> get filteredCompetencies {
    final selected = selectedTrackId;
    if (selected == null) return competencies;
    return competencies.where((c) => c.trackId == selected).toList();
  }

  ProgressState copyWith({
    ProgressStatus? status,
    List<StackTrack>? tracks,
    ReadinessSummary? summary,
    List<TrackCompetency>? competencies,
    List<FocusArea>? focusAreas,
    String? selectedTrackId,
    bool clearSelectedTrack = false,
    String? errorMessage,
  }) {
    return ProgressState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      summary: summary ?? this.summary,
      competencies: competencies ?? this.competencies,
      focusAreas: focusAreas ?? this.focusAreas,
      selectedTrackId: clearSelectedTrack
          ? null
          : (selectedTrackId ?? this.selectedTrackId),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tracks,
    summary,
    competencies,
    focusAreas,
    selectedTrackId,
    errorMessage,
  ];
}
