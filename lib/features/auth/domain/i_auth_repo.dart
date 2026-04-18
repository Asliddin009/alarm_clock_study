import 'package:alearn/features/auth/domain/auth_session.dart';

abstract interface class IAuthRepo {
  String get name;

  Future<AuthSession?> restoreSession();
  Future<AuthSession> signIn(String usernameOrEmail, String password);
  Future<AuthSession> continueAsGuest();
  Future<void> logout();
}
