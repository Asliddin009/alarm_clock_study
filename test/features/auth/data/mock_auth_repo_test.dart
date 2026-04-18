import 'package:alearn/features/auth/data/mock_app_repo.dart';
import 'package:alearn/features/auth/domain/auth_exception.dart';
import 'package:alearn/features/auth/domain/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'signs in with mock credentials and restores the saved session',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final sharedPreferences = await SharedPreferences.getInstance();
      final repo = MockAuthRepo(sharedPreferences);

      final session = await repo.signIn(
        MockAuthRepo.demoEmail,
        MockAuthRepo.demoPassword,
      );
      final restoredSession = await repo.restoreSession();

      expect(
        session,
        const AuthSession(
          type: AuthSessionType.authorized,
          email: MockAuthRepo.demoEmail,
          displayName: 'Demo User',
        ),
      );
      expect(restoredSession, session);
    },
  );

  test('throws invalid credentials for wrong email or password', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final sharedPreferences = await SharedPreferences.getInstance();
    final repo = MockAuthRepo(sharedPreferences);

    await expectLater(
      () => repo.signIn('wrong@alearn.app', 'bad-password'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.type,
          'type',
          AuthExceptionType.invalidCredentials,
        ),
      ),
    );
  });

  test('persists and restores a guest session', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final sharedPreferences = await SharedPreferences.getInstance();
    final repo = MockAuthRepo(sharedPreferences);

    final session = await repo.continueAsGuest();
    final restoredSession = await repo.restoreSession();

    expect(
      session,
      const AuthSession(type: AuthSessionType.guest, displayName: 'Guest'),
    );
    expect(restoredSession, session);
  });

  test('logout clears the persisted session', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final sharedPreferences = await SharedPreferences.getInstance();
    final repo = MockAuthRepo(sharedPreferences);

    await repo.signIn(MockAuthRepo.demoEmail, MockAuthRepo.demoPassword);
    await repo.logout();

    expect(await repo.restoreSession(), isNull);
  });
}
