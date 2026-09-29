import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stackprep/core/error/failures.dart';
import 'package:stackprep/core/theme/app_colors.dart';
import 'package:stackprep/core/theme/app_theme.dart';
import 'package:stackprep/core/theme/app_theme_scope.dart';
import 'package:stackprep/core/usecases/usecase.dart';
import 'package:stackprep/features/onboarding/domain/entities/stack_track.dart';
import 'package:stackprep/features/onboarding/domain/usecases/get_stack_tracks.dart';
import 'package:stackprep/features/profile/presentation/pages/learning_stats_page.dart';
import 'package:stackprep/features/progress/domain/entities/focus_area.dart';
import 'package:stackprep/features/progress/domain/entities/progress_overview.dart';
import 'package:stackprep/features/progress/domain/entities/readiness_summary.dart';
import 'package:stackprep/features/progress/domain/entities/track_competency.dart';
import 'package:stackprep/features/progress/domain/repositories/progress_repository.dart';
import 'package:stackprep/features/progress/domain/usecases/get_progress_overview.dart';
import 'package:stackprep/features/progress/presentation/cubit/progress_cubit.dart';
import 'package:stackprep/injection_container.dart' show sl;

class _FakeProgressRepository implements ProgressRepository {
  _FakeProgressRepository({this.overview, this.failure});

  final ProgressOverview? overview;
  final Failure? failure;

  @override
  Future<Either<Failure, ProgressOverview>> getProgressOverview() async =>
      failure != null ? Left(failure!) : Right(overview!);

  @override
  Future<Either<Failure, List<StackTrack>>> getTracks() async =>
      const Right(<StackTrack>[]);

  @override
  Future<Either<Failure, void>> recordAttempt({
    required String trackId,
    String? moduleId,
    String? moduleTitle,
    required String type,
    required int correct,
    required int total,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> markModuleViewed({
    required String trackId,
    required String moduleId,
  }) async => const Right(null);
}

class _EmptyGetStackTracks implements GetStackTracks {
  @override
  Future<Either<Failure, List<StackTrack>>> call(NoParams params) async =>
      const Right(<StackTrack>[]);
}

ProgressOverview _overview({List<int>? activity}) => ProgressOverview(
  summary: ReadinessSummary(
    currentStreakDays: 12,
    totalSessions: 87,
    readinessScore: 0.72,
    globalReadinessScore: 0.64,
    targetScore: 0.9,
    activityLevels: activity ?? List.filled(84, 0)
      ..[80] = 3,
  ),
  competencies: const [
    TrackCompetency(
      trackId: 'flutter',
      score: 82,
      level: 'Intermediate',
      modulesCompleted: 9,
      modulesTotal: 12,
    ),
    TrackCompetency(
      trackId: 'dart',
      score: 55,
      level: 'Beginner',
      modulesCompleted: 4,
      modulesTotal: 10,
    ),
  ],
  focusAreas: const [
    FocusArea(
      title: 'Isolates & concurrency',
      percent: 0.31,
      trend: TrendDirection.up,
      trendLabel: '+4% this week',
      critical: true,
    ),
  ],
);

/// Registers a cubit backed by [repository] and pumps the stats page.
Future<void> _pumpStats(
  WidgetTester tester, {
  required _FakeProgressRepository repository,
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  addTearDown(() => AppColors.brightness = Brightness.dark);

  final cubit = ProgressCubit(
    getProgressOverview: GetProgressOverview(repository: repository),
    repository: repository,
    getStackTracks: _EmptyGetStackTracks(),
  );
  addTearDown(() async {
    await cubit.close();
    await sl.unregister<ProgressCubit>();
  });
  sl.registerSingleton<ProgressCubit>(cubit);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp(
        theme: AppTheme.dark,
        home: const AppThemeScope(
          generation: 0,
          brightness: Brightness.dark,
          child: LearningStatsPage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the headline numbers from real progress data', (
    tester,
  ) async {
    await _pumpStats(
      tester,
      repository: _FakeProgressRepository(overview: _overview()),
    );

    expect(find.text('Learning Stats'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('87'), findsOneWidget);
    // 9 + 4 modules completed across both tracks.
    expect(find.text('13'), findsOneWidget);
    expect(find.text('of 22'), findsOneWidget);
    expect(find.text('64%'), findsWidgets);
  });

  testWidgets('breaks progress down per track', (tester) async {
    await _pumpStats(
      tester,
      repository: _FakeProgressRepository(overview: _overview()),
    );

    expect(find.text('TRACK_BREAKDOWN'), findsOneWidget);
    // The catalog is empty in tests, so the raw track id stands in for a name.
    expect(find.text('flutter'), findsOneWidget);
    expect(find.text('dart'), findsOneWidget);
    expect(find.text('9/12'), findsOneWidget);
    expect(find.text('4/10'), findsOneWidget);
  });

  testWidgets('surfaces the weakest areas with their trend', (tester) async {
    await _pumpStats(
      tester,
      repository: _FakeProgressRepository(overview: _overview()),
    );

    expect(find.text('NEEDS_ATTENTION'), findsOneWidget);
    expect(find.text('Isolates & concurrency'), findsOneWidget);
    expect(find.text('+4% this week'), findsOneWidget);
    expect(find.text('CRITICAL'), findsOneWidget);
    expect(find.text('31%'), findsOneWidget);
  });

  testWidgets('describes the activity grid in words', (tester) async {
    await _pumpStats(
      tester,
      repository: _FakeProgressRepository(
        overview: _overview(activity: List.filled(84, 0)..[80] = 3),
      ),
    );

    expect(find.text('Active on 1 of the last 84 days.'), findsOneWidget);
  });

  testWidgets('says so plainly when there is no activity yet', (tester) async {
    await _pumpStats(
      tester,
      repository: _FakeProgressRepository(
        overview: _overview(activity: List.filled(84, 0)),
      ),
    );

    expect(find.text('No activity recorded yet.'), findsOneWidget);
  });

  testWidgets('reports a load failure instead of showing zeroes', (
    tester,
  ) async {
    await _pumpStats(
      tester,
      repository: _FakeProgressRepository(
        failure: CacheFailure('Could not reach Firestore.'),
      ),
    );

    expect(find.text('Stats unavailable'), findsOneWidget);
    expect(find.text('Could not reach Firestore.'), findsOneWidget);
  });
}
