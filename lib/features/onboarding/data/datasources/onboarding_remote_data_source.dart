import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';

/// Persists the onboarding result to Firestore so the backend knows who
/// selected which stacks and at which runtime level.
abstract interface class OnboardingRemoteDataSource {
  /// Writes/merges `users/{uid}` with the user's id, selected track ids and
  /// runtime level. Requires a signed-in Firebase user.
  Future<void> saveUserProfile({
    required List<String> trackIds,
    required String runtimeLevelId,
  });
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  OnboardingRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  @override
  Future<void> saveUserProfile({
    required List<String> trackIds,
    required String runtimeLevelId,
  }) async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const ServerException('No signed-in user to save a profile for.');
    }
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'userId': user.uid,
        'userEmail': user.email,
        'tracks': trackIds,
        'runtimeLevel': runtimeLevelId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to save profile.');
    }
  }
}
