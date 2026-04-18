// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get alarm => 'Alarm';

  @override
  String get no_alarms => 'No alarms yet';

  @override
  String get create_alarm => 'Create alarm';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get error => 'Error';

  @override
  String get try_again => 'Try again';

  @override
  String get select_time => 'select the alarm time';

  @override
  String get select_language_title => 'Choose your interface language';

  @override
  String get select_language_subtitle => 'You can change it before signing in.';

  @override
  String get splash_title => 'ALearn';

  @override
  String get splash_subtitle =>
      'Wake up, study, and keep English in your daily routine.';

  @override
  String get onboarding_skip => 'Skip';

  @override
  String get onboarding_next => 'Next';

  @override
  String get onboarding_start => 'Choose language';

  @override
  String get onboarding_alarm_title => 'Wake up with a purpose';

  @override
  String get onboarding_alarm_description =>
      'Instead of a passive alarm, the app nudges you into an active start with a small learning step.';

  @override
  String get onboarding_words_title => 'Repeat useful words offline';

  @override
  String get onboarding_words_description =>
      'Keep your vocabulary close at hand and revisit categories even when you are away from the network.';

  @override
  String get onboarding_voice_title => 'Train your pronunciation calmly';

  @override
  String get onboarding_voice_description =>
      'Short voice-focused practice blocks help you speak more clearly before the day even begins.';

  @override
  String get russian_language => 'Russian';

  @override
  String get english_language => 'English';

  @override
  String get auth_title => 'Sign in';

  @override
  String get auth_subtitle => 'Use the mock account or skip for now.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get sign_in => 'Sign in';

  @override
  String get skip_for_now => 'Skip for now';

  @override
  String get change_language => 'Change language';

  @override
  String get mock_auth_hint => 'Mock credentials: demo@alearn.app / 123456';

  @override
  String get invalid_credentials_error => 'Incorrect email or password.';

  @override
  String get unexpected_error => 'Something went wrong. Please try again.';

  @override
  String get nav_alarm => 'Alarm';

  @override
  String get nav_words => 'Words';

  @override
  String get nav_pronunciation => 'Voice';

  @override
  String get nav_profile => 'Profile';

  @override
  String get alarm_empty_subtitle =>
      'Set a wake-up time and attach a quick English quiz to your morning.';

  @override
  String get alarm_one_time => 'One-time alarm';

  @override
  String get edit_alarm_title => 'Edit alarm';

  @override
  String get repeat_alarm => 'Repeat';

  @override
  String get weekdays_title => 'Weekdays';

  @override
  String get quiz_categories_title => 'Quiz categories';

  @override
  String get categories_loading_hint =>
      'Categories will appear automatically after loading.';

  @override
  String get save_changes_action => 'Save changes';

  @override
  String get create_action => 'Create';

  @override
  String get words_screen_title => 'Study words';

  @override
  String get words_summary_title => 'Compact daily study';

  @override
  String get words_summary_subtitle =>
      'Browse categories, repeat familiar words, and keep the vocabulary section light and focused.';

  @override
  String get words_categories_metric => 'Categories';

  @override
  String get words_total_metric => 'Words';

  @override
  String get words_empty_title => 'The vocabulary list is still empty';

  @override
  String get words_empty_message =>
      'Once categories load, this section will show word groups and quick previews.';

  @override
  String get words_empty_preview => 'No preview words yet.';

  @override
  String words_word_count(int count) {
    return '$count words';
  }

  @override
  String get pronunciation_screen_title => 'Pronunciation';

  @override
  String get pronunciation_title => 'Make your speech cleaner';

  @override
  String get pronunciation_subtitle =>
      'Short, repeatable steps to warm up pronunciation before practice.';

  @override
  String get pronunciation_breathe_title => 'Set the rhythm';

  @override
  String get pronunciation_breathe_body =>
      'Take one calm breath and say the phrase slowly, keeping the ending clear.';

  @override
  String get pronunciation_listen_title => 'Listen for stress';

  @override
  String get pronunciation_listen_body =>
      'Focus on the stressed word and keep the rest smooth and short.';

  @override
  String get pronunciation_repeat_title => 'Repeat in one flow';

  @override
  String get pronunciation_repeat_body =>
      'Say the phrase 3 times with the same pace and softer pauses.';

  @override
  String get pronunciation_phrase_label => 'Practice phrase';

  @override
  String get pronunciation_phrase => 'I need a little more time.';

  @override
  String get pronunciation_translation => 'Мне нужно немного больше времени.';

  @override
  String get profile_screen_title => 'Profile';

  @override
  String get profile_guest_title => 'Guest mode is active';

  @override
  String get profile_guest_subtitle =>
      'You can explore the app now and sign in later whenever you want.';

  @override
  String get profile_authorized_title => 'Your session is ready';

  @override
  String profile_authorized_subtitle(String name) {
    return 'Signed in as $name.';
  }

  @override
  String get profile_preferences_title => 'Preferences';

  @override
  String get profile_language_label => 'Interface language';

  @override
  String get profile_status_label => 'Session';

  @override
  String get profile_guest_status => 'Guest';

  @override
  String get profile_authorized_status => 'Authorized';

  @override
  String get profile_session_title => 'Session control';

  @override
  String get profile_session_subtitle =>
      'You can leave the session and come back through the onboarding flow at any time.';

  @override
  String get wake_up_title => 'Wake up';

  @override
  String get ring_alarm_missing =>
      'The alarm is already missing, but you can safely stop the ringing.';

  @override
  String ring_alarm_label(String time) {
    return 'Alarm $time';
  }

  @override
  String get quiz_unavailable =>
      'The quiz is unavailable right now. You can stop the alarm manually.';

  @override
  String get stop_alarm => 'Stop alarm';

  @override
  String get wrong_answer => 'Not quite. Try again.';

  @override
  String get root_screen_title => 'Start';

  @override
  String get root_guest_title => 'Guest mode';

  @override
  String get root_guest_message =>
      'You can explore the alarm flow now and sign in later.';

  @override
  String get root_authorized_title => 'Welcome back';

  @override
  String root_authorized_message(String name) {
    return 'Signed in as $name.';
  }

  @override
  String get open_alarm_screen => 'Open alarm screen';

  @override
  String get logout => 'Log out';

  @override
  String get bootstrap_error_title => 'Startup error';

  @override
  String get retry => 'Retry';
}
