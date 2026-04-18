import 'dart:convert';

import 'package:alearn/features/auth/domain/auth_exception.dart';
import 'package:alearn/features/auth/domain/auth_session.dart';
import 'package:alearn/features/auth/domain/i_auth_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class MockAuthRepo implements IAuthRepo {
  MockAuthRepo(this._sharedPreferences);

  static const String demoEmail = 'demo@alearn.app';
  static const String demoPassword = '123456';
  static const String _storageKey = 'AUTH_SESSION';

  final SharedPreferences _sharedPreferences;

  @override
  String get name => 'MockAuthRepo';

  @override
  Future<AuthSession> continueAsGuest() async {
    const session = AuthSession(
      type: AuthSessionType.guest,
      displayName: 'Guest',
    );
    await _saveSession(session);
    return session;
  }

  @override
  Future<void> logout() async {
    await _sharedPreferences.remove(_storageKey);
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final rawSession = _sharedPreferences.getString(_storageKey);
    if (rawSession == null) {
      return null;
    }
    final json = jsonDecode(rawSession) as Map<String, dynamic>;
    return AuthSession(
      type: AuthSessionType.values.byName(json['type'] as String),
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
    );
  }

  @override
  Future<AuthSession> signIn(String usernameOrEmail, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (usernameOrEmail != demoEmail || password != demoPassword) {
      throw const AuthException(AuthExceptionType.invalidCredentials);
    }

    const session = AuthSession(
      type: AuthSessionType.authorized,
      email: demoEmail,
      displayName: 'Demo User',
    );
    await _saveSession(session);
    return session;
  }

  Future<void> _saveSession(AuthSession session) async {
    await _sharedPreferences.setString(
      _storageKey,
      jsonEncode(<String, String?>{
        'type': session.type.name,
        'email': session.email,
        'displayName': session.displayName,
      }),
    );
  }
}
