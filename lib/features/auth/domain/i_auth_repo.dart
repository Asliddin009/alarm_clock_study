abstract interface class IAuthRepo {
  String get name;

  Future<String> signInSms(String email);
  Future<(String accessToken, String refreshToken)> sendSms(
    String email,
    String code,
  );
}
