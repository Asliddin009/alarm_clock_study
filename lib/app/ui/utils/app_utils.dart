import 'package:flutter/widgets.dart';

class AppUtils {
  static String? getLocaleCodeFromSystem() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return systemLocale.languageCode;
  }
}
