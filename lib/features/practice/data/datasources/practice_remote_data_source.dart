import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../models/practice_question_model.dart';

/// Fetches practice questions from Firestore. Each topic stores its
/// questions in a sub-collection: `topics/{topicId}/questions/`.
abstract interface class PracticeRemoteDataSource {
  Future<List<PracticeQuestionModel>> getQuestions({required String topicCode});
}

class PracticeFirestoreDataSourceImpl implements PracticeRemoteDataSource {
  PracticeFirestoreDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<List<PracticeQuestionModel>> getQuestions({
    required String topicCode,
  }) async {
    if (topicCode.isEmpty) {
      throw const CacheException('Topic code is required.');
    }
    try {
      final snapshot = await _firestore
          .collection('topics')
          .doc(topicCode)
          .collection('questions')
          .get();
      return snapshot.docs
          .map((doc) => _fromFirestore(doc.id, doc.data()))
          .toList();
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
