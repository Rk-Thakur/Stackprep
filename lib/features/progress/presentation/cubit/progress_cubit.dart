import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../onboarding/domain/entities/stack_track.dart';
import '../../../onboarding/domain/usecases/get_stack_tracks.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/usecases/get_progress_overview.dart';
import 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit({
    required GetProgressOverview getProgressOverview,
    required ProgressRepository repository,
    required GetStackTracks getStackTracks,
  }) : _getProgressOverview = getProgressOverview,
       _repository = repository,
       _getStackTracks = getStackTracks,
       super(const ProgressState());

  final GetProgressOverview _getProgressOverview;
  final ProgressRepository _repository;
  final GetStackTracks _getStackTracks;

  Future<void> load() async {
    emit(state.copyWith(status: ProgressStatus.loading));
    final overviewResult = await _getProgressOverview(const NoParams());
    if (isClosed) return;
    final tracks = await _loadTracks();
    if (isClosed) return;
    overviewResult.fold(
      (failure) => emit(
        state.copyWith(
          status: ProgressStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (overview) => emit(
        state.copyWith(
          status: ProgressStatus.ready,
          summary: overview.summary,
          competencies: overview.competencies,
          focusAreas: overview.focusAreas,
          tracks: tracks,
        ),
      ),
    );
  }

  Future<List<StackTrack>> _loadTracks() async {
    // Prefer the live Firestore catalog so the Core Competencies filter only
    // shows tracks that currently exist; fall back to the bundled catalog if
    // the read fails.
    final remote = await _repository.getTracks();
    if (remote.isRight()) {
      return remote.getOrElse(() => const []);
    }
    final fallback = await _getStackTracks(const NoParams());
    return fallback.getOrElse(() => const []);
  }

  void selectTrack(String? trackId) {
    if (trackId == null) {
      emit(state.copyWith(clearSelectedTrack: true));
    } else {
      emit(state.copyWith(selectedTrackId: trackId));
    }
  }
}
