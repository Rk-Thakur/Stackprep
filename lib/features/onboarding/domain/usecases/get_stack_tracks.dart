import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stack_track.dart';
import '../repositories/onboarding_repository.dart';

class GetStackTracks implements UseCase<List<StackTrack>, NoParams> {
  GetStackTracks(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<Either<Failure, List<StackTrack>>> call(NoParams params) async {
    return Right(_repository.getStackTracks());
  }
}
