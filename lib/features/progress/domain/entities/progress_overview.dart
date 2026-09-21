import 'package:equatable/equatable.dart';

import 'focus_area.dart';
import 'readiness_summary.dart';
import 'track_competency.dart';

/// Everything the progress tab renders in one payload.
class ProgressOverview extends Equatable {
  const ProgressOverview({
    required this.summary,
    required this.competencies,
    required this.focusAreas,
  });

  final ReadinessSummary summary;
  final List<TrackCompetency> competencies;
  final List<FocusArea> focusAreas;

  @override
  List<Object?> get props => [summary, competencies, focusAreas];
}
