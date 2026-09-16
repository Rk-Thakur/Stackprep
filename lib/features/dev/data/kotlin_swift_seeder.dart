import 'package:cloud_firestore/cloud_firestore.dart';

import 'seeder/seed_catalog.dart';
import 'seeder/seed_models.dart';

/// Seeder for the four primary tracks (Kotlin, Swift, Flutter,
/// React Native) with full curriculum: modules + content, questions, and
/// flipcards.
///
/// Collection paths written:
///   tracks/{trackId}
///   tracks/{trackId}/modules/{moduleId}              (contains content[] blocks)
///   tracks/{trackId}/modules/{moduleId}/questions/{qId}
///   tracks/{trackId}/flipcards/{cardId}
///
/// Content block types: heading, explanation, code.
/// Question fields: question, options, correctIndex, level, codeHeader,
///   codeLanguage, codeLines.
/// Flipcard fields: term, definition, codeHeader, codeLanguage, codeLines.
class AppSeeder {
  const AppSeeder();

  /// Seeds every track and returns a report of document counts written.
  Future<Map<String, Map<String, int>>> seedAll() async {
    final report = <String, Map<String, int>>{};
    for (final track in seedTracks) {
      report[track.id] = await _seedTrack(track);
    }
    return report;
  }

  Future<Map<String, int>> _seedTrack(SeedTrack track) async {
    final db = FirebaseFirestore.instance;
    final trackRef = db.collection('tracks').doc(track.id);

    await trackRef.set({
      'name': track.name,
      'description': track.description,
      'category': track.category,
      'color': track.color,
      'order': track.order,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    var modules = 0;
    var questions = 0;

    for (var mi = 0; mi < track.modules.length; mi++) {
      final module = track.modules[mi];
      final moduleRef = trackRef.collection('modules').doc(module.id);

      await moduleRef.set({
        'title': module.title,
        'description': module.description,
        'learningObjectives': module.learningObjectives,
        'level': module.level,
        'order': mi,
        'trackId': track.id,
        'content': module.content,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      modules++;

      // Questions for this module.
      for (final q in module.questions) {
        final qRef = moduleRef.collection('questions').doc(q.id);
        await qRef.set(q.toFirestore(), SetOptions(merge: true));
        questions++;
      }
    }

    // Flipcards for the whole track.
    var flipcards = 0;
    for (final card in track.flipcards) {
      final cardRef = trackRef.collection('flipcards').doc(card.id);
      await cardRef.set(card.toFirestore(), SetOptions(merge: true));
      flipcards++;
    }

    return {'modules': modules, 'questions': questions, 'flipcards': flipcards};
  }
}
