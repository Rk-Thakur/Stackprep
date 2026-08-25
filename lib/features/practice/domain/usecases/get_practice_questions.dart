import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/practice_question.dart';
import '../repositories/practice_repository.dart';

class GetPracticeQuestions
    implements UseCase<List<PracticeQuestion>, GetPracticeQuestionsParams> {
  GetPracticeQuestions(this._repository);

  final PracticeRepository _repository;

  @override
  Future<Either<Failure, List<PracticeQuestion>>> call(
    GetPracticeQuestionsParams params,
  ) => _repository.getQuestions(topicCode: params.topicCode);
}

class GetPracticeQuestionsParams extends Equatable {
  const GetPracticeQuestionsParams({required this.topicCode});

  final String topicCode;

  @override
  List<Object?> get props => [topicCode];
}
