import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/progress_overview.dart';

abstract interface class ProgressRepository {
  Future<Either<Failure, ProgressOverview>> getProgressOverview();
}
