import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/service/alarm_service.dart';
import 'package:alearn/features/alarm/ui/screens/edit_alarm_new.dart';
import 'package:alearn/features/category/domain/cubit/category_cubit.dart';
import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

void main() {
  testWidgets('creates an alarm with selected weekday and category', (
    tester,
  ) async {
    final alarmRepo = RecordingAlarmRepo();
    final alarmCache = InMemoryAlarmCacheRepo();
    final alarmBloc = AlarmBloc(
      alarmService: AlarmService(
        alarmRepo: alarmRepo,
        alarmCacheRepo: alarmCache,
      ),
    );
    final categoryCubit = CategoryCubit(
      FakeCategoryRepo(
        baseCategories: const <CategoryEntity>[
          CategoryEntity(id: 1, name: 'Для разработчиков', wordList: []),
        ],
      ),
    )..getCategories();

    await tester.pumpWidget(
      buildTestApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<AlarmBloc>.value(value: alarmBloc),
            BlocProvider<CategoryCubit>.value(value: categoryCubit),
          ],
          child: const CreateAlarmScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(Weekday.monday.shortLabel));
    await tester.pump();
    await tester.tap(find.text('Для разработчиков'));
    await tester.pump();
    final createButton = find.widgetWithText(ElevatedButton, 'Создать');
    await tester.ensureVisible(createButton);
    await tester.pumpAndSettle();
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(alarmCache.alarms, hasLength(1));
    expect(alarmCache.alarms.single.weekdays, contains(Weekday.monday));
    expect(alarmCache.alarms.single.listCategoryIds, contains(1));
  });
}
