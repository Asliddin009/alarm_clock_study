// ignore: unused_import
import 'package:intl/intl.dart' as intl;
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

  @override
  String get error => 'Ошибка';

  @override
  String get try_again => 'Повторите попытку';

  @override
  String get select_time => 'выберите время будильника';

  @override
  String get select_language_title => 'Выберите язык интерфейса';

  @override
  String get select_language_subtitle =>
      'Его можно будет сменить перед авторизацией.';

  @override
  String get splash_title => 'ALearn';

  @override
  String get splash_subtitle =>
      'Просыпайтесь, учитесь и держите английский в ежедневной рутине.';

  @override
  String get onboarding_skip => 'Пропустить';

  @override
  String get onboarding_next => 'Далее';

  @override
  String get onboarding_start => 'Выбрать язык';

  @override
  String get onboarding_alarm_title => 'Просыпайтесь со смыслом';

  @override
  String get onboarding_alarm_description =>
      'Вместо пассивного будильника приложение мягко переводит вас в активное утро через маленький учебный шаг.';

  @override
  String get onboarding_words_title => 'Повторяйте полезные слова офлайн';

  @override
  String get onboarding_words_description =>
      'Держите словарь под рукой и возвращайтесь к категориям даже без подключения к сети.';

  @override
  String get onboarding_voice_title => 'Спокойно тренируйте произношение';

  @override
  String get onboarding_voice_description =>
      'Короткие голосовые практики помогают говорить чище ещё до того, как день по-настоящему начался.';

  @override
  String get russian_language => 'Русский';

  @override
  String get english_language => 'Английский';

  @override
  String get auth_title => 'Авторизация';

  @override
  String get auth_subtitle =>
      'Войдите в моковый аккаунт или пока пропустите этот шаг.';

  @override
  String get email => 'Почта';

  @override
  String get password => 'Пароль';

  @override
  String get sign_in => 'Войти';

  @override
  String get skip_for_now => 'Пропустить пока';

  @override
  String get change_language => 'Сменить язык';

  @override
  String get mock_auth_hint => 'Моковые данные: demo@alearn.app / 123456';

  @override
  String get invalid_credentials_error => 'Неверная почта или пароль.';

  @override
  String get unexpected_error => 'Что-то пошло не так. Повторите попытку.';

  @override
  String get nav_alarm => 'Будильник';

  @override
  String get nav_words => 'Слова';

  @override
  String get nav_pronunciation => 'Произношение';

  @override
  String get nav_profile => 'Профиль';

  @override
  String get alarm_empty_subtitle =>
      'Добавьте время подъёма и прикрепите короткий английский квиз к утру.';

  @override
  String get alarm_one_time => 'Разовый будильник';

  @override
  String get edit_alarm_title => 'Редактирование будильника';

  @override
  String get repeat_alarm => 'Повторять';

  @override
  String get weekdays_title => 'Дни недели';

  @override
  String get quiz_categories_title => 'Категории для квиза';

  @override
  String get categories_loading_hint =>
      'Категории появятся автоматически после загрузки.';

  @override
  String get save_changes_action => 'Сохранить изменения';

  @override
  String get create_action => 'Создать';

  @override
  String get words_screen_title => 'Изучение слов';

  @override
  String get words_summary_title => 'Спокойная ежедневная практика';

  @override
  String get words_summary_subtitle =>
      'Просматривайте категории, повторяйте знакомые слова и держите словарь компактным и понятным.';

  @override
  String get words_categories_metric => 'Категории';

  @override
  String get words_total_metric => 'Слова';

  @override
  String get words_empty_title => 'Список слов пока пуст';

  @override
  String get words_empty_message =>
      'Когда категории загрузятся, здесь появятся группы слов и быстрые превью.';

  @override
  String get words_empty_preview => 'Пока нет слов для превью.';

  @override
  String words_word_count(int count) {
    return '$count слов';
  }

  @override
  String get pronunciation_screen_title => 'Произношение';

  @override
  String get pronunciation_title => 'Сделайте речь чище';

  @override
  String get pronunciation_subtitle =>
      'Короткие повторяемые шаги, чтобы разогреть произношение перед практикой.';

  @override
  String get pronunciation_breathe_title => 'Задайте ритм';

  @override
  String get pronunciation_breathe_body =>
      'Сделайте спокойный вдох и произнесите фразу медленно, чётко удерживая окончание.';

  @override
  String get pronunciation_listen_title => 'Слушайте ударение';

  @override
  String get pronunciation_listen_body =>
      'Сфокусируйтесь на ударном слове, а остальные произносите мягко и короче.';

  @override
  String get pronunciation_repeat_title => 'Повторите одним потоком';

  @override
  String get pronunciation_repeat_body =>
      'Произнесите фразу 3 раза в одном темпе и с более мягкими паузами.';

  @override
  String get pronunciation_phrase_label => 'Фраза для практики';

  @override
  String get pronunciation_phrase => 'I need a little more time.';

  @override
  String get pronunciation_translation => 'Мне нужно немного больше времени.';

  @override
  String get profile_screen_title => 'Профиль';

  @override
  String get profile_guest_title => 'Активен гостевой режим';

  @override
  String get profile_guest_subtitle =>
      'Вы можете изучить приложение сейчас и войти в аккаунт позже.';

  @override
  String get profile_authorized_title => 'Сессия готова';

  @override
  String profile_authorized_subtitle(String name) {
    return 'Вы вошли как $name.';
  }

  @override
  String get profile_preferences_title => 'Настройки';

  @override
  String get profile_language_label => 'Язык интерфейса';

  @override
  String get profile_status_label => 'Сессия';

  @override
  String get profile_guest_status => 'Гость';

  @override
  String get profile_authorized_status => 'Авторизован';

  @override
  String get profile_session_title => 'Управление сессией';

  @override
  String get profile_session_subtitle =>
      'Вы можете выйти из сессии и в любой момент снова пройти стартовый сценарий.';

  @override
  String get wake_up_title => 'Пора просыпаться';

  @override
  String get ring_alarm_missing =>
      'Будильник уже не найден, но звонок можно безопасно остановить.';

  @override
  String ring_alarm_label(String time) {
    return 'Будильник $time';
  }

  @override
  String get quiz_unavailable =>
      'Вопрос для квиза сейчас недоступен. Можно выключить будильник вручную.';

  @override
  String get stop_alarm => 'Остановить будильник';

  @override
  String get wrong_answer => 'Неверно, попробуйте ещё раз.';

  @override
  String get root_screen_title => 'Главный экран';

  @override
  String get root_guest_title => 'Гостевой режим';

  @override
  String get root_guest_message =>
      'Можно изучить сценарий будильника сейчас и авторизоваться позже.';

  @override
  String get root_authorized_title => 'С возвращением';

  @override
  String root_authorized_message(String name) {
    return 'Вы вошли как $name.';
  }

  @override
  String get open_alarm_screen => 'Открыть экран будильников';

  @override
  String get logout => 'Выйти';

  @override
  String get bootstrap_error_title => 'Ошибка запуска';

  @override
  String get retry => 'Повторить';
}
