import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stackprep/core/error/failures.dart';
import 'package:stackprep/core/theme/app_theme.dart';
import 'package:stackprep/features/auth/domain/entities/app_user.dart';
import 'package:stackprep/features/auth/domain/repositories/auth_repository.dart';
import 'package:stackprep/features/auth/domain/usecases/observe_auth_state.dart';
import 'package:stackprep/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:stackprep/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:stackprep/features/auth/domain/usecases/sign_out.dart';
import 'package:stackprep/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:stackprep/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:stackprep/features/auth/presentation/pages/auth_page.dart';

/// In-memory stand-in so the bloc can boot without Firebase. `signInResult`
/// controls whether a login attempt succeeds or fails, so we can exercise the
/// post-signup "now sign in" path.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.signInResult = const Right(null)});

  final Either<Failure, AppUser?> signInResult;

  @override
  Stream<AppUser?> get authStateChanges => Stream.value(null);

  @override
  AppUser? get currentUser => null;

  @override
  Future<Either<Failure, AppUser?>> signUpWithEmail({
    required String email,
    required String password,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, AppUser?>> signInWithEmail({
    required String email,
    required String password,
  }) async =>
      signInResult;

  @override
  Future<Either<Failure, AppUser?>> signInWithGoogle() async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);
}

Future<AuthBloc> _pumpAuth(
  WidgetTester tester,
  AuthRepository repository,
) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final bloc = AuthBloc(
    observeAuthState: ObserveAuthState(repository),
    signInWithEmail: SignInWithEmail(repository),
    signUpWithEmail: SignUpWithEmail(repository),
    signInWithGoogle: SignInWithGoogle(repository),
    signOut: SignOut(repository),
  );
  addTearDown(bloc.close);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        theme: AppTheme.dark,
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const AuthPage(),
        ),
      ),
    ),
  );
  await tester.pump();
  return bloc;
}

Future<void> _fillCredentials(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(find.byType(TextField).at(0), email);
  await tester.enterText(find.byType(TextField).at(1), password);
}

void main() {
  testWidgets(
    'failed login after signup shows the error, not the account notice',
    (tester) async {
      await _pumpAuth(
        tester,
        _FakeAuthRepository(
          signInResult: const Left(ServerFailure('Incorrect email or password.')),
        ),
      );

      await tester.tap(find.text('CREATE_ACCOUNT'));
      await tester.pump();
      await _fillCredentials(
        tester,
        email: 'dev@stackprep.app',
        password: 'hunter22',
      );
      await tester.tap(find.text('[CREATE_ACCOUNT]'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.textContaining('ACCOUNT_CREATED'),
        findsOneWidget,
        reason: 'creating an account should show the sign-in-now notice',
      );

      await tester.pump(const Duration(seconds: 5));
      await _fillCredentials(
        tester,
        email: 'dev@stackprep.app',
        password: 'wrong-password',
      );
      await tester.tap(find.text('[EXECUTE_LOGIN]'));
      await tester.pump();
      // The post-signup "ACCOUNT_CREATED" snackbar is still animating out
      // (4s duration + exit animation), so the incoming error snackbar is
      // queued behind it. Pump past the exit animation so it enters the tree.
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.textContaining('Incorrect email or password.'),
        findsOneWidget,
        reason: 'a failed login must surface the actual error',
      );
      expect(
        find.textContaining('ACCOUNT_CREATED'),
        findsNothing,
        reason: 'the post-signup notice must not resurface on the login path',
      );
    },
  );
}