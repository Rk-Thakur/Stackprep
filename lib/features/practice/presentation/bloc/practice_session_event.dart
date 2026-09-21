import 'package:equatable/equatable.dart';

sealed class PracticeSessionEvent extends Equatable {
  const PracticeSessionEvent();

  @override
  List<Object?> get props => [];
}

/// Kicks off a session: loads the question set for [topicCode].
class PracticeSessionStarted extends PracticeSessionEvent {
  const PracticeSessionStarted({
    required this.topicCode,
    this.moduleId,
    this.challenge = false,
  });

  final String topicCode;

  /// When set, only that module's questions are loaded (a module quiz).
  final String? moduleId;

  /// When true, the session is a daily challenge and is recorded under the
  /// 'challenge' activity channel.
  final bool challenge;

  @override
  List<Object?> get props => [topicCode, moduleId, challenge];
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
