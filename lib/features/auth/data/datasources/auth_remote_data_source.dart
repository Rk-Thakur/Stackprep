import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';

/// Firebase Auth + Google Sign-In wrapper. Throws [ServerException] (or
/// subclasses) so the repository can translate them into failures without
/// leaking provider types upward.
abstract interface class AuthRemoteDataSource {
  Stream<fb.User?> get authStateChanges;

  fb.User? get currentUser;

  Future<fb.User> signUpWithEmail({required String email, required String password});

  Future<fb.User> signInWithEmail({required String email, required String password});

  /// Returns null when the user cancels the Google account picker.
  Future<fb.User?> signInWithGoogle();

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({fb.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _firebaseAuth;
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
      return credential.user!;
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
      return credential.user!;
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
      return userCredential.user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw ServerException('Google sign-in failed: ${e.description ?? e.code}');
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
      default:
        return 'Authentication failed ($code).';
    }
  }
}
