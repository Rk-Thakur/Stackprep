import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_user.dart';

/// Auth contract owned by the domain layer; implemented in the data layer.
abstract interface class AuthRepository {
  /// Emits the current [AppUser] whenever Firebase's auth state changes.
  Stream<AppUser?> get authStateChanges;

  AppUser? get currentUser;

  Future<Either<Failure, AppUser?>> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser?>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Resolves quietly (Right(null)) when the user cancels Google's picker —
  /// that's not a failure worth surfacing.
  Future<Either<Failure, AppUser?>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();
}
