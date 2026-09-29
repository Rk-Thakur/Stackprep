import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/daily_challenge_store.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../onboarding/domain/repositories/onboarding_repository.dart';
import '../repositories/auth_repository.dart';

/// Erases an account end to end: the backend record and its subcollections,
/// the auth identity, and every trace of it left on this device.
///
/// The order matters. The remote wipe runs first and is allowed to fail the
/// whole use case, because signing the user out while their data survived
/// would strand it where they can no longer reach it. Once the remote side is
/// gone the local clears are best effort: the account is already deleted, so a
/// stale key on this device is not worth failing over or leaving the user
/// stranded on a page for an account that no longer exists.
class DeleteAccount implements UseCase<void, NoParams> {
  const DeleteAccount({
    required AuthRepository authRepository,
    required OnboardingRepository onboardingRepository,
    required DailyChallengeStore dailyChallengeStore,
  }) : _authRepository = authRepository,
       _onboardingRepository = onboardingRepository,
       _dailyChallengeStore = dailyChallengeStore;

  final AuthRepository _authRepository;
  final OnboardingRepository _onboardingRepository;
  final DailyChallengeStore _dailyChallengeStore;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    final deleted = await _authRepository.deleteAccount();
    final failure = deleted.fold((failure) => failure, (_) => null);
    if (failure != null) return Left(failure);

    await _bestEffort(() async {
      final cleared = await _onboardingRepository.clearAccountData();
      cleared.fold((failure) => throw StateError(failure.message), (_) {});
    });
    await _bestEffort(_dailyChallengeStore.clearHistory);

    return const Right(null);
  }

  Future<void> _bestEffort(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      debugPrint('DeleteAccount: local clear failed — $error');
    }
  }
}
