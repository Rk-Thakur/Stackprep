import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/progress_overview.dart';
import '../repositories/progress_repository.dart';

class GetProgressOverview implements UseCase<ProgressOverview, NoParams> {
  const GetProgressOverview({required ProgressRepository repository})
    : _repository = repository;

  final ProgressRepository _repository;

  @override
  Future<Either<Failure, ProgressOverview>> call(NoParams params) =>
      _repository.getProgressOverview();
}
