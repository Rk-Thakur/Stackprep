/// User-facing error type crossing the domain boundary. Carries a message
/// safe to show directly in the UI.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The backend/provider call itself failed (network, rejected credential,
/// provider outage, ...).
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Data could not be found or produced locally (unknown id, empty store).
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
