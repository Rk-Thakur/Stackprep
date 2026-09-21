import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../models/practice_question_model.dart';

/// Fetches practice questions from Firestore. Each track stores its
/// questions in sub-collections: `tracks/{trackId}/modules/{moduleId}/questions/`.
abstract interface class PracticeRemoteDataSource {
  Future<List<PracticeQuestionModel>> getQuestions({
    required String topicCode,
    String? moduleId,
  });
}

class PracticeFirestoreDataSourceImpl implements PracticeRemoteDataSource {
  PracticeFirestoreDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<List<PracticeQuestionModel>> getQuestions({
    required String topicCode,
    String? moduleId,
  }) async {
    if (topicCode.isEmpty) {
      throw const CacheException('Topic code is required.');
    }
    try {
      // The topic code is a track id (e.g. KOTLIN). When a module is given,
      // only that module's questions are loaded; otherwise every question
      // across all of the track's modules is aggregated into one set.
      final moduleIds = moduleId == null
          ? (await _firestore
                  .collection('tracks')
                  .doc(topicCode)
                  .collection('modules')
                  .get())
              .docs
              .map((d) => d.id)
              .toList()
          : [moduleId];
      final questions = <PracticeQuestionModel>[];
      for (final moduleId in moduleIds) {
        final qSnap = await _firestore
            .collection('tracks')
            .doc(topicCode)
            .collection('modules')
            .doc(moduleId)
            .collection('questions')
            .get();
        questions.addAll(
          qSnap.docs.map((doc) => _fromFirestore(doc.id, doc.data())),
        );
      }
      if (questions.isEmpty) {
        throw const CacheException('No questions available for this track.');
      }
      return questions;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch questions.');
    }
  }

  PracticeQuestionModel _fromFirestore(String docId, Map<String, dynamic> data) {
    final optionsRaw = data['options'] as List<dynamic>? ?? [];
    final codeLinesRaw = data['codeLines'] as List<dynamic>? ?? [];
    return PracticeQuestionModel(
      refId: docId,
      question: data['question'] as String? ?? '',
      options: optionsRaw.map((o) => o.toString()).toList(),
      correctIndex: data['correctIndex'] as int? ?? 0,
      codeHeader: data['codeHeader'] as String?,
      codeLanguage: data['codeLanguage'] as String?,
      codeLines: codeLinesRaw.map((l) => l.toString()).toList(),
    );
  }
}
