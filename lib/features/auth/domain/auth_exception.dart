enum AuthExceptionType { invalidCredentials, unsupported }

final class AuthException implements Exception {
  const AuthException(this.type);

  final AuthExceptionType type;
}
