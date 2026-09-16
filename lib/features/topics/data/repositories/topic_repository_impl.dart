import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/topic.dart';
import '../../domain/repositories/topic_repository.dart';
import '../datasources/topic_remote_data_source.dart';

class TopicRepositoryImpl implements TopicRepository {
  TopicRepositoryImpl({required TopicRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final TopicRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Topic>> getTopic(String topicId) async {
    try {
      final topic = await _remoteDataSource.getTopic(topicId);
      return Right(topic);
    } on AppException catch (exception) {
      return Left(CacheFailure(exception.message));
    }
  }

  @override
  Future<Either<Failure, List<Topic>>> getTopics() async {
    try {
      final topics = await _remoteDataSource.getTopics();
      return Right(topics);
    } on AppException catch (exception) {
      return Left(CacheFailure(exception.message));
    }
  }
}
