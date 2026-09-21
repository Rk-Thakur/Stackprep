import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/topic.dart';
import '../repositories/topic_repository.dart';

class GetTopic implements UseCase<Topic, GetTopicParams> {
  const GetTopic({required TopicRepository repository})
    : _repository = repository;

  final TopicRepository _repository;

  @override
  Future<Either<Failure, Topic>> call(GetTopicParams params) =>
      _repository.getTopic(params.topicId);
}

class GetTopicParams extends Equatable {
  const GetTopicParams({required this.topicId});

  final String topicId;

  @override
  List<Object?> get props => [topicId];
}
