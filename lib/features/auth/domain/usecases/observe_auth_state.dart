import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Continuous observation of the signed-in identity; the bloc subscribes to
/// this to keep [AuthState.status] in sync with Firebase.
class ObserveAuthState implements StreamUseCase<AppUser?, NoParams> {
  ObserveAuthState(this._repository);

  final AuthRepository _repository;

  @override
  Stream<AppUser?> call(NoParams params) => _repository.authStateChanges;
}
