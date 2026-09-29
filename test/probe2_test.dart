import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stackprep/core/error/failures.dart';
import 'package:stackprep/core/theme/app_theme.dart';
import 'package:stackprep/core/usecases/usecase.dart';
import 'package:stackprep/features/onboarding/domain/entities/stack_track.dart';
import 'package:stackprep/features/onboarding/domain/usecases/get_stack_tracks.dart';
import 'package:stackprep/features/profile/presentation/pages/learning_stats_page.dart';
import 'package:stackprep/features/progress/domain/entities/progress_overview.dart';
import 'package:stackprep/features/progress/domain/entities/readiness_summary.dart';
import 'package:stackprep/features/progress/domain/repositories/progress_repository.dart';
import 'package:stackprep/features/progress/domain/usecases/get_progress_overview.dart';
import 'package:stackprep/features/progress/presentation/cubit/progress_cubit.dart';
import 'package:stackprep/injection_container.dart' show sl;

class _Repo implements ProgressRepository {
  @override
  Future<Either<Failure, ProgressOverview>> getProgressOverview() async =>
      const Left(CacheFailure('nope'));
  @override
  Future<Either<Failure, List<StackTrack>>> getTracks() async =>
      const Right(<StackTrack>[]);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Tracks implements GetStackTracks {
  @override
  Future<Either<Failure, List<StackTrack>>> call(NoParams p) async =>
      const Right(<StackTrack>[]);
}

void main() {
  testWidgets('probe2: page builds with pump only', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final repo = _Repo();
    final cubit = ProgressCubit(
      getProgressOverview: GetProgressOverview(repository: repo),
      repository: repo,
      getStackTracks: _Tracks(),
    );
    sl.registerSingleton<ProgressCubit>(cubit);
    addTearDown(() async {
      await cubit.close();
      await sl.unregister<ProgressCubit>();
    });
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (context, _) => MaterialApp(
          theme: AppTheme.dark,
          home: const LearningStatsPage(),
        ),
      ),
    );
    await tester.pump();
    debugPrint('PROBE: pumped once');
    await tester.pump(const Duration(milliseconds: 100));
    debugPrint('PROBE: pumped twice');
    expect(find.text('Learning Stats'), findsOneWidget);
  });
}
