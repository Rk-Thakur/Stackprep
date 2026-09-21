import 'package:equatable/equatable.dart';

/// A highlighted code sample attached to a question or lesson.
class CodeSnippet extends Equatable {
  const CodeSnippet({
    required this.header,
    required this.language,
    required this.lines,
  });

  final String header;
  final String language;
  final List<String> lines;

  @override
  List<Object?> get props => [header, language, lines];
}

/// A single multiple-choice practice question.
class PracticeQuestion extends Equatable {
  const PracticeQuestion({
    required this.refId,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.codeSnippet,
  });

  final String refId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final CodeSnippet? codeSnippet;

  @override
  List<Object?> get props => [
    refId,
    question,
    options,
    correctIndex,
    codeSnippet,
  ];
}
