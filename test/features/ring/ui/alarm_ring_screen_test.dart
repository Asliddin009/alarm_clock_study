import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/service/alarm_service.dart';
import 'package:alearn/features/category/domain/entity/category_entity.dart';
import 'package:alearn/features/ring/domain/ring_question_service.dart';
import 'package:alearn/features/ring/ring_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

void main() {
  testWidgets('shows a safe fallback when question data is missing',
      (tester) async {
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

    await tester.pumpWidget(
      buildTestApp(
        BlocProvider<AlarmBloc>.value(
          value: alarmBloc,
          child: AlarmRingScreen(
            alarmId: 1,
            questionService: questionService,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Вопрос для квиза сейчас недоступен'),
      findsOneWidget,
    );
  });
}
