abstract class AuthRepository {
  Future<dynamic> signUp({
    required String password,
    required String username,
    required String email,
  });

  Future<dynamic> signIn({
    required String password,
    required String username,
  });

  Future<dynamic> getProfile();

  Future<dynamic> userUpdate({
    String? username,
    String? email,
  });

  Future<dynamic> passwordUpdate({
    required String oldPassword,
    required String newPassword,
  });

  Future<dynamic> refreshToken({String? refreshToken});
}
