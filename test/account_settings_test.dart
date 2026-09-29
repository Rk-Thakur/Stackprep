import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackprep/core/error/failures.dart';
import 'package:stackprep/core/storage/theme_store.dart';
import 'package:stackprep/core/theme/app_colors.dart';
import 'package:stackprep/core/theme/app_theme.dart';
import 'package:stackprep/core/theme/app_theme_scope.dart';
import 'package:stackprep/core/theme/theme_cubit.dart';
import 'package:stackprep/features/auth/domain/entities/app_user.dart';
import 'package:stackprep/features/auth/domain/repositories/auth_repository.dart';
import 'package:stackprep/features/auth/domain/usecases/observe_auth_state.dart';
import 'package:stackprep/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:stackprep/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:stackprep/features/auth/domain/usecases/sign_out.dart';
import 'package:stackprep/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:stackprep/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:stackprep/features/profile/presentation/pages/account_settings_page.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<AppUser?> get authStateChanges => Stream.value(null);

  @override
  AppUser? get currentUser => null;

  @override
  Future<Either<Failure, AppUser?>> signUpWithEmail({
    required String email,
    required String password,
  }) async => const Right(null);

  @override
  Future<Either<Failure, AppUser?>> signInWithEmail({
    required String email,
    required String password,
  }) async => const Right(null);

  @override
  Future<Either<Failure, AppUser?>> signInWithGoogle() async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);

  @override
  Future<Either<Failure, void>> deleteAccount() async => const Right(null);
}

/// Pumps the settings page inside a stand-in app root that mirrors
/// `main.dart`: repoints the palette and publishes the theme scope.
Future<ThemeCubit> _pumpSettings(WidgetTester tester) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  addTearDown(() => AppColors.brightness = Brightness.dark);

  SharedPreferences.setMockInitialValues({});
  final store = ThemeStore(prefs: await SharedPreferences.getInstance());
  final themeCubit = ThemeCubit(
    store: store,
    platformBrightness: Brightness.dark,
  );
  addTearDown(themeCubit.close);

  final repository = _FakeAuthRepository();
  final authBloc = AuthBloc(
    observeAuthState: ObserveAuthState(repository),
    signInWithEmail: SignInWithEmail(repository),
    signUpWithEmail: SignUpWithEmail(repository),
    signInWithGoogle: SignInWithGoogle(repository),
    signOut: SignOut(repository),
  );
  addTearDown(authBloc.close);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<ThemeCubit>.value(value: themeCubit),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, theme) {
            AppColors.brightness = theme.brightness;
            return MaterialApp(
              theme: theme.brightness == Brightness.dark
                  ? AppTheme.dark
                  : AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: theme.mode,
              // Mirrors main.dart: the scope sits above the Navigator, so
              // pages are routes beneath it.
              builder: (context, child) => AppThemeScope(
                generation: theme.generation,
                brightness: theme.brightness,
                child: child ?? const SizedBox.shrink(),
              ),
              home: const AccountSettingsPage(),
            );
          },
        ),
      ),
    ),
  );
  await tester.pump();
  return themeCubit;
}

void main() {
  testWidgets('Clear Cache is gone from the settings list', (tester) async {
    await _pumpSettings(tester);
    expect(find.text('Clear Cache'), findsNothing);
    expect(find.text('14.2 MB'), findsNothing);
  });

  testWidgets('Export Data is present and describes the PDF', (tester) async {
    await _pumpSettings(tester);
    expect(find.text('Export Data'), findsOneWidget);
    expect(find.text('Save your progress as a PDF report'), findsOneWidget);
  });

  testWidgets('Theme row explains that the default follows the device', (
    tester,
  ) async {
    await _pumpSettings(tester);
    expect(find.text('Follows your device setting'), findsOneWidget);
  });

  testWidgets('tapping Theme opens a picker with all three options', (
    tester,
  ) async {
    await _pumpSettings(tester);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();

    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('choosing Light switches the palette and persists the choice', (
    tester,
  ) async {
    final cubit = await _pumpSettings(tester);
    expect(AppColors.brightness, Brightness.dark);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    expect(cubit.state.mode, ThemeMode.light);
    expect(cubit.state.brightness, Brightness.light);
    expect(AppColors.brightness, Brightness.light);
    expect(AppColors.surface, AppLightPalette.surface);

    // The sheet closes and the row now reports the explicit choice.
    expect(find.text('APPEARANCE'), findsNothing);
    expect(find.text('Always light'), findsOneWidget);
  });

  testWidgets('choosing Dark keeps the dark palette', (tester) async {
    final cubit = await _pumpSettings(tester);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(cubit.state.mode, ThemeMode.dark);
    expect(AppColors.brightness, Brightness.dark);
    expect(find.text('Always dark'), findsOneWidget);
  });

  testWidgets('choosing System hands control back to the device', (
    tester,
  ) async {
    final cubit = await _pumpSettings(tester);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();

    expect(cubit.state.mode, ThemeMode.system);
    expect(find.text('Follows your device setting'), findsOneWidget);
  });

  testWidgets('cancelling the picker leaves the theme untouched', (
    tester,
  ) async {
    final cubit = await _pumpSettings(tester);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(cubit.state.mode, ThemeMode.system);
    expect(find.text('APPEARANCE'), findsNothing);
  });

  testWidgets('the selection survives a relaunch via the stored preference', (
    tester,
  ) async {
    final cubit = await _pumpSettings(tester);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    // Simulate a cold start reading the persisted choice back.
    final relaunched = ThemeCubit(
      store: ThemeStore(prefs: await SharedPreferences.getInstance()),
      platformBrightness: Brightness.dark,
    );
    addTearDown(relaunched.close);
    expect(relaunched.state.mode, ThemeMode.light);
    expect(cubit.state.mode, ThemeMode.light);
  });

  testWidgets('switching theme does not discard the edited username', (
    tester,
  ) async {
    await _pumpSettings(tester);

    Future<void> editUsernameTo(String name) async {
      await tester.tap(find.text('Edit Username'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), name);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
    }

    await editUsernameTo('ada_l');

    // Change the theme: the keyed subtree is rebuilt, but the page's own State
    // sits above `Themed`, so the edit must survive.
    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit Username'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'ada_l',
    );
  });

  testWidgets('Delete Account asks for confirmation before doing anything', (
    tester,
  ) async {
    await _pumpSettings(tester);

    // The button lives at the bottom of a scroll view, past the preference rows.
    await tester.scrollUntilVisible(find.text('Delete Account'), 200);
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    expect(find.text('DELETE ACCOUNT'), findsOneWidget);
    expect(find.text('Type DELETE to confirm'), findsOneWidget);
  });

  testWidgets('cancelling the confirmation deletes nothing', (tester) async {
    await _pumpSettings(tester);

    await tester.scrollUntilVisible(find.text('Delete Account'), 200);
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('DELETE ACCOUNT'), findsNothing);
    // Still on the settings page with the button usable again, which also means
    // the deletion was never started.
    expect(find.text('DANGER ZONE'), findsOneWidget);
    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Delete Account'),
    );
    expect(button.onPressed, isNotNull);
  });
}
