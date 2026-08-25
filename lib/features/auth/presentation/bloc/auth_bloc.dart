import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/observe_auth_state.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required ObserveAuthState observeAuthState,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
  }) : _observeAuthState = observeAuthState,
       _signInWithEmail = signInWithEmail,
       _signUpWithEmail = signUpWithEmail,
       _signInWithGoogle = signInWithGoogle,
       _signOut = signOut,
       super(const AuthState()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);

    _userSubscription = _observeAuthState(const NoParams()).listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  final ObserveAuthState _observeAuthState;
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;

  late final StreamSubscription<AppUser?> _userSubscription;

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
    final result = await _signInWithEmail(
      SignInEmailParams(email: event.email, password: event.password),
    );
    result.fold(_failureEmitter(emit), (_) {
      emit(state.copyWith(formStatus: AuthFormStatus.idle));
    });
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(formStatus: AuthFormStatus.submitting, clearError: true),
    );
    final result = await _signUpWithEmail(
      SignUpEmailParams(email: event.email, password: event.password),
    );
    result.fold(_failureEmitter(emit), (_) {
      emit(state.copyWith(formStatus: AuthFormStatus.idle));
    });
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(formStatus: AuthFormStatus.submitting, clearError: true),
    );
    final result = await _signInWithGoogle(const NoParams());
    result.fold(_failureEmitter(emit), (_) {
      emit(state.copyWith(formStatus: AuthFormStatus.idle));
    });
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _signOut(const NoParams());
  }

  void Function(Failure failure) _failureEmitter(Emitter<AuthState> emit) {
    return (failure) => emit(
      state.copyWith(
        formStatus: AuthFormStatus.failure,
        errorMessage: failure.message,
      ),
    );
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
