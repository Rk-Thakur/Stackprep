import 'package:dartz/dartz.dart';
import 'package:stackprep/core/error/failures.dart';
import 'package:stackprep/core/usecases/usecase.dart';
import 'package:stackprep/features/auth/domain/entities/app_user.dart';
import 'package:stackprep/features/onboarding/domain/usecases/get_stack_tracks.dart';
import 'package:stackprep/features/progress/domain/entities/progress_overview.dart';
import 'package:stackprep/features/progress/domain/usecases/get_progress_overview.dart';

import '../entities/progress_report.dart';

/// Assembles a [ProgressReport] from the live progress overview and the
/// signed-in user, so the PDF renderer stays a pure function of its input.
class BuildProgressReport
    implements UseCase<ProgressReport, BuildProgressReportParams> {
  const BuildProgressReport({
    required GetProgressOverview getProgressOverview,
    required GetStackTracks getStackTracks,
  }) : _getProgressOverview = getProgressOverview,
       _getStackTracks = getStackTracks;

  final GetProgressOverview _getProgressOverview;
  final GetStackTracks _getStackTracks;

  @override
  Future<Either<Failure, ProgressReport>> call(
    BuildProgressReportParams params,
  ) async {
    final overviewResult = await _getProgressOverview(const NoParams());
    final overview = overviewResult.fold((failure) => null, (value) => value);
    if (overview == null) {
      return Left<Failure, ProgressReport>(
        overviewResult.fold((failure) => failure, (_) => null)!,
      );
    }

    // Names are cosmetic, so an empty catalog just falls back to the raw id.
    final trackNames = (await _getStackTracks(const NoParams())).fold(
      (_) => <String, String>{},
      (list) => {for (final track in list) track.id: track.name},
    );

    return Right(_build(overview, trackNames, params.user, params.generatedAt));
  }

  ProgressReport _build(
    ProgressOverview overview,
    Map<String, String> trackNames,
    AppUser? user,
    DateTime generatedAt,
  ) {
    final summary = overview.summary;
    return ProgressReport(
      generatedAt: generatedAt,
      userName: _clean(user?.displayName),
      userEmail: _clean(user?.email),
      currentStreakDays: summary.currentStreakDays,
      totalSessions: summary.totalSessions,
      readinessScore: summary.readinessScore,
      globalReadinessScore: summary.globalReadinessScore,
      targetScore: summary.targetScore,
      activityLevels: summary.activityLevels,
      competencies: overview.competencies
          .map(
            (c) => ReportCompetency(
              trackId: c.trackId,
              trackName: trackNames[c.trackId] ?? c.trackId,
              score: c.score,
              level: c.level,
              modulesCompleted: c.modulesCompleted,
              modulesTotal: c.modulesTotal,
            ),
          )
          .toList(growable: false),
      focusAreas: overview.focusAreas
          .map(
            (f) => ReportFocusArea(
              title: f.title,
              percent: f.percent,
              trendLabel: f.trendLabel,
              critical: f.critical,
            ),
          )
          .toList(growable: false),
    );
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

class BuildProgressReportParams {
  const BuildProgressReportParams({this.user, required this.generatedAt});

  final AppUser? user;
  final DateTime generatedAt;
}
