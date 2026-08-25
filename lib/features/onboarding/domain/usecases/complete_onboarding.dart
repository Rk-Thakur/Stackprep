import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/onboarding_summary.dart';
import '../repositories/onboarding_repository.dart';

class CompleteOnboarding
    implements UseCase<OnboardingSummary, CompleteOnboardingParams> {
  CompleteOnboarding(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<Either<Failure, OnboardingSummary>> call(
    CompleteOnboardingParams params,
  ) => _repository.completeOnboarding(
    trackIds: params.trackIds,
    runtimeLevelId: params.runtimeLevelId,
  );
}

class CompleteOnboardingParams extends Equatable {
  const CompleteOnboardingParams({
    required this.trackIds,
    required this.runtimeLevelId,
  });

  final List<String> trackIds;
  final String runtimeLevelId;

  @override
  List<Object?> get props => [trackIds, runtimeLevelId];
}
