import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/daily_challenge_store.dart';
import '../../../progress/domain/usecases/record_attempt.dart';
import '../../domain/entities/practice_question.dart';
import '../../domain/usecases/get_practice_questions.dart';
import 'practice_session_event.dart';
import 'practice_session_state.dart';

/// Number of questions in each daily challenge session.
const int kDailyChallengeQuestionCount = 10;

/// Drives a single practice run: question flow, answer grading, and the
/// final score handed to the summary screen.
class PracticeSessionBloc
    extends Bloc<PracticeSessionEvent, PracticeSessionState> {
  PracticeSessionBloc({
    required GetPracticeQuestions getPracticeQuestions,
    required RecordAttempt recordAttempt,
    required DailyChallengeStore dailyChallengeStore,
  }) : _getPracticeQuestions = getPracticeQuestions,
       _recordAttempt = recordAttempt,
       _dailyChallengeStore = dailyChallengeStore,
       super(const PracticeSessionState()) {
    on<PracticeSessionStarted>(_onStarted);
    on<PracticeAnswerSelected>(_onAnswerSelected);
    on<PracticeAnswerChecked>(_onAnswerChecked);
    on<PracticeQuestionSkipped>(_onQuestionSkipped);
    on<PracticeNextRequested>(_onNextRequested);
  }

  final GetPracticeQuestions _getPracticeQuestions;
  final RecordAttempt _recordAttempt;
  final DailyChallengeStore _dailyChallengeStore;

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
          questions: event.challenge
              ? _buildDailyChallenge(questions)
              : questions,
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
      if (state.challenge) {
        await _dailyChallengeStore.markDoneToday();
      }
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

  /// Picks today's fixed challenge set: a deterministic per-date shuffle
  /// capped to [kDailyChallengeQuestionCount], so every user sees the same
  /// questions on the same day and the set rolls over each calendar day.
  List<PracticeQuestion> _buildDailyChallenge(List<PracticeQuestion> all) {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final shuffled = List<PracticeQuestion>.of(all)..shuffle(Random(seed));
    return shuffled.take(kDailyChallengeQuestionCount).toList();
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
