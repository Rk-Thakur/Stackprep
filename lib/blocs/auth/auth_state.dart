import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Ambient "am I logged in" status, driven by Firebase's auth state stream —
/// the source of truth for whether the app should navigate past the auth
/// screen.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Status of whatever sign-in/sign-up action is currently in flight, kept
/// separate from [AuthStatus] so a failed attempt doesn't get confused with
/// "not logged in yet".
enum AuthFormStatus { idle, submitting, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.formStatus = AuthFormStatus.idle,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthFormStatus formStatus;
  final User? user;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthFormStatus? formStatus,
    User? user,
    bool clearUser = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      formStatus: formStatus ?? this.formStatus,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, formStatus, user?.uid, errorMessage];
}
