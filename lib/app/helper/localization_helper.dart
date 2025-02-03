import 'package:alearn/app/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class LocalizationHelper {
  const LocalizationHelper();

  /// Проверка локализации на инициализацию
  ///
  /// В случае, если локализация не найдена, выдает exception
  static AppLocalizations getLocalizations(BuildContext context) {
    final localization = AppLocalizations.of(context);
    if (localization == null) {
      throw Exception(
        'Localizations not found. Ensure localization is initialized properly.',
      );
    }
    return localization;
  }
}
