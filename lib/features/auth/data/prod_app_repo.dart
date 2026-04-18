import 'package:alearn/features/auth/domain/auth_exception.dart';
import 'package:alearn/features/auth/domain/auth_session.dart';
import 'package:alearn/features/auth/domain/i_auth_repo.dart';

final class ProdAuthRepo implements IAuthRepo {
  @override
  String get name => 'ProdAuthRepo';

  @override
  Future<AuthSession> continueAsGuest() {
    throw const AuthException(AuthExceptionType.unsupported);
  }

  @override
  Future<void> logout() {
    throw const AuthException(AuthExceptionType.unsupported);
  }

  @override
  Future<AuthSession?> restoreSession() {
    throw const AuthException(AuthExceptionType.unsupported);
  }

  @override
  Future<AuthSession> signIn(String usernameOrEmail, String password) {
    throw const AuthException(AuthExceptionType.unsupported);
  }
}
