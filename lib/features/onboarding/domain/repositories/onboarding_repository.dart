import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/onboarding_summary.dart';
import '../entities/runtime_level.dart';
import '../entities/stack_track.dart';

/// Onboarding contract owned by the domain layer; implemented in the data
/// layer on top of the bundled track/runtime catalogs.
abstract interface class OnboardingRepository {
  List<StackTrack> getStackTracks();

  List<RuntimeLevel> getRuntimeLevels();

  /// Validates and persists the user's selection locally, returning the
  /// resolved summary used by the recap screen. Does not touch the backend —
  /// see [syncProfileToRemote] for that.
  Future<Either<Failure, OnboardingSummary>> completeOnboarding({
    required List<String> trackIds,
    required String runtimeLevelId,
  });

  /// Writes the signed-in user's id, email, selected tracks, and runtime
  /// level to the backend. Called when the user taps "Enter Workspace" on
  /// the recap screen, i.e. once they've actually committed to the
  /// selection rather than just previewed it.
  Future<Either<Failure, void>> syncProfileToRemote({
    required List<String> trackIds,
    required String runtimeLevelId,
  });
}
