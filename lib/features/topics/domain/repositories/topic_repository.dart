import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/topic.dart';

abstract interface class TopicRepository {
  Future<Either<Failure, Topic>> getTopic(String topicId);
}
