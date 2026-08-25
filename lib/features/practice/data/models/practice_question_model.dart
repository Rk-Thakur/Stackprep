import '../../domain/entities/practice_question.dart';

/// Data-layer shape of [PracticeQuestion]; mirrors the entity until real
/// serialization (Firestore/RemoteConfig) lands.
class PracticeQuestionModel {
  const PracticeQuestionModel({
    required this.refId,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.codeHeader,
    this.codeLanguage,
    this.codeLines = const [],
  });

  final String refId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? codeHeader;
  final String? codeLanguage;
  final List<String> codeLines;

  PracticeQuestion toEntity() => PracticeQuestion(
    refId: refId,
    question: question,
    options: options,
    correctIndex: correctIndex,
    codeSnippet: codeHeader == null || codeLanguage == null
        ? null
        : CodeSnippet(
            header: codeHeader!,
            language: codeLanguage!,
            lines: codeLines,
          ),
  );
}
