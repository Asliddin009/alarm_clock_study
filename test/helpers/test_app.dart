import 'package:alearn/app/localization/app_localizations.dart';
import 'package:flutter/material.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    locale: const Locale('ru'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}
