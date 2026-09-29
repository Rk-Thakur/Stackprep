import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackprep/core/error/failures.dart';
import 'package:stackprep/core/storage/daily_challenge_store.dart';
import 'package:stackprep/core/theme/app_colors.dart';
import 'package:stackprep/core/theme/app_theme.dart';
import 'package:stackprep/core/usecases/usecase.dart';
import 'package:stackprep/features/auth/domain/entities/app_user.dart';
import 'package:stackprep/features/auth/domain/repositories/auth_repository.dart';
import 'package:stackprep/features/auth/domain/usecases/delete_account.dart';
import 'package:stackprep/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:stackprep/features/onboarding/domain/entities/onboarding_summary.dart';
import 'package:stackprep/features/onboarding/domain/entities/runtime_level.dart';
import 'package:stackprep/features/onboarding/domain/entities/stack_track.dart';
import 'package:stackprep/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:stackprep/features/profile/presentation/widgets/delete_account_confirm_dialog.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.deleteResult});

  /// Left when the remote wipe should be reported as failed.
  final Failure? deleteResult;
  int deleteCalls = 0;

  @override
  Stream<AppUser?> get authStateChanges => Stream.value(null);

  @override
  AppUser? get currentUser => null;

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    deleteCalls++;
    return deleteResult == null ? const Right(null) : Left(deleteResult!);
  }

  @override
  Future<Either<Failure, AppUser?>> signInWithEmail({
    required String email,
    required String password,
  }) async => const Right(null);

  @override
  Future<Either<Failure, AppUser?>> signInWithGoogle() async =>
      const Right(null);

  @override
  Future<Either<Failure, AppUser?>> signUpWithEmail({
    required String email,
    required String password,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);
}

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({this.clearResult});

  final Failure? clearResult;
  int clearCalls = 0;

  @override
  Future<Either<Failure, void>> clearAccountData() async {
    clearCalls++;
    return clearResult == null ? const Right(null) : Left(clearResult!);
  }

  @override
  List<StackTrack> getStackTracks() => const [];

  @override
  List<RuntimeLevel> getRuntimeLevels() => const [];

  @override
  Future<Either<Failure, OnboardingSummary>> completeOnboarding({
    required List<String> trackIds,
    required String runtimeLevelId,
  }) async => const Right(
    OnboardingSummary(
      selectedTracks: [],
      runtimeLevel: RuntimeLevel(
        id: 'mid',
        title: 'Mid',
        description: 'Ships features end to end.',
        focus: 'Shipping features',
      ),
    ),
  );

  @override
  Future<Either<Failure, void>> syncProfileToRemote({
    required List<String> trackIds,
    required String runtimeLevelId,
  }) async => const Right(null);
}

Future<DailyChallengeStore> _storeWithHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final store = DailyChallengeStore(prefs: prefs);
  await store.markDoneToday(DateTime(2026, 9, 27));
  await store.markDoneToday(DateTime(2026, 9, 28));
  return store;
}

DeleteAccount _useCase(
  _FakeAuthRepository auth,
  _FakeOnboardingRepository onboarding,
  DailyChallengeStore daily,
) => DeleteAccount(
  authRepository: auth,
  onboardingRepository: onboarding,
  dailyChallengeStore: daily,
);

