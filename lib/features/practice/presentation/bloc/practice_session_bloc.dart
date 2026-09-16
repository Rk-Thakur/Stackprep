import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../progress/domain/usecases/record_attempt.dart';
import '../../domain/usecases/get_practice_questions.dart';
import 'practice_session_event.dart';
import 'practice_session_state.dart';

/// Drives a single practice run: question flow, answer grading, and the
/// final score handed to the summary screen.
class PracticeSessionBloc
    extends Bloc<PracticeSessionEvent, PracticeSessionState> {
  PracticeSessionBloc({
    required GetPracticeQuestions getPracticeQuestions,
    required RecordAttempt recordAttempt,
  }) : _getPracticeQuestions = getPracticeQuestions,
       _recordAttempt = recordAttempt,
       super(const PracticeSessionState()) {
    on<PracticeSessionStarted>(_onStarted);
    on<PracticeAnswerSelected>(_onAnswerSelected);
    on<PracticeAnswerChecked>(_onAnswerChecked);
    on<PracticeQuestionSkipped>(_onQuestionSkipped);
    on<PracticeNextRequested>(_onNextRequested);
  }

  final GetPracticeQuestions _getPracticeQuestions;
  final RecordAttempt _recordAttempt;

  Future<void> _onStarted(
    PracticeSessionStarted event,
    Emitter<PracticeSessionState> emit,
  ) async {
    emit(state.copyWith(status: PracticeSessionStatus.loading));
    final result = await _getPracticeQuestions(
      GetPracticeQuestionsParams(
        topicCode: event.topicCode,
        moduleId: event.moduleId,
      ),
    );
    result.fold(
      (Failure failure) => emit(
        state.copyWith(
          status: PracticeSessionStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (questions) => emit(
        state.copyWith(
          status: PracticeSessionStatus.ready,
          questions: questions,
          currentIndex: 0,
          clearSelectedIndex: true,
          checked: false,
          correctCount: 0,
          results: const [],
          topicCode: event.topicCode,
          moduleId: event.moduleId,
          challenge: event.challenge,
        ),
      ),
    );
  }

  void _onAnswerSelected(
    PracticeAnswerSelected event,
    Emitter<PracticeSessionState> emit,
  ) {
    if (state.checked) return;
    emit(state.copyWith(selectedIndex: event.optionIndex));
  }

  void _onAnswerChecked(
    PracticeAnswerChecked event,
    Emitter<PracticeSessionState> emit,
  ) {
    if (state.checked || state.selectedIndex == null) return;
    final question = state.currentQuestion;
    if (question == null) return;

    final isCorrect = state.selectedIndex == question.correctIndex;
    emit(
      state.copyWith(
        checked: true,
        correctCount: isCorrect ? state.correctCount + 1 : state.correctCount,
        results: [
          ...state.results,
          QuestionResult(refId: question.refId, correct: isCorrect),
        ],
      ),
    );
  }

  Future<void> _advance(Emitter<PracticeSessionState> emit) async {
    if (state.isLastQuestion) {
      final type = state.challenge
          ? 'challenge'
          : (state.moduleId == null ? 'mcq' : 'quiz');
      await _recordAttempt(
        RecordAttemptParams(
          trackId: state.topicCode,
          moduleId: state.moduleId,
          type: type,
          correct: state.correctCount,
          total: state.totalQuestions,
        ),
      );
      emit(state.copyWith(completed: true));
      return;
    }
    emit(
      state.copyWith(
        currentIndex: state.currentIndex + 1,
        clearSelectedIndex: true,
        checked: false,
      ),
    );
  }

  Future<void> _onQuestionSkipped(
    PracticeQuestionSkipped event,
    Emitter<PracticeSessionState> emit,
  ) async {
    if (!state.checked) {
      await _advance(emit);
    }
  }

  Future<void> _onNextRequested(
    PracticeNextRequested event,
    Emitter<PracticeSessionState> emit,
  ) async {
    if (state.checked) {
      await _advance(emit);
    }
  }
}
