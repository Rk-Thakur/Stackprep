import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Contract for a single-responsibility application action: the presentation
/// layer calls it, it delegates to a domain repository, and it always
/// resolves to a [Failure] or a [Type] — never throws.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Same contract as [UseCase] for actions that expose a continuous stream
/// of data instead of a single result.
abstract class StreamUseCase<Type, Params> {
  Stream<Type> call(Params params);
}

/// Sentinel for use cases that don't need parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