void main() {
  group('DeleteAccount', () {
    test('wipes the account and the local copies on success', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = _FakeAuthRepository();
      final onboarding = _FakeOnboardingRepository();
      final daily = await _storeWithHistory();

      final result = await _useCase(auth, onboarding, daily)(const NoParams());

      expect(result.isRight(), isTrue);
      expect(auth.deleteCalls, 1);
      expect(onboarding.clearCalls, 1);
      expect(daily.isDoneToday(DateTime(2026, 9, 27)), isFalse);
      expect(daily.isDoneToday(DateTime(2026, 9, 28)), isFalse);
    });

    test(
      'reports the failure and keeps local data when the wipe fails',
      () async {
        SharedPreferences.setMockInitialValues({});
        final auth = _FakeAuthRepository(
          deleteResult: const ServerFailure('Network error.'),
        );
        final onboarding = _FakeOnboardingRepository();
        final daily = await _storeWithHistory();

        final result = await _useCase(auth, onboarding, daily)(
          const NoParams(),
        );

        // Signing the user out while their data survived would strand it
        // somewhere they can no longer reach, so the local copy is left intact.
        expect(result.isLeft(), isTrue);
        expect(result.fold((f) => f.message, (_) => ''), 'Network error.');
        expect(onboarding.clearCalls, 0);
        expect(daily.isDoneToday(DateTime(2026, 9, 27)), isTrue);
      },
    );

    test('still succeeds when the local clear fails', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = _FakeAuthRepository();
      final onboarding = _FakeOnboardingRepository(
        clearResult: const CacheFailure('nope'),
      );
      final daily = await _storeWithHistory();

      final result = await _useCase(auth, onboarding, daily)(const NoParams());

      // The account is already gone remotely, so a stale key on this device is
      // not worth failing the deletion over.
      expect(result.isRight(), isTrue);
      expect(onboarding.clearCalls, 1);
    });
  });

  group('OnboardingLocalDataSourceImpl.clearAccountData', () {
    test('drops the selected tracks and the completion flag', () async {
      SharedPreferences.setMockInitialValues({});
      final source = OnboardingLocalDataSourceImpl(
        prefs: await SharedPreferences.getInstance(),
      );
      await source.setOnboardingCompleted();
      await source.saveSelections(
        trackIds: const ['KOTLIN', 'SWIFT'],
        runtimeLevelId: 'senior',
      );

      await source.clearAccountData();

      expect(source.isOnboardingCompleted(), isFalse);
      expect(source.selectedTrackIds, isEmpty);
      expect(source.selectedRuntimeLevel, 'mid');
    });

    test('forgets the in-memory onboarding summary', () async {
      SharedPreferences.setMockInitialValues({});
      final source = OnboardingLocalDataSourceImpl(
        prefs: await SharedPreferences.getInstance(),
      );
      source.savedSummary = OnboardingSummary(
        selectedTracks: const [],
        runtimeLevel: const RuntimeLevel(
          id: 'mid',
          title: 'Mid',
          description: 'Ships features end to end.',
          focus: 'Shipping features',
        ),
      );

      await source.clearAccountData();

      expect(source.savedSummary, isNull);
    });
  });

  group('DailyChallengeStore.clearHistory', () {
    test('removes every recorded day and leaves other keys alone', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final prefs = await SharedPreferences.getInstance();
      final store = DailyChallengeStore(prefs: prefs);
      await store.markDoneToday(DateTime(2026, 9, 26));
      await store.markDoneToday(DateTime(2026, 9, 27));

      await store.clearHistory();

      expect(store.isDoneToday(DateTime(2026, 9, 26)), isFalse);
      expect(prefs.getString('theme_mode'), 'dark');
    });
  });

  group('DeleteAccountConfirmDialog', () {
    Future<void> pumpDialog(WidgetTester tester) async {
      // Matches main.dart's design size; the default 800x600 test surface makes
      // ScreenUtil scale up and overflow rows that fit on a real device.
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, _) => MaterialApp(
            theme: AppTheme.dark,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => DeleteAccountConfirmDialog.show(
                      context,
                      email: 'ada@example.com',
                    ),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      AppColors.brightness = Brightness.dark;
      addTearDown(() => AppColors.brightness = Brightness.dark);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('keeps the delete button disabled until DELETE is typed', (
      tester,
    ) async {
      await pumpDialog(tester);

      final button = find.widgetWithText(ElevatedButton, 'Delete permanently');
      expect(tester.widget<ElevatedButton>(button).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'nope');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(button).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
    });

    testWidgets('accepts the word in any case', (tester) async {
      await pumpDialog(tester);

      await tester.enterText(find.byType(TextField), '  delete  ');
      await tester.pump();

      final button = find.widgetWithText(ElevatedButton, 'Delete permanently');
      expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
    });

    testWidgets('lists what is being destroyed and names the account', (
      tester,
    ) async {
      await pumpDialog(tester);

      expect(find.text('Confirming for ada@example.com'), findsOneWidget);
      expect(
        find.text(
          'Every track you selected, on this device and in the backend',
        ),
        findsOneWidget,
      );
    });

    testWidgets('cancelling resolves false and deletes nothing', (
      tester,
    ) async {
      bool? outcome;
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, _) => MaterialApp(
            theme: AppTheme.dark,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      outcome = await DeleteAccountConfirmDialog.show(context);
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(outcome, isFalse);
    });
  });
}
