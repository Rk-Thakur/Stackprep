import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/onboarding_summary.dart';
import '../../domain/entities/runtime_level.dart';
import '../../domain/entities/stack_track.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_data_source.dart';
import '../datasources/onboarding_remote_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({
    required OnboardingLocalDataSource localDataSource,
    required OnboardingRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  final OnboardingLocalDataSource _localDataSource;
  final OnboardingRemoteDataSource _remoteDataSource;

  @override
  List<StackTrack> getStackTracks() => _localDataSource.stackTracks;

  @override
  List<RuntimeLevel> getRuntimeLevels() => _localDataSource.runtimeLevels;

  @override
  Future<Either<Failure, OnboardingSummary>> completeOnboarding({
    required List<String> trackIds,
    required String runtimeLevelId,
  }) async {
    try {
      if (trackIds.isEmpty) {
        throw const CacheException('Select at least one track.');
      }
      final tracks = _localDataSource.stackTracks
          .where((track) => trackIds.contains(track.id))
          .toList();
      if (tracks.length != trackIds.length) {
        throw const CacheException('One or more selected tracks are unknown.');
      }
      final level = _localDataSource.runtimeLevels.firstWhere(
        (candidate) => candidate.id == runtimeLevelId,
        orElse: () => throw CacheException(
          'Unknown runtime level "$runtimeLevelId".',
        ),
      );
      final summary = OnboardingSummary(selectedTracks: tracks, runtimeLevel: level);
      _localDataSource.savedSummary = summary;
      return Right(summary);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> syncProfileToRemote({
    required List<String> trackIds,
    required String runtimeLevelId,
  }) async {
    try {
      await _remoteDataSource.saveUserProfile(
        trackIds: trackIds,
        runtimeLevelId: runtimeLevelId,
      );
      return const Right(null);
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
