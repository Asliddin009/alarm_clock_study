import 'package:alearn/features/auth/domain/i_auth_repo.dart';

final class ProdAuthRepo implements IAuthRepo {
  @override
  String get name => 'ProdAuthRepo';

  @override
  Future<(String, String)> sendSms(String email, String code) {
    throw UnsupportedError('Production auth is not implemented yet.');
  }

  @override
  Future<String> signInSms(String email) {
    throw UnsupportedError('Production auth is not implemented yet.');
  }
}
