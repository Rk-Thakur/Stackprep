import 'package:equatable/equatable.dart';

/// Per-track competency score, joined against the track catalog by id.
class TrackCompetency extends Equatable {
  const TrackCompetency({
    required this.trackId,
    required this.score,
    required this.level,
  });

  final String trackId;

  /// 0–100.
  final int score;
  final String level;

  @override
  List<Object?> get props => [trackId, score, level];
}
