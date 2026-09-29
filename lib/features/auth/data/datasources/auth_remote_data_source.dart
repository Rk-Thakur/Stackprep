import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';

/// Firebase Auth + Google Sign-In wrapper. Throws [ServerException] (or
/// subclasses) so the repository can translate them into failures without
/// leaking provider types upward.
abstract interface class AuthRemoteDataSource {
  Stream<fb.User?> get authStateChanges;

  fb.User? get currentUser;

  Future<fb.User> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<fb.User> signInWithEmail({
    required String email,
    required String password,
  });

  /// Returns null when the user cancels the Google account picker.
  Future<fb.User?> signInWithGoogle();

  Future<void> signOut();

  /// Erases the signed-in account for good: the `users/{uid}` document and all
  /// of its subcollections, then the Firebase Auth record itself. Throws
  /// [ServerException] if any step fails.
  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  Future<void>? _googleSignInInit;

  @override
  Stream<fb.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  fb.User? get currentUser => _firebaseAuth.currentUser;

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInit ??= GoogleSignIn.instance.initialize();
  }

  @override
  Future<fb.User> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await _pushUserToFirestore(user);
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw ServerException(_messageForCode(e.code));
    }
  }

  @override
  Future<fb.User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await _pushUserToFirestore(user);
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw ServerException(_messageForCode(e.code));
    }
  }

  @override
  Future<fb.User?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const ServerException(
          'Google sign-in did not return an identity token.',
        );
      }
      final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user != null) {
        await _pushUserToFirestore(user);
      }
      return user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw ServerException(
        'Google sign-in failed: ${e.description ?? e.code}',
      );
    } on fb.FirebaseAuthException catch (e) {
      throw ServerException(_messageForCode(e.code));
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (_googleSignInInit != null) {
      await GoogleSignIn.instance.signOut();
    }
  }

  /// The subcollections hanging off `users/{uid}` that hold user-owned data.
  /// `progress/overview` is a single fixed document; the rest grow per day or
  /// per attempt, which is why they need paging rather than a known id.
  static const List<String> _userSubcollections = [
    'progress',
    'moduleProgress',
    'activityDaily',
    'attempts',
  ];

  /// Firestore caps a batch at 500 operations, so deletes are chunked to stay
  /// well under it.
  static const int _deleteBatchSize = 400;

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const ServerException('There is no signed-in account to delete.');
    }

    try {
      // Firestore has no cascading delete and this client version has no
      // recursiveDelete helper, so every subcollection is emptied first. This
      // deliberately leaves the shared `tracks/` catalog alone: those documents
      // belong to the curriculum, not to this user.
      final userDoc = _firestore.collection('users').doc(user.uid);
      for (final name in _userSubcollections) {
        await _deleteSubcollection(userDoc.collection(name));
      }
      await userDoc.delete();

      // Last, because it ends the session the Firestore rules authenticate
      // against, and because leaving the Auth record behind would let the same
      // sign-in recreate `users/{uid}` via _pushUserToFirestore.
      await user.delete();
    } on fb.FirebaseAuthException catch (e) {
      throw ServerException(_messageForCode(e.code));
    } on FirebaseException {
      throw const ServerException(
        'Could not delete your data. Check your connection and try again.',
      );
    }

    if (_googleSignInInit != null) {
      await GoogleSignIn.instance.signOut();
    }
  }

  Future<void> _deleteSubcollection(
    Query<Map<String, dynamic>> collection,
  ) async {
    final snapshot = await collection.get();
    final docs = snapshot.docs;
    for (var i = 0; i < docs.length; i += _deleteBatchSize) {
      final batch = _firestore.batch();
      for (final doc in docs.skip(i).take(_deleteBatchSize)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  /// Upserts the base `users/{uid}` profile whenever a user signs up or signs
  /// in, so the account exists in Firestore even before onboarding fills in
  /// the tracks/runtime level (which the onboarding write merges on top).
  ///
  /// Never throws: a failed profile write shouldn't fail the authentication
  /// itself — the user is still signed in.
  Future<void> _pushUserToFirestore(fb.User user) async {
    try {
      final data = <String, dynamic>{
        'userId': user.uid,
        'userEmail': user.email,
        'displayName': user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
        'authProvider': user.providerData.isNotEmpty
            ? user.providerData[0].providerId
            : 'unknown',
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));
    } on FirebaseException {
      // Deliberately swallow — auth still succeeded.
    }
  }

  String _messageForCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Choose a stronger password (6+ characters).';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled for this project.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'requires-recent-login':
        return 'For your security, sign in again before deleting your account.';
      default:
        return 'Authentication failed ($code).';
    }
  }
}
