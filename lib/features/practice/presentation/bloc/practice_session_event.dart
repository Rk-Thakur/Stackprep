import 'package:equatable/equatable.dart';

sealed class PracticeSessionEvent extends Equatable {
  const PracticeSessionEvent();

  @override
  List<Object?> get props => [];
}

/// Kicks off a session: loads the question set for [topicCode].
class PracticeSessionStarted extends PracticeSessionEvent {
  const PracticeSessionStarted({required this.topicCode});

  final String topicCode;

  @override
  List<Object?> get props => [topicCode];
}

class PracticeAnswerSelected extends PracticeSessionEvent {
  const PracticeAnswerSelected(this.optionIndex);

  final int optionIndex;

  @override
  List<Object?> get props => [optionIndex];
}

/// Grades the selected answer and locks the options until the user moves on.
class PracticeAnswerChecked extends PracticeSessionEvent {
  const PracticeAnswerChecked();
}

class PracticeQuestionSkipped extends PracticeSessionEvent {
  const PracticeQuestionSkipped();
}

/// Advances to the next question; on the last question this marks the
/// session completed.
class PracticeNextRequested extends PracticeSessionEvent {
  const PracticeNextRequested();
}
