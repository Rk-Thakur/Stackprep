import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Internal: fired whenever Firebase's own auth state stream changes.
class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);

  final AppUser? user;

  @override
  List<Object?> get props => [user];
}

class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
