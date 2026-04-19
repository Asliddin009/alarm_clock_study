import 'package:alearn/app/domain/i_app_preferences_repo.dart';
import 'package:alearn/app/ui/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class SharedPrefAppPreferencesRepo implements IAppPreferencesRepo {
  SharedPrefAppPreferencesRepo(this._sharedPreferences);

  static const String localeStorageKey = 'APP_LOCALE_CODE';
  static const String onboardingStorageKey = 'APP_ONBOARDING_COMPLETED';

  final SharedPreferences _sharedPreferences;

  @override
  Future<String?> getLocaleCode() async {
    String? res = _sharedPreferences.getString(localeStorageKey);
    res ??= AppUtils.getLocaleCodeFromSystem();
    return res;
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
