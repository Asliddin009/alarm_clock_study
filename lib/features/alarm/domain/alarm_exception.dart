sealed class AlarmException implements Exception {
  const AlarmException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

final class AlarmCacheException extends AlarmException {
  const AlarmCacheException(super.message, {super.cause});
}

final class AlarmRepositoryException extends AlarmException {
  const AlarmRepositoryException(super.message, {super.cause});
}

final class AlarmPermissionException extends AlarmException {
  const AlarmPermissionException(super.message, {super.cause});
}
