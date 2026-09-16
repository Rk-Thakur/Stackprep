import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

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
    this.justSignedUp = false,
  });

  final AuthStatus status;
  final AuthFormStatus formStatus;
  final AppUser? user;
  final String? errorMessage;

  /// True right after an account is created, so the UI can pivot to the
  /// sign-in form and require the user to log in (instead of riding the
  /// auto-authenticated session Firebase creates at sign-up).
  final bool justSignedUp;

  AuthState copyWith({
    AuthStatus? status,
    AuthFormStatus? formStatus,
    AppUser? user,
    bool clearUser = false,
    String? errorMessage,
    bool clearError = false,
    bool? justSignedUp,
  }) {
    return AuthState(
      status: status ?? this.status,
      formStatus: formStatus ?? this.formStatus,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      justSignedUp: justSignedUp ?? this.justSignedUp,
    );
  }

  @override
  List<Object?> get props => [
    status,
    formStatus,
    user?.uid,
    errorMessage,
    justSignedUp,
  ];
}
