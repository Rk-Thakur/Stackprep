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

/// In-memory stand-in so the bloc can boot without Firebase.
class _FakeAuthRepository implements AuthRepository {
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
      const Right(null);

  @override
  Future<Either<Failure, AppUser?>> signInWithGoogle() async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);
}

void main() {
  testWidgets('AuthPage renders the sign-in terminal', (tester) async {
    // The UI is designed against a 393x852 logical frame (see main.dart);
    // the default 800x600 test surface makes ScreenUtil scale up and
    // overflow rows that fit fine on a real device.
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repository = _FakeAuthRepository();
    final bloc = AuthBloc(
      observeAuthState: ObserveAuthState(repository),
      signInWithEmail: SignInWithEmail(repository),
      signUpWithEmail: SignUpWithEmail(repository),
      signInWithGoogle: SignInWithGoogle(repository),
      signOut: SignOut(repository),
    );

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

    expect(find.text('STACKPREP'), findsOneWidget);
    expect(find.text('USER_IDENTIFIER (Email)'), findsOneWidget);
    expect(find.text('AUTH_TOKEN (Password)'), findsOneWidget);
    expect(find.text('SIGN_IN'), findsOneWidget);
    expect(find.text('CREATE_ACCOUNT'), findsOneWidget);
  });
}
