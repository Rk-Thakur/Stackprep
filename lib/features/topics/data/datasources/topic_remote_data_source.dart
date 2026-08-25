import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/topic.dart';
import '../../domain/entities/topic_module.dart';

/// Fetches topic data from the Firestore `topics` collection.
class TopicRemoteDataSource {
  TopicRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Fetches a single topic by its document ID.
  Future<Topic> getTopic(String topicId) async {
    try {
      final doc = await _firestore.collection('topics').doc(topicId).get();
      if (!doc.exists || doc.data() == null) {
        throw const CacheException('Topic not found.');
      }
      return _fromFirestore(doc.id, doc.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch topic.');
    }
  }

  /// Fetches all topics from the `topics` collection.
  Future<List<Topic>> getTopics() async {
    try {
      final snapshot = await _firestore.collection('topics').get();
      return snapshot.docs
          .map((doc) => _fromFirestore(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch topics.');
    }
  }

  Topic _fromFirestore(String docId, Map<String, dynamic> data) {
    final modulesRaw = data['modules'] as List<dynamic>? ?? [];
    return Topic(
      id: docId,
      level: data['level'] as String? ?? '',
      trackName: data['trackName'] as String? ?? '',
      trackColor: data['trackColor'] as int? ?? 0,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      modules: modulesRaw
          .map((m) => TopicModule(
                title: m['title'] as String? ?? '',
                description: m['description'] as String? ?? '',
                taskCount: m['taskCount'] as int? ?? 0,
                duration: m['duration'] as String? ?? '',
              ))
          .toList(),
    );
  }
}
