import 'package:equatable/equatable.dart';

import '../../domain/entities/practice_question.dart';

enum PracticeSessionStatus { initial, loading, ready, failure }

/// Outcome for a single answered question, used to build the summary's
/// real session log.
class QuestionResult {
  const QuestionResult({
    required this.refId,
    required this.correct,
  });

  final String refId;
  final bool correct;
}

class PracticeSessionState extends Equatable {
  const PracticeSessionState({
    this.status = PracticeSessionStatus.initial,
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedIndex,
    this.checked = false,
    this.correctCount = 0,
    this.results = const [],
    this.completed = false,
    this.topicCode = '',
    this.moduleId,
    this.challenge = false,
    this.errorMessage,
  });

  final PracticeSessionStatus status;
  final List<PracticeQuestion> questions;
  final int currentIndex;

  /// Index of the option the user picked for the current question.
  final int? selectedIndex;
  final bool checked;
  final int correctCount;

  /// Per-question outcome (in question order) for the summary session log.
  final List<QuestionResult> results;

  /// True once the last question has been advanced past — the page listens
  /// for this to route to the summary screen.
  final bool completed;
  final String topicCode;
  final String? moduleId;

  /// True when this session was launched as the daily challenge, so it's
  /// recorded under the 'challenge' channel.
  final bool challenge;
  final String? errorMessage;

  bool get isLoading => status == PracticeSessionStatus.loading;
  bool get isLastQuestion => currentIndex == questions.length - 1;
  int get totalQuestions => questions.length;
  double get progress =>
      questions.isEmpty ? 0 : ((currentIndex + 1) / questions.length);

  PracticeQuestion? get currentQuestion =>
      questions.isEmpty ? null : questions[currentIndex];

  PracticeSessionState copyWith({
    PracticeSessionStatus? status,
    List<PracticeQuestion>? questions,
    int? currentIndex,
    int? selectedIndex,
    bool clearSelectedIndex = false,
    bool? checked,
    int? correctCount,
    List<QuestionResult>? results,
    bool? completed,
    String? topicCode,
    String? moduleId,
    bool? challenge,
    String? errorMessage,
  }) {
    return PracticeSessionState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedIndex: clearSelectedIndex
          ? null
          : (selectedIndex ?? this.selectedIndex),
      checked: checked ?? this.checked,
      correctCount: correctCount ?? this.correctCount,
      results: results ?? this.results,
      completed: completed ?? this.completed,
      topicCode: topicCode ?? this.topicCode,
      moduleId: moduleId ?? this.moduleId,
      challenge: challenge ?? this.challenge,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    questions,
    currentIndex,
    selectedIndex,
    checked,
    correctCount,
    results,
    completed,
    topicCode,
    moduleId,
    challenge,
    errorMessage,
  ];
}
