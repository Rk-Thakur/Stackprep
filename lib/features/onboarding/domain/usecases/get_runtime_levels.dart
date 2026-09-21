import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/runtime_level.dart';
import '../repositories/onboarding_repository.dart';

class GetRuntimeLevels implements UseCase<List<RuntimeLevel>, NoParams> {
  GetRuntimeLevels(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<Either<Failure, List<RuntimeLevel>>> call(NoParams params) async {
    return Right(_repository.getRuntimeLevels());
  }
}
