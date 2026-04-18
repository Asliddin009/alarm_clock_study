abstract interface class IAppPreferencesRepo {
  Future<String?> getLocaleCode();
  Future<void> setLocaleCode(String localeCode);
  Future<bool> getHasCompletedOnboarding();
  Future<void> setHasCompletedOnboarding(bool value);
}
