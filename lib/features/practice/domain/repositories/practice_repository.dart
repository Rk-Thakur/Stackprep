import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/practice_question.dart';

/// Practice contract owned by the domain layer.
abstract interface class PracticeRepository {
  Future<Either<Failure, List<PracticeQuestion>>> getQuestions({
    required String topicCode,
  });
}
