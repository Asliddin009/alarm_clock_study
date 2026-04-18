import 'package:alearn/app/domain/i_app_preferences_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class SharedPrefAppPreferencesRepo implements IAppPreferencesRepo {
  SharedPrefAppPreferencesRepo(this._sharedPreferences);

  static const String localeStorageKey = 'APP_LOCALE_CODE';
  static const String onboardingStorageKey = 'APP_ONBOARDING_COMPLETED';

  final SharedPreferences _sharedPreferences;

  @override
  Future<String?> getLocaleCode() async {
    return _sharedPreferences.getString(localeStorageKey);
  }

  @override
  Future<void> setLocaleCode(String localeCode) async {
    await _sharedPreferences.setString(localeStorageKey, localeCode);
  }

  @override
  Future<bool> getHasCompletedOnboarding() async {
    return _sharedPreferences.getBool(onboardingStorageKey) ?? false;
  }

  @override
  Future<void> setHasCompletedOnboarding(bool value) async {
    await _sharedPreferences.setBool(onboardingStorageKey, value);
  }
}
