import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../onboarding/domain/usecases/get_stack_tracks.dart';
import 'practice_state.dart';

/// Loads the track catalog for the practice tab. Reuses the onboarding
/// feature's domain layer — the catalog belongs to onboarding, practice
/// merely consumes it.
class PracticeCubit extends Cubit<PracticeState> {
  PracticeCubit({required GetStackTracks getStackTracks})
    : _getStackTracks = getStackTracks,
      super(const PracticeState());

  final GetStackTracks _getStackTracks;

  Future<void> loadTracks() async {
    if (state.status == PracticeStatus.ready) return;
    emit(state.copyWith(status: PracticeStatus.loading));
    final result = await _getStackTracks(const NoParams());
    result.fold(
      (Failure failure) => emit(
        state.copyWith(
          status: PracticeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (tracks) => emit(state.copyWith(status: PracticeStatus.ready, tracks: tracks)),
    );
  }
}
