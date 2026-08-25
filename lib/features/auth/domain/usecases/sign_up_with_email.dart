import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmail implements UseCase<AppUser?, SignUpEmailParams> {
  SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser?>> call(SignUpEmailParams params) =>
      _repository.signUpWithEmail(
        email: params.email,
        password: params.password,
      );
}

class SignUpEmailParams extends Equatable {
  const SignUpEmailParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
