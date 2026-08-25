import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

/// Translates data-source exceptions into [Failure]s so no provider type
/// or exception escapes the data layer.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<AppUser?> get authStateChanges =>
      _remoteDataSource.authStateChanges.map(_mapUser);

  @override
  AppUser? get currentUser => _mapUser(_remoteDataSource.currentUser);

  @override
  Future<Either<Failure, AppUser?>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
      );
      return Right(UserModel.fromFirebase(user).toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Authentication failed.'));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      return Right(UserModel.fromFirebase(user).toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Authentication failed.'));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> signInWithGoogle() async {
    try {
      final user = await _remoteDataSource.signInWithGoogle();
      return Right(user == null ? null : UserModel.fromFirebase(user).toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Google sign-in failed.'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Could not sign out.'));
    }
  }

  AppUser? _mapUser(fb.User? user) =>
      user == null ? null : UserModel.fromFirebase(user).toEntity();
}
