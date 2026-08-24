import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);

    _userSubscription = _authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<User?> _userSubscription;

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        status: event.user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        user: event.user,
        clearUser: event.user == null,
        formStatus: AuthFormStatus.idle,
      ),
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(formStatus: AuthFormStatus.submitting, clearError: true),
    );
    try {
      await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(formStatus: AuthFormStatus.idle));
    } on AuthFailure catch (e) {
      emit(
        state.copyWith(
          formStatus: AuthFormStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(formStatus: AuthFormStatus.submitting, clearError: true),
    );
    try {
      await _authRepository.signUpWithEmail(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(formStatus: AuthFormStatus.idle));
    } on AuthFailure catch (e) {
      emit(
        state.copyWith(
          formStatus: AuthFormStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(formStatus: AuthFormStatus.submitting, clearError: true),
    );
    try {
      await _authRepository.signInWithGoogle();
      emit(state.copyWith(formStatus: AuthFormStatus.idle));
    } on AuthFailure catch (e) {
      emit(
        state.copyWith(
          formStatus: AuthFormStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
