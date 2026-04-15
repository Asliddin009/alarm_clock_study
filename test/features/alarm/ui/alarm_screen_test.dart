import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/service/alarm_service.dart';
import 'package:alearn/features/alarm/ui/screens/alarm_screen_new.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

void main() {
  testWidgets('renders alarms and deletes one with swipe', (tester) async {
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

    await tester.pumpWidget(
      buildTestApp(
        BlocProvider<AlarmBloc>.value(
          value: alarmBloc,
          child: const AlarmScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('08:30'), findsOneWidget);

    await tester.drag(find.text('08:30'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(alarmRepo.deletedIds, <int>[1]);
  });
}
