import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../onboarding/domain/entities/stack_track.dart';
import '../entities/progress_overview.dart';

abstract interface class ProgressRepository {
  Future<Either<Failure, ProgressOverview>> getProgressOverview();

  /// Loads the live track catalog from Firestore for the Core Competencies
  /// filter, so it only shows tracks that currently exist.
  Future<Either<Failure, List<StackTrack>>> getTracks();

  /// Records one completed practice/MCQ/flashcard attempt and rolls it into
  /// the user's cached `progress/overview` document (streak, per-track
  /// competency score, and global readiness).
  Future<Either<Failure, void>> recordAttempt({
    required String trackId,
    String? moduleId,
    String? moduleTitle,
    required String type,
    required int correct,
    required int total,
  });

  /// Marks a module as viewed the first time the user opens it, bumping
  /// that track's completed-module count. A no-op on repeat views.
  Future<Either<Failure, void>> markModuleViewed({
    required String trackId,
    required String moduleId,
  });
}
