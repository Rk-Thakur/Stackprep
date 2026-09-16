import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/progress_repository.dart';

/// Records one completed practice/MCQ/quiz/flashcard/challenge attempt so
/// the progress tab reflects real usage instead of a hand-authored snapshot.
class RecordAttempt implements UseCase<void, RecordAttemptParams> {
  const RecordAttempt({required ProgressRepository repository})
    : _repository = repository;

  final ProgressRepository _repository;

  @override
  Future<Either<Failure, void>> call(RecordAttemptParams params) =>
      _repository.recordAttempt(
        trackId: params.trackId,
        moduleId: params.moduleId,
        moduleTitle: params.moduleTitle,
        type: params.type,
        correct: params.correct,
        total: params.total,
      );
}

class RecordAttemptParams extends Equatable {
  const RecordAttemptParams({
    required this.trackId,
    this.moduleId,
    this.moduleTitle,
    required this.type,
    required this.correct,
    required this.total,
  });

  final String trackId;
  final String? moduleId;

  /// Only needed when [moduleId] is set — labels the module in Focus Areas
  /// without an extra Firestore read.
  final String? moduleTitle;

  /// 'mcq', 'quiz', 'flashcard', or 'challenge' — each maps onto a weighted
  /// activity channel in the track's competency score.
  final String type;
  final int correct;
  final int total;

  @override
  List<Object?> get props => [
    trackId,
    moduleId,
    moduleTitle,
    type,
    correct,
    total,
  ];
}
