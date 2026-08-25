import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/onboarding_local_data_source.dart';
import '../../domain/entities/onboarding_summary.dart';
import '../../domain/usecases/complete_onboarding.dart';
import '../../domain/usecases/get_runtime_levels.dart' as levels_uc;
import '../../domain/usecases/get_stack_tracks.dart' as tracks_uc;
import '../../domain/usecases/sync_profile_to_remote.dart';
import 'onboarding_state.dart';

/// Drives both onboarding steps (stack selection + runtime calibration) so
/// the two pages share one selection state.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required tracks_uc.GetStackTracks getStackTracks,
    required levels_uc.GetRuntimeLevels getRuntimeLevels,
    required CompleteOnboarding completeOnboarding,
    required SyncProfileToRemote syncProfileToRemote,
    required OnboardingLocalDataSource localDataSource,
  }) : _getStackTracks = getStackTracks,
       _getRuntimeLevels = getRuntimeLevels,
       _completeOnboarding = completeOnboarding,
       _syncProfileToRemote = syncProfileToRemote,
       _localDataSource = localDataSource,
       super(const OnboardingState());

  final tracks_uc.GetStackTracks _getStackTracks;
  final levels_uc.GetRuntimeLevels _getRuntimeLevels;
  final CompleteOnboarding _completeOnboarding;
  final SyncProfileToRemote _syncProfileToRemote;
  final OnboardingLocalDataSource _localDataSource;

  Future<void> loadCatalogs() async {
    if (state.status == OnboardingStatus.ready) return;
    final tracksResult = await _getStackTracks(const NoParams());
    final levelsResult = await _getRuntimeLevels(const NoParams());
    emit(
      state.copyWith(
        status: OnboardingStatus.ready,
        tracks: tracksResult.getOrElse(() => const []),
        levels: levelsResult.getOrElse(() => const []),
        clearError: true,
      ),
    );
  }

  void toggleTrack(String id) {
    final updated = Set<String>.from(state.selectedTrackIds);
    if (!updated.add(id)) {
      updated.remove(id);
    }
    emit(state.copyWith(selectedTrackIds: updated));
  }

  void selectLevel(String id) {
    emit(state.copyWith(selectedLevelId: id));
  }

  /// Validates + persists the selection. Returns the resolved summary on
  /// success (also mirrored into [OnboardingState.summary]), or null after
  /// emitting the failure message.
  Future<OnboardingSummary?> submit() async {
    final result = await _completeOnboarding(
      CompleteOnboardingParams(
        trackIds: state.selectedTrackIds.toList(),
        runtimeLevelId: state.selectedLevelId,
      ),
    );
    return result.fold(
      (Failure failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return null;
      },
      (summary) {
        emit(state.copyWith(summary: summary));
        return summary;
      },
    );
  }

  /// Fires the Firestore write of the user's id, email, tracks, and runtime
  /// level. Called on "Enter Workspace" — the point the user actually
  /// commits to the selection, not just previews it on the recap screen.
  /// Never throws; a failure here shouldn't stop the user from continuing.
  /// Also persists the onboarding completion flag and selections to
  /// SharedPreferences so the splash screen can skip auth + onboarding
  /// on subsequent launches.
  Future<void> syncOnEnterWorkspace() async {
    await _syncProfileToRemote(
      SyncProfileToRemoteParams(
        trackIds: state.selectedTrackIds.toList(),
        runtimeLevelId: state.selectedLevelId,
      ),
    );
    await _localDataSource.saveSelections(
      trackIds: state.selectedTrackIds.toList(),
      runtimeLevelId: state.selectedLevelId,
    );
    await _localDataSource.setOnboardingCompleted();
  }
}
