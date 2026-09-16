import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/progress_repository.dart';

/// Records that the user opened a module, so the progress tab can show how
/// many of a track's modules they've worked through.
class MarkModuleViewed implements UseCase<void, MarkModuleViewedParams> {
  const MarkModuleViewed({required ProgressRepository repository})
    : _repository = repository;

  final ProgressRepository _repository;

  @override
  Future<Either<Failure, void>> call(MarkModuleViewedParams params) =>
      _repository.markModuleViewed(
        trackId: params.trackId,
        moduleId: params.moduleId,
      );
}

class MarkModuleViewedParams extends Equatable {
  const MarkModuleViewedParams({
    required this.trackId,
    required this.moduleId,
  });

  final String trackId;
  final String moduleId;

  @override
  List<Object?> get props => [trackId, moduleId];
}
