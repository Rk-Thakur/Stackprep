import 'package:equatable/equatable.dart';

/// Headline stats for the Commitment Engine / System Mastery cards.
/// Scores are fractions between 0 and 1.
class ReadinessSummary extends Equatable {
  const ReadinessSummary({
    required this.currentStreakDays,
    required this.totalSessions,
    required this.readinessScore,
    required this.globalReadinessScore,
    required this.targetScore,
  });

  final int currentStreakDays;
  final int totalSessions;

  /// e.g. 0.87 renders as "87%".
  final double readinessScore;
  final double globalReadinessScore;
  final double targetScore;

  @override
  List<Object?> get props => [
    currentStreakDays,
    totalSessions,
    readinessScore,
    globalReadinessScore,
    targetScore,
  ];
}
