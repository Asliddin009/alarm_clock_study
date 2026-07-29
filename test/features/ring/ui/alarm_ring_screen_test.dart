import 'package:alearn/app/data/shared_pref_app_preferences_repo.dart';
import 'package:alearn/di/app_dependencies.dart';
import 'package:alearn/di/app_dependencies_scope.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/service/alarm_service.dart';
import 'package:alearn/features/auth/data/mock_app_repo.dart';
import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/ring/domain/ring_question_service.dart';
import 'package:alearn/features/ring/ring_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

void main() {
  testWidgets('shows a safe fallback when question data is missing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final sharedPreferences = await SharedPreferences.getInstance();
    final alarm = AlarmEntity(
      id: 1,
      time: DateTime(2026, 4, 13, 9, 0),
      isActive: true,
    );
    final alarmBloc = AlarmBloc(
      alarmService: AlarmService(
        alarmRepo: RecordingAlarmRepo(),
        alarmCacheRepo: InMemoryAlarmCacheRepo(<AlarmEntity>[alarm]),
      ),
    )..add(const AlarmStarted());
    final questionService = RingQuestionService(
      categoryRepo: FakeCategoryRepo(
        baseCategories: const <CategoryEntity>[
          CategoryEntity(id: 1, name: 'Пустая категория', wordList: []),
        ],
      ),
    );
    final appDependencies = AppDependencies.testing(
      authRepo: MockAuthRepo(sharedPreferences),
      appPreferencesRepo: SharedPrefAppPreferencesRepo(sharedPreferences),
      alarmRepo: RecordingAlarmRepo(),
      alarmCacheRepo: InMemoryAlarmCacheRepo(<AlarmEntity>[alarm]),
      alarmService: AlarmService(
        alarmRepo: RecordingAlarmRepo(),
        alarmCacheRepo: InMemoryAlarmCacheRepo(<AlarmEntity>[alarm]),
      ),
      categoryRepo: FakeCategoryRepo(),
      categoryProgressRepo: InMemoryCategoryProgressRepo(),
      pointsRepo: InMemoryPointsRepo(),
      ringQuestionService: questionService,
    );

    await tester.pumpWidget(
      buildTestApp(
        AppDependenciesScope(
          appDependencies: appDependencies,
          child: BlocProvider<AlarmBloc>.value(
            value: alarmBloc,
            child: AlarmRingScreen(
              alarmId: 1,
              questionService: questionService,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      find.textContaining('Вопрос для квиза сейчас недоступен'),
      findsOneWidget,
    );
  });
}
