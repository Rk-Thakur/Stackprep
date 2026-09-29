import 'package:equatable/equatable.dart';

/// A point-in-time snapshot of everything the export report shows.
///
/// Built by `ProgressReportBuilder` from the live progress overview and the
/// signed-in user, then rendered by the PDF generator. Kept free of Flutter
/// types so it stays trivially testable.
class ProgressReport extends Equatable {
  const ProgressReport({
    required this.generatedAt,
    this.userName,
    this.userEmail,
    required this.currentStreakDays,
    required this.totalSessions,
    required this.readinessScore,
    required this.globalReadinessScore,
    required this.targetScore,
    required this.activityLevels,
    required this.competencies,
    required this.focusAreas,
  });

  final DateTime generatedAt;
  final String? userName;
  final String? userEmail;
  final int currentStreakDays;
  final int totalSessions;

  /// Fractions between 0 and 1.
  final double readinessScore;
  final double globalReadinessScore;
  final double targetScore;

  /// One entry per day, oldest first, bucketed 0 (none) to 4 (most active).
  final List<int> activityLevels;

  final List<ReportCompetency> competencies;
  final List<ReportFocusArea> focusAreas;

  /// File name for the generated PDF, e.g. `stackprep-report-2026-09-28.pdf`.
  String get fileName {
    String two(int value) => value.toString().padLeft(2, '0');
    final d = generatedAt;
    return 'stackprep-report-${d.year}-${two(d.month)}-${two(d.day)}.pdf';
  }

  @override
  List<Object?> get props => [
    generatedAt,
    userName,
    userEmail,
    currentStreakDays,
    totalSessions,
    readinessScore,
    globalReadinessScore,
    targetScore,
    activityLevels,
    competencies,
    focusAreas,
  ];
}

/// One row of the competency table, with the track id already resolved to a
/// human name so the PDF does not need the catalog.
class ReportCompetency extends Equatable {
  const ReportCompetency({
    required this.trackId,
    required this.trackName,
    required this.score,
    required this.level,
    required this.modulesCompleted,
    required this.modulesTotal,
  });

  final String trackId;
  final String trackName;

  /// 0–100.
  final int score;
  final String level;
  final int modulesCompleted;
  final int modulesTotal;

  /// Renders as "3/8", or just the completed count when the total is unknown.
  String get modulesLabel => modulesTotal <= 0
      ? '$modulesCompleted'
      : '$modulesCompleted/$modulesTotal';

  @override
  List<Object?> get props => [
    trackId,
    trackName,
    score,
    level,
    modulesCompleted,
    modulesTotal,
  ];
}

/// One focus-area row, with the trend flattened to a glyph.
class ReportFocusArea extends Equatable {
  const ReportFocusArea({
    required this.title,
    required this.percent,
    required this.trendLabel,
    required this.critical,
  });

  final String title;

  /// Completion/mastery fraction between 0 and 1.
  final double percent;
  final String trendLabel;
  final bool critical;

  @override
  List<Object?> get props => [title, percent, trendLabel, critical];
}
