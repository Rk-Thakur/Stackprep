/// Shared models for the Firestore curriculum seeder.
///
/// These are the PUBLIC counterparts of the private seed types that used to
/// live inside `kotlin_swift_seeder.dart`. Splitting the seed content across
/// per-track files keeps each track editable independently while the seeder
/// (and the dev SeedPage) consume a single combined catalog: `seedTracks`.
library;

class SeedTrack {
  const SeedTrack({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.color,
    required this.order,
    required this.modules,
    required this.flipcards,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final int color;
  final int order;
  final List<SeedModule> modules;
  final List<SeedFlipcard> flipcards;
}

class SeedModule {
  const SeedModule({
    required this.id,
    required this.title,
    required this.description,
    required this.learningObjectives,
    required this.content,
    this.level = 'BEGINNER',
    this.questions = const [],
  });

  final String id;
  final String title;
  final String description;
  final List<String> learningObjectives;
  final String level;

  /// Content blocks: `{type: heading, text}` or
  /// `{type: explanation, text}` or `{type: code, language, code}`.
  final List<Map<String, dynamic>> content;
  final List<SeedQuestion> questions;
}

class SeedQuestion {
  SeedQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.level,
    this.codeHeader,
    this.codeLanguage,
    this.codeLines = const [],
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String level;
  final String? codeHeader;
  final String? codeLanguage;
  final List<String> codeLines;

  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'level': level,
      if (codeHeader != null) 'codeHeader': codeHeader,
      if (codeLanguage != null) 'codeLanguage': codeLanguage,
      if (codeLines.isNotEmpty) 'codeLines': codeLines,
    };
  }
}

class SeedFlipcard {
  SeedFlipcard({
    required this.id,
    required this.term,
    required this.definition,
    this.codeHeader,
    this.codeLanguage,
    this.codeLines = const [],
  });

  final String id;
  final String term;
  final String definition;
  final String? codeHeader;
  final String? codeLanguage;
  final List<String> codeLines;

  Map<String, dynamic> toFirestore() {
    return {
      'term': term,
      'definition': definition,
      if (codeHeader != null) 'codeHeader': codeHeader,
      if (codeLanguage != null) 'codeLanguage': codeLanguage,
      if (codeLines.isNotEmpty) 'codeLines': codeLines,
    };
  }
}
