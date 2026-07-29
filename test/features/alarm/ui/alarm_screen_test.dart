import 'package:alearn/app/data/shared_pref_app_preferences_repo.dart';
import 'package:alearn/di/app_dependencies.dart';
import 'package:alearn/di/app_dependencies_scope.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/service/alarm_service.dart';
import 'package:alearn/features/auth/data/mock_app_repo.dart';
import 'package:alearn/features/alarm/ui/screens/alarm_screen_new.dart';
import 'package:alearn/features/ring/domain/ring_question_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

void main() {
  testWidgets('shows permission gate before alarm content', (tester) async {
    final alarmRepo = RecordingAlarmRepo();
    final alarmCache = InMemoryAlarmCacheRepo();
    final alarmBloc = AlarmBloc(
      alarmService: AlarmService(
        alarmRepo: alarmRepo,
        alarmCacheRepo: alarmCache,
      ),
    )..add(const AlarmStarted());

    await tester.pumpWidget(
      buildTestApp(
        BlocProvider<AlarmBloc>.value(
          value: alarmBloc,
          child: AlarmScreen(
            permissionsReadyLoader: _grantedPermissionLoaderFalse,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(
      find.byKey(const Key('alarm-request-permissions-button')),
      findsOneWidget,
    );
  });

  testWidgets('renders alarms and reacts to alarm deletion', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final sharedPreferences = await SharedPreferences.getInstance();
    final alarm = AlarmEntity(
      id: 1,
      time: DateTime(2026, 4, 13, 8, 30),
      isActive: true,
    );
    final alarmRepo = RecordingAlarmRepo();
    final alarmCache = InMemoryAlarmCacheRepo(<AlarmEntity>[alarm]);
    final alarmBloc = AlarmBloc(
      alarmService: AlarmService(
        alarmRepo: alarmRepo,
        alarmCacheRepo: alarmCache,
      ),
    )..add(const AlarmStarted());
    final categoryRepo = FakeCategoryRepo();
    final appDependencies = AppDependencies.testing(
      authRepo: MockAuthRepo(sharedPreferences),
      appPreferencesRepo: SharedPrefAppPreferencesRepo(sharedPreferences),
      alarmRepo: alarmRepo,
      alarmCacheRepo: alarmCache,
      alarmService: AlarmService(
        alarmRepo: alarmRepo,
        alarmCacheRepo: alarmCache,
      ),
      categoryRepo: categoryRepo,
      categoryProgressRepo: InMemoryCategoryProgressRepo(),
      pointsRepo: InMemoryPointsRepo(),
      ringQuestionService: RingQuestionService(categoryRepo: categoryRepo),
    );

    await tester.pumpWidget(
      buildTestApp(
        AppDependenciesScope(
          appDependencies: appDependencies,
          child: BlocProvider<AlarmBloc>.value(
            value: alarmBloc,
            child: AlarmScreen(
              permissionsReadyLoader: _grantedPermissionLoaderTrue,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('08:30'), findsWidgets);
    await appDependencies.alarmService.deleteAlarm(alarm.id);
    alarmBloc.add(const AlarmRefreshRequested());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(alarmRepo.deletedIds, <int>[1]);
    expect(find.text('08:30'), findsNothing);
  });
}

Future<bool> _grantedPermissionLoaderTrue() async => true;

Future<bool> _grantedPermissionLoaderFalse() async => false;
