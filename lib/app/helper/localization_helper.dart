import 'package:alearn/app/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class LocalizationHelper {
  const LocalizationHelper();

  /// Проверка локализации на инициализацию
  ///
  /// В случае, если локализация не найдена, выдает exception
  static AppLocalizations getLocalizations(BuildContext context) {
    return AppLocalizations.of(context)!;
  }
}
