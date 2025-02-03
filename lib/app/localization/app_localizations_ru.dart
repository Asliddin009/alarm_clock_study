import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get alarm => 'Будильник';

  @override
  String get no_alarms => 'Нет будильников';

  @override
  String get create_alarm => 'Создание будильника';

  @override
  String get date => 'Дата';

  @override
  String get time => 'Время';
}
