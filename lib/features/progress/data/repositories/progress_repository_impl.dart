import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../datasources/progress_local_data_source.dart';
import '../../domain/entities/progress_overview.dart';
import '../../domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl({required ProgressFirestoreDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ProgressFirestoreDataSource _remoteDataSource;

  @override
  Future<Either<Failure, ProgressOverview>> getProgressOverview() async {
    try {
      final overview = await _remoteDataSource.getProgressOverview();
      return Right(overview);
    } on AppException catch (exception) {
      return Left(CacheFailure(exception.message));
    }
  }
}
