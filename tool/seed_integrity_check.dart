import 'package:stackprep/features/dev/data/seeder/seed_catalog.dart';

void main() {
  final errors = <String>[];
  final levels = {'BEGINNER', 'INTERMEDIATE', 'ADVANCED'};
  final trackIds = <String>{};

  for (final track in seedTracks) {
    if (!trackIds.add(track.id)) {
      errors.add('Duplicate track id: ${track.id}');
    }
    if (track.id.isEmpty ||
        track.name.isEmpty ||
        track.description.isEmpty ||
        track.category.isEmpty) {
      errors.add('Track ${track.id}: empty metadata field');
    }
    if (track.modules.isEmpty) {
      errors.add('Track ${track.id}: no modules');
    }
    if (track.flipcards.isEmpty) {
      errors.add('Track ${track.id}: no flipcards');
    }

    final moduleIds = <String>{};
    final flipcardIds = <String>{};
    for (final module in track.modules) {
      if (!moduleIds.add(module.id)) {
        errors.add('Track ${track.id}: duplicate module id ${module.id}');
      }
      if (module.questions.length < 10) {
        errors.add(
          'Track ${track.id} module ${module.id}: expected >=10 questions, '
          'got ${module.questions.length}',
        );
      }
      if (module.title.isEmpty || module.description.isEmpty) {
        errors.add('Track ${track.id} module ${module.id}: empty title/description');
      }
      if (module.learningObjectives.isEmpty) {
        errors.add('Track ${track.id} module ${module.id}: no learning objectives');
      }
      if (!levels.contains(module.level)) {
        errors.add('Track ${track.id} module ${module.id}: bad level ${module.level}');
      }

      final questionIds = <String>{};
      for (final q in module.questions) {
        if (!questionIds.add(q.id)) {
          errors.add('Track ${track.id} module ${module.id}: duplicate question id ${q.id}');
        }
        if (q.question.trim().isEmpty) {
          errors.add('Track ${track.id} module ${module.id}: empty question body');
        }
        if (q.options.length < 2) {
          errors.add('Track ${track.id} module ${module.id} q ${q.id}: <2 options');
        }
        if (q.correctIndex < 0 || q.correctIndex >= q.options.length) {
          errors.add(
            'Track ${track.id} module ${module.id} q ${q.id}: '
            'correctIndex ${q.correctIndex} out of range for ${q.options.length} options',
          );
        }
        if (!levels.contains(q.level)) {
          errors.add('Track ${track.id} module ${module.id} q ${q.id}: bad level ${q.level}');
        }
        final levelCounts = <String, int>{};
        for (final l in [q.level]) {
          levelCounts.update(l, (v) => v + 1, ifAbsent: () => 1);
        }
        if (q.correctIndex < 0) {
          errors.add('unused');
        }
      }
    }

    for (final card in track.flipcards) {
      if (!flipcardIds.add(card.id)) {
        errors.add('Track ${track.id}: duplicate flipcard id ${card.id}');
      }
      if (card.term.trim().isEmpty || card.definition.trim().isEmpty) {
        errors.add('Track ${track.id} flipcard ${card.id}: empty term/definition');
      }
    }
  }

  if (errors.isEmpty) {
    print('ALL CHECKS PASSED');
    for (final track in seedTracks) {
      final questions = track.modules
          .fold<int>(0, (sum, m) => sum + m.questions.length);
      print(
        '${track.id}: ${track.modules.length} modules, $questions questions, '
        '${track.flipcards.length} flipcards',
      );
    }
  } else {
    for (final e in errors) {
      print('ERROR: $e');
    }
    throw Exception('Seed integrity validation failed (${errors.length} errors)');
  }
}