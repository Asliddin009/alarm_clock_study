import 'package:alearn/features/auth/domain/i_auth_repo.dart';

final class MockAuthRepo implements IAuthRepo {
  @override
  String get name => 'MockAuthRepo';

  @override
  Future<(String, String)> sendSms(String email, String code) {
    if (code == '1111') {
      throw Exception('wrong code');
    }
    return Future.delayed(
      const Duration(seconds: 1),
      () => ('accessToken', 'refToken'),
    );
  }

  @override
  Future<String> signInSms(String email) {
    return Future.delayed(const Duration(seconds: 2), () => 'code sent');
  }
}
