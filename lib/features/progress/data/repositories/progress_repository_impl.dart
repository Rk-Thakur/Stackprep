import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../onboarding/domain/entities/stack_track.dart';
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

  @override
  Future<Either<Failure, List<StackTrack>>> getTracks() async {
    try {
      final tracks = await _remoteDataSource.getTracks();
      return Right(tracks);
    } on AppException catch (exception) {
      return Left(CacheFailure(exception.message));
    }
  }

  @override
  Future<Either<Failure, void>> recordAttempt({
    required String trackId,
    String? moduleId,
    String? moduleTitle,
    required String type,
    required int correct,
    required int total,
  }) async {
    try {
      await _remoteDataSource.recordAttempt(
        trackId: trackId,
        moduleId: moduleId,
        moduleTitle: moduleTitle,
        type: type,
        correct: correct,
        total: total,
      );
      return const Right(null);
    } on AppException catch (exception) {
      return Left(CacheFailure(exception.message));
    }
  }

  @override
  Future<Either<Failure, void>> markModuleViewed({
    required String trackId,
    required String moduleId,
  }) async {
    try {
      await _remoteDataSource.markModuleViewed(
        trackId: trackId,
        moduleId: moduleId,
      );
      return const Right(null);
    } on AppException catch (exception) {
      return Left(CacheFailure(exception.message));
    }
  }
}
