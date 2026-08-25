import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../onboarding/domain/usecases/get_stack_tracks.dart';
import '../../domain/usecases/get_progress_overview.dart';
import 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit({
    required GetProgressOverview getProgressOverview,
    required GetStackTracks getStackTracks,
  }) : _getProgressOverview = getProgressOverview,
       _getStackTracks = getStackTracks,
       super(const ProgressState());

  final GetProgressOverview _getProgressOverview;
  final GetStackTracks _getStackTracks;

  Future<void> load() async {
    emit(state.copyWith(status: ProgressStatus.loading));
    final results = await (
      _getProgressOverview(const NoParams()),
      _getStackTracks(const NoParams()),
    ).wait;
    final overviewResult = results.$1;
    final tracksResult = results.$2;

    overviewResult.fold(
      (failure) => emit(
        state.copyWith(
          status: ProgressStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (overview) => tracksResult.fold(
        (failure) => emit(
          state.copyWith(
            status: ProgressStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (tracks) => emit(
          state.copyWith(
            status: ProgressStatus.ready,
            summary: overview.summary,
            competencies: overview.competencies,
            focusAreas: overview.focusAreas,
            tracks: tracks,
          ),
        ),
      ),
    );
  }

  void selectTrack(String? trackId) {
    if (trackId == null) {
      emit(state.copyWith(clearSelectedTrack: true));
    } else {
      emit(state.copyWith(selectedTrackId: trackId));
    }
  }
}
