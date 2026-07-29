import 'package:alearn/app/app_runner/app.dart';
import 'package:alearn/app/data/shared_pref_app_preferences_repo.dart';
import 'package:alearn/di/app_dependencies.dart';
import 'package:alearn/features/alarm/domain/service/alarm_service.dart';
import 'package:alearn/features/auth/data/mock_app_repo.dart';
import 'package:alearn/features/points/data/shared_pref_points_repo.dart';
import 'package:alearn/features/ring/domain/ring_question_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fakes.dart';

Future<Widget> _buildApp({
  Map<String, Object> initialPreferences = const <String, Object>{},
}) async {
  SharedPreferences.setMockInitialValues(initialPreferences);
  final sharedPreferences = await SharedPreferences.getInstance();
  final categoryRepo = FakeCategoryRepo();
  final alarmRepo = RecordingAlarmRepo();
  final alarmCacheRepo = InMemoryAlarmCacheRepo();

  addTearDown(alarmRepo.dispose);

  return App(
    appDependencies: AppDependencies.testing(
      authRepo: MockAuthRepo(sharedPreferences),
      appPreferencesRepo: SharedPrefAppPreferencesRepo(sharedPreferences),
      alarmRepo: alarmRepo,
      alarmCacheRepo: alarmCacheRepo,
      alarmService: AlarmService(
        alarmRepo: alarmRepo,
        alarmCacheRepo: alarmCacheRepo,
      ),
      categoryRepo: categoryRepo,
      categoryProgressRepo: InMemoryCategoryProgressRepo(),
      pointsRepo: SharedPrefPointsRepo(sharedPreferences),
      ringQuestionService: RingQuestionService(categoryRepo: categoryRepo),
    ),
  );
}

Future<void> _pumpPastSplash(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1700));
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _pumpUi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}

void main() {
  testWidgets('first launch shows the language selection screen', (
    tester,
  ) async {
    await tester.pumpWidget(await _buildApp());
    await _pumpPastSplash(tester);

    expect(find.byKey(const Key('language-selection-screen')), findsOneWidget);
  });

  testWidgets('choosing a language opens the onboarding screen', (
    tester,
  ) async {
    await tester.pumpWidget(await _buildApp());
    await _pumpPastSplash(tester);

    await tester.tap(find.byKey(const Key('language-option-ru')));
    await _pumpUi(tester);

    expect(find.byKey(const Key('onboarding-screen')), findsOneWidget);
  });

  testWidgets('finishing onboarding opens the auth screen', (tester) async {
    await tester.pumpWidget(await _buildApp());
    await _pumpPastSplash(tester);

    await tester.tap(find.byKey(const Key('language-option-ru')));
    await _pumpUi(tester);
    await tester.tap(find.byKey(const Key('onboarding-skip-button')));
    await _pumpUi(tester);

    expect(find.byKey(const Key('auth-screen')), findsOneWidget);
  });

  testWidgets('skip from auth opens the root screen', (tester) async {
    await tester.pumpWidget(await _buildApp());
    await _pumpPastSplash(tester);

    await tester.tap(find.byKey(const Key('language-option-ru')));
    await _pumpUi(tester);
    await tester.tap(find.byKey(const Key('onboarding-skip-button')));
    await _pumpUi(tester);
    await tester.tap(find.byKey(const Key('auth-skip-button')));
    await _pumpUi(tester);

    expect(find.byKey(const Key('root-screen')), findsOneWidget);
  });

  testWidgets('successful sign in opens the root screen', (tester) async {
    await tester.pumpWidget(await _buildApp());
    await _pumpPastSplash(tester);

    await tester.tap(find.byKey(const Key('language-option-en')));
    await _pumpUi(tester);
    await tester.tap(find.byKey(const Key('onboarding-skip-button')));
    await _pumpUi(tester);
    await tester.enterText(
      find.byKey(const Key('auth-email-field')),
      MockAuthRepo.demoEmail,
    );
    await tester.enterText(
      find.byKey(const Key('auth-password-field')),
      MockAuthRepo.demoPassword,
    );
    await tester.tap(find.byKey(const Key('auth-sign-in-button')));
    await _pumpUi(tester);

    expect(find.byKey(const Key('root-screen')), findsOneWidget);
  });

  testWidgets('logout returns the user to auth screen', (tester) async {
    await tester.pumpWidget(await _buildApp());
    await _pumpPastSplash(tester);

    await tester.tap(find.byKey(const Key('language-option-en')));
    await _pumpUi(tester);
    await tester.tap(find.byKey(const Key('onboarding-skip-button')));
    await _pumpUi(tester);
    await tester.tap(find.byKey(const Key('auth-skip-button')));
    await _pumpUi(tester);
    await tester.tap(find.text('Profile'));
    await _pumpUi(tester);
    final logoutButton = find.byKey(const Key('root-logout-button'));
    await tester.ensureVisible(logoutButton);
    await _pumpUi(tester);
    await tester.tap(logoutButton);
    await _pumpUi(tester);

    expect(find.byKey(const Key('auth-screen')), findsOneWidget);
  });

  testWidgets('saved locale is applied on the next launch', (tester) async {
    await tester.pumpWidget(
      await _buildApp(
        initialPreferences: <String, Object>{
          SharedPrefAppPreferencesRepo.localeStorageKey: 'en',
          SharedPrefAppPreferencesRepo.onboardingStorageKey: true,
        },
      ),
    );
    await _pumpPastSplash(tester);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(find.byKey(const Key('auth-screen')), findsOneWidget);
    expect(app.locale, const Locale('en'));
    expect(find.text('Sign in'), findsWidgets);
  });
}
