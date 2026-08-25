import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_practice_questions.dart';
import 'practice_session_event.dart';
import 'practice_session_state.dart';

/// Drives a single practice run: question flow, answer grading, and the
/// final score handed to the summary screen.
class PracticeSessionBloc
    extends Bloc<PracticeSessionEvent, PracticeSessionState> {
  PracticeSessionBloc({required GetPracticeQuestions getPracticeQuestions})
    : _getPracticeQuestions = getPracticeQuestions,
      super(const PracticeSessionState()) {
    on<PracticeSessionStarted>(_onStarted);
    on<PracticeAnswerSelected>(_onAnswerSelected);
    on<PracticeAnswerChecked>(_onAnswerChecked);
    on<PracticeQuestionSkipped>(_onQuestionSkipped);
    on<PracticeNextRequested>(_onNextRequested);
  }

  final GetPracticeQuestions _getPracticeQuestions;

  Future<void> _onStarted(
    PracticeSessionStarted event,
    Emitter<PracticeSessionState> emit,
  ) async {
    emit(state.copyWith(status: PracticeSessionStatus.loading));
    final result = await _getPracticeQuestions(
      GetPracticeQuestionsParams(topicCode: event.topicCode),
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
      ),
    );
  }

  void _advance(Emitter<PracticeSessionState> emit) {
    if (state.isLastQuestion) {
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

  void _onQuestionSkipped(
    PracticeQuestionSkipped event,
    Emitter<PracticeSessionState> emit,
  ) {
    if (!state.checked) {
      _advance(emit);
    }
  }

  void _onNextRequested(
    PracticeNextRequested event,
    Emitter<PracticeSessionState> emit,
  ) {
    if (state.checked) {
      _advance(emit);
    }
  }
}
