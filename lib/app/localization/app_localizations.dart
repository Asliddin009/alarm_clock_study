import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @alarm.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get alarm;

  /// No description provided for @no_alarms.
  ///
  /// In en, this message translates to:
  /// **'No alarms yet'**
  String get no_alarms;

  /// No description provided for @create_alarm.
  ///
  /// In en, this message translates to:
  /// **'Create alarm'**
  String get create_alarm;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get try_again;

  /// No description provided for @select_time.
  ///
  /// In en, this message translates to:
  /// **'select the alarm time'**
  String get select_time;

  /// No description provided for @select_language_title.
  ///
  /// In en, this message translates to:
  /// **'Choose your interface language'**
  String get select_language_title;

  /// No description provided for @select_language_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change it before signing in.'**
  String get select_language_subtitle;

  /// No description provided for @splash_title.
  ///
  /// In en, this message translates to:
  /// **'ALearn'**
  String get splash_title;

  /// No description provided for @splash_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Wake up, study, and keep English in your daily routine.'**
  String get splash_subtitle;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// No description provided for @onboarding_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next;

  /// No description provided for @onboarding_start.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get onboarding_start;

  /// No description provided for @onboarding_alarm_title.
  ///
  /// In en, this message translates to:
  /// **'Wake up with a purpose'**
  String get onboarding_alarm_title;

  /// No description provided for @onboarding_alarm_description.
  ///
  /// In en, this message translates to:
  /// **'Instead of a passive alarm, the app nudges you into an active start with a small learning step.'**
  String get onboarding_alarm_description;

  /// No description provided for @onboarding_words_title.
  ///
  /// In en, this message translates to:
  /// **'Repeat useful words offline'**
  String get onboarding_words_title;

  /// No description provided for @onboarding_words_description.
  ///
  /// In en, this message translates to:
  /// **'Keep your vocabulary close at hand and revisit categories even when you are away from the network.'**
  String get onboarding_words_description;

  /// No description provided for @onboarding_voice_title.
  ///
  /// In en, this message translates to:
  /// **'Train your pronunciation calmly'**
  String get onboarding_voice_title;

  /// No description provided for @onboarding_voice_description.
  ///
  /// In en, this message translates to:
  /// **'Short voice-focused practice blocks help you speak more clearly before the day even begins.'**
  String get onboarding_voice_description;

  /// No description provided for @russian_language.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian_language;

  /// No description provided for @english_language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english_language;

  /// No description provided for @auth_title.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get auth_title;

  /// No description provided for @auth_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the mock account or skip for now.'**
  String get auth_subtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get sign_in;

  /// No description provided for @skip_for_now.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skip_for_now;

  /// No description provided for @change_language.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get change_language;

  /// No description provided for @mock_auth_hint.
  ///
  /// In en, this message translates to:
  /// **'Mock credentials: demo@alearn.app / 123456'**
  String get mock_auth_hint;

  /// No description provided for @invalid_credentials_error.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get invalid_credentials_error;

  /// No description provided for @unexpected_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unexpected_error;

  /// No description provided for @nav_alarm.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get nav_alarm;

  /// No description provided for @nav_words.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get nav_words;

  /// No description provided for @nav_pronunciation.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get nav_pronunciation;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @alarm_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a wake-up time and attach a quick English quiz to your morning.'**
  String get alarm_empty_subtitle;

  /// No description provided for @alarm_one_time.
  ///
  /// In en, this message translates to:
  /// **'One-time alarm'**
  String get alarm_one_time;

  /// No description provided for @edit_alarm_title.
  ///
  /// In en, this message translates to:
  /// **'Edit alarm'**
  String get edit_alarm_title;

  /// No description provided for @repeat_alarm.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat_alarm;

  /// No description provided for @weekdays_title.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get weekdays_title;

  /// No description provided for @quiz_categories_title.
  ///
  /// In en, this message translates to:
  /// **'Quiz categories'**
  String get quiz_categories_title;

  /// No description provided for @categories_loading_hint.
  ///
  /// In en, this message translates to:
  /// **'Categories will appear automatically after loading.'**
  String get categories_loading_hint;

  /// No description provided for @save_changes_action.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get save_changes_action;

  /// No description provided for @create_action.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create_action;

  /// No description provided for @words_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Study words'**
  String get words_screen_title;

  /// No description provided for @words_summary_title.
  ///
  /// In en, this message translates to:
  /// **'Compact daily study'**
  String get words_summary_title;

  /// No description provided for @words_summary_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse categories, repeat familiar words, and keep the vocabulary section light and focused.'**
  String get words_summary_subtitle;

  /// No description provided for @words_categories_metric.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get words_categories_metric;

  /// No description provided for @words_total_metric.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get words_total_metric;

  /// No description provided for @words_empty_title.
  ///
  /// In en, this message translates to:
  /// **'The vocabulary list is still empty'**
  String get words_empty_title;

  /// No description provided for @words_empty_message.
  ///
  /// In en, this message translates to:
  /// **'Once categories load, this section will show word groups and quick previews.'**
  String get words_empty_message;

  /// No description provided for @words_empty_preview.
  ///
  /// In en, this message translates to:
  /// **'No preview words yet.'**
  String get words_empty_preview;

  /// No description provided for @words_word_count.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String words_word_count(int count);

  /// No description provided for @pronunciation_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation'**
  String get pronunciation_screen_title;

  /// No description provided for @pronunciation_title.
  ///
  /// In en, this message translates to:
  /// **'Make your speech cleaner'**
  String get pronunciation_title;

  /// No description provided for @pronunciation_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Short, repeatable steps to warm up pronunciation before practice.'**
  String get pronunciation_subtitle;

  /// No description provided for @pronunciation_breathe_title.
  ///
  /// In en, this message translates to:
  /// **'Set the rhythm'**
  String get pronunciation_breathe_title;

  /// No description provided for @pronunciation_breathe_body.
  ///
  /// In en, this message translates to:
  /// **'Take one calm breath and say the phrase slowly, keeping the ending clear.'**
  String get pronunciation_breathe_body;

  /// No description provided for @pronunciation_listen_title.
  ///
  /// In en, this message translates to:
  /// **'Listen for stress'**
  String get pronunciation_listen_title;

  /// No description provided for @pronunciation_listen_body.
  ///
  /// In en, this message translates to:
  /// **'Focus on the stressed word and keep the rest smooth and short.'**
  String get pronunciation_listen_body;

  /// No description provided for @pronunciation_repeat_title.
  ///
  /// In en, this message translates to:
  /// **'Repeat in one flow'**
  String get pronunciation_repeat_title;

  /// No description provided for @pronunciation_repeat_body.
  ///
  /// In en, this message translates to:
  /// **'Say the phrase 3 times with the same pace and softer pauses.'**
  String get pronunciation_repeat_body;

  /// No description provided for @pronunciation_phrase_label.
  ///
  /// In en, this message translates to:
  /// **'Practice phrase'**
  String get pronunciation_phrase_label;

  /// No description provided for @pronunciation_phrase.
  ///
  /// In en, this message translates to:
  /// **'I need a little more time.'**
  String get pronunciation_phrase;

  /// No description provided for @pronunciation_translation.
  ///
  /// In en, this message translates to:
  /// **'Мне нужно немного больше времени.'**
  String get pronunciation_translation;

  /// No description provided for @profile_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_screen_title;

  /// No description provided for @profile_guest_title.
  ///
  /// In en, this message translates to:
  /// **'Guest mode is active'**
  String get profile_guest_title;

  /// No description provided for @profile_guest_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You can explore the app now and sign in later whenever you want.'**
  String get profile_guest_subtitle;

  /// No description provided for @profile_authorized_title.
  ///
  /// In en, this message translates to:
  /// **'Your session is ready'**
  String get profile_authorized_title;

  /// No description provided for @profile_authorized_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}.'**
  String profile_authorized_subtitle(String name);

  /// No description provided for @profile_preferences_title.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profile_preferences_title;

  /// No description provided for @profile_language_label.
  ///
  /// In en, this message translates to:
  /// **'Interface language'**
  String get profile_language_label;

  /// No description provided for @profile_status_label.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get profile_status_label;

  /// No description provided for @profile_guest_status.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profile_guest_status;

  /// No description provided for @profile_authorized_status.
  ///
  /// In en, this message translates to:
  /// **'Authorized'**
  String get profile_authorized_status;

  /// No description provided for @profile_session_title.
  ///
  /// In en, this message translates to:
  /// **'Session control'**
  String get profile_session_title;

  /// No description provided for @profile_session_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You can leave the session and come back through the onboarding flow at any time.'**
  String get profile_session_subtitle;

  /// No description provided for @wake_up_title.
  ///
  /// In en, this message translates to:
  /// **'Wake up'**
  String get wake_up_title;

  /// No description provided for @ring_alarm_missing.
  ///
  /// In en, this message translates to:
  /// **'The alarm is already missing, but you can safely stop the ringing.'**
  String get ring_alarm_missing;

  /// No description provided for @ring_alarm_label.
  ///
  /// In en, this message translates to:
  /// **'Alarm {time}'**
  String ring_alarm_label(String time);

  /// No description provided for @quiz_unavailable.
  ///
  /// In en, this message translates to:
  /// **'The quiz is unavailable right now. You can stop the alarm manually.'**
  String get quiz_unavailable;

  /// No description provided for @stop_alarm.
  ///
  /// In en, this message translates to:
  /// **'Stop alarm'**
  String get stop_alarm;

  /// No description provided for @wrong_answer.
  ///
  /// In en, this message translates to:
  /// **'Not quite. Try again.'**
  String get wrong_answer;

  /// No description provided for @root_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get root_screen_title;

  /// No description provided for @root_guest_title.
  ///
  /// In en, this message translates to:
  /// **'Guest mode'**
  String get root_guest_title;

  /// No description provided for @root_guest_message.
  ///
  /// In en, this message translates to:
  /// **'You can explore the alarm flow now and sign in later.'**
  String get root_guest_message;

  /// No description provided for @root_authorized_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get root_authorized_title;

  /// No description provided for @root_authorized_message.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}.'**
  String root_authorized_message(String name);

  /// No description provided for @open_alarm_screen.
  ///
  /// In en, this message translates to:
  /// **'Open alarm screen'**
  String get open_alarm_screen;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @bootstrap_error_title.
  ///
  /// In en, this message translates to:
  /// **'Startup error'**
  String get bootstrap_error_title;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
