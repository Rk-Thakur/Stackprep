import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/onboarding_repository.dart';

/// Writes the user's id, email, selected tracks, and runtime level to the
/// backend. Fired specifically on "Enter Workspace", not at onboarding
/// completion — see [OnboardingRepository.syncProfileToRemote].
class SyncProfileToRemote implements UseCase<void, SyncProfileToRemoteParams> {
  SyncProfileToRemote(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<Either<Failure, void>> call(SyncProfileToRemoteParams params) =>
      _repository.syncProfileToRemote(
        trackIds: params.trackIds,
        runtimeLevelId: params.runtimeLevelId,
      );
}

class SyncProfileToRemoteParams extends Equatable {
  const SyncProfileToRemoteParams({
    required this.trackIds,
    required this.runtimeLevelId,
  });

  final List<String> trackIds;
  final String runtimeLevelId;

  @override
  List<Object?> get props => [trackIds, runtimeLevelId];
}
