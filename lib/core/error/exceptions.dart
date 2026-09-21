/// Infrastructure-layer exceptions. Data sources throw these; only
/// repository implementations are expected to catch them (and map them to
/// [Failure]s from `failures.dart`).
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when a remote/backend call fails (network, auth provider, etc.).
class ServerException extends AppException {
  const ServerException(super.message);
}

/// Thrown when locally available data can't be resolved (missing id, etc.).
class CacheException extends AppException {
  const CacheException(super.message);
}
