import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/practice_question.dart';
import '../../domain/repositories/practice_repository.dart';
import '../datasources/practice_remote_data_source.dart';

class PracticeRepositoryImpl implements PracticeRepository {
  PracticeRepositoryImpl({required PracticeRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final PracticeRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<PracticeQuestion>>> getQuestions({
    required String topicCode,
  }) async {
    try {
      final models = await _remoteDataSource.getQuestions(
        topicCode: topicCode,
      );
      return Right(models.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Could not load practice questions.'));
    }
  }
}
