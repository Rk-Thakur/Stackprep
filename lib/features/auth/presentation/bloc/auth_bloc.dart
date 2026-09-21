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

  /// True while an account is being created. Firebase auto-authenticates a
  /// brand-new user the moment the account is created, which would otherwise
  /// bounce the user straight past the login form. We hold that off and sign
  /// the fresh user back out so they must explicitly sign in.
  bool _creatingAccount = false;

  late final StreamSubscription<AppUser?> _userSubscription;

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final loggedIn = event.user != null && !_creatingAccount;
    emit(
      state.copyWith(
        status: loggedIn
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        user: loggedIn ? event.user : null,
        clearUser: event.user == null || _creatingAccount,
        formStatus: AuthFormStatus.idle,
        // A real sign-in clears the "please sign in now" notice.
        justSignedUp: loggedIn ? false : null,
      ),
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        formStatus: AuthFormStatus.submitting,
        clearError: true,
        // A real sign-in attempt clears the post-signup "sign in now" notice
        // so it can't resurface on the login path (e.g. masking an error).
        justSignedUp: false,
      ),
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
    _creatingAccount = true;
    emit(
      state.copyWith(formStatus: AuthFormStatus.submitting, clearError: true),
    );
    final result = await _signUpWithEmail(
      SignUpEmailParams(email: event.email, password: event.password),
    );
    await result.fold<Future<void>>(
      (failure) async {
        _creatingAccount = false;
        emit(
          state.copyWith(
            formStatus: AuthFormStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) async {
        // Account created. Sign the auto-authenticated session out so the
        // user has to sign in with a matching email/password before the app
        // proceeds from the sign-in form.
        await _signOut(const NoParams());
        _creatingAccount = false;
        emit(
          state.copyWith(
            formStatus: AuthFormStatus.idle,
            justSignedUp: true,
          ),
        );
      },
    );
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
