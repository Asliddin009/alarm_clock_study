import 'package:alearn/features/alarm/domain/alarm_exception.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/service/alarm_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  test('creates an alarm and keeps repo/cache in sync', () async {
    final repo = RecordingAlarmRepo();
    final cache = InMemoryAlarmCacheRepo();
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    final alarms = await service.createAlarm(
      dateTime: DateTime(2026, 4, 13, 7, 30),
      isRepeat: true,
      weekdays: const <Weekday>[Weekday.monday],
      categoryIds: const <int>[1],
    );

    expect(alarms.single.id, 1);
    expect(repo.scheduled.single.id, 1);
    expect(cache.alarms.single.listCategoryIds, <int>[1]);
  });

  test('rolls back a scheduled alarm when cache save fails', () async {
    final repo = RecordingAlarmRepo();
    final cache = InMemoryAlarmCacheRepo()..failOnSave = true;
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    await expectLater(
      () => service.createAlarm(
        dateTime: DateTime(2026, 4, 13, 9),
        isRepeat: false,
        weekdays: const <Weekday>[],
        categoryIds: const <int>[],
      ),
      throwsA(isA<AlarmCacheException>()),
    );
    expect(repo.deletedIds, <int>[1]);
  });

  test('re-schedules the previous alarm if cache delete fails', () async {
    final existingAlarm = AlarmEntity(
      id: 1,
      time: DateTime(2026, 4, 13, 10),
      isActive: true,
    );
    final repo = RecordingAlarmRepo();
    final cache = InMemoryAlarmCacheRepo(<AlarmEntity>[existingAlarm])
      ..failOnDelete = true;
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    await expectLater(
      () => service.deleteAlarm(existingAlarm.id),
      throwsA(isA<AlarmCacheException>()),
    );
    expect(repo.deletedIds, <int>[1]);
    expect(repo.scheduled.last.id, 1);
  });
}
