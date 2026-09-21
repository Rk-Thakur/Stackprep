import 'package:equatable/equatable.dart';

/// Per-track competency score, joined against the track catalog by id.
class TrackCompetency extends Equatable {
  const TrackCompetency({
    required this.trackId,
    required this.score,
    required this.level,
    this.modulesCompleted = 0,
    this.modulesTotal = 0,
  });

  final String trackId;

  /// 0–100.
  final int score;
  final String level;

  /// How many of the track's modules the user has opened, and how many
  /// exist in the catalog. `modulesTotal == 0` means unknown (not fetched).
  final int modulesCompleted;
  final int modulesTotal;

  @override
  List<Object?> get props => [
    trackId,
    score,
    level,
    modulesCompleted,
    modulesTotal,
  ];
}
