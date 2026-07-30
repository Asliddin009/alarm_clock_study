import 'package:alearn/features/alarm/domain/alarm_exception.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_ring_event.dart';
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

  test('persists the native alarm id returned by the repo', () async {
    final repo = RecordingAlarmRepo()..nativeAlarmIdToAssign = 'uuid-1';
    final cache = InMemoryAlarmCacheRepo();
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    await service.createAlarm(
      dateTime: DateTime(2026, 4, 13, 7, 30),
      isRepeat: false,
      weekdays: const <Weekday>[],
      categoryIds: const <int>[],
    );

    // Без этого будильник AlarmKit нельзя ни отменить, ни остановить.
    expect(cache.alarms.single.nativeAlarmId, 'uuid-1');
  });

  test('resolves a ringing native id to the domain alarm id', () async {
    final alarm = AlarmEntity(
      id: 7,
      time: DateTime(2026, 4, 13, 6),
      isActive: true,
      nativeAlarmId: 'uuid-7',
    );
    final repo = RecordingAlarmRepo();
    final cache = InMemoryAlarmCacheRepo(<AlarmEntity>[alarm]);
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    final ringingIds = service.ringStream.take(1).toList();
    repo.ringController.add(const AlarmRingEvent(nativeAlarmId: 'uuid-7'));

    expect(await ringingIds, <int>[7]);
    await repo.dispose();
  });

  test('finds an alarm already ringing when the app opens', () async {
    final alarm = AlarmEntity(
      id: 5,
      time: DateTime(2026, 4, 13, 6),
      isActive: true,
      nativeAlarmId: 'uuid-5',
    );
    final repo = RecordingAlarmRepo()
      ..ringingAlarm = const AlarmRingEvent(nativeAlarmId: 'uuid-5');
    final cache = InMemoryAlarmCacheRepo(<AlarmEntity>[alarm]);
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    expect(await service.findRingingAlarmId(), 5);
  });

  test('reports no ringing alarm when the system knows none', () async {
    final repo = RecordingAlarmRepo();
    final cache = InMemoryAlarmCacheRepo();
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    expect(await service.findRingingAlarmId(), isNull);
  });

  test('deactivates a fired one-shot alarm instead of deleting it', () async {
    final firedAlarm = AlarmEntity(
      id: 1,
      time: DateTime(2020, 1, 1, 8),
      isActive: true,
    );
    final repo = RecordingAlarmRepo();
    final cache = InMemoryAlarmCacheRepo(<AlarmEntity>[firedAlarm]);
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    await service.initialize();

    // Сверка не имеет права терять данные пользователя.
    expect(cache.alarms.single.id, 1);
    expect(cache.alarms.single.isActive, isFalse);
    expect(repo.scheduled, isEmpty);
  });

  test('reschedules an active alarm that vanished from the system', () async {
    final repeatingAlarm = AlarmEntity(
      id: 1,
      time: DateTime(2026, 4, 13, 7),
      isActive: true,
      isRepeat: true,
      weekdays: const <Weekday>[Weekday.monday],
    );
    final repo = RecordingAlarmRepo()..nativeAlarmIdToAssign = 'uuid-new';
    final cache = InMemoryAlarmCacheRepo(<AlarmEntity>[repeatingAlarm]);
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    await service.initialize();

    expect(repo.scheduled.single.id, 1);
    expect(cache.alarms.single.nativeAlarmId, 'uuid-new');
  });

  test('cancels a system alarm that was switched off in the app', () async {
    final disabledAlarm = AlarmEntity(
      id: 1,
      time: DateTime(2026, 4, 13, 7),
      isActive: false,
      nativeAlarmId: 'uuid-1',
    );
    final repo = RecordingAlarmRepo()
      ..scheduledAlarmKeys = <String>{'uuid-1'};
    final cache = InMemoryAlarmCacheRepo(<AlarmEntity>[disabledAlarm]);
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    await service.initialize();

    expect(repo.deletedIds, <int>[1]);
    expect(cache.alarms.single.nativeAlarmId, isNull);
  });

  test('leaves the cache untouched when the system query fails', () async {
    final alarm = AlarmEntity(
      id: 1,
      time: DateTime(2026, 4, 13, 7),
      isActive: true,
    );
    final repo = RecordingAlarmRepo()..failOnGetScheduledKeys = true;
    final cache = InMemoryAlarmCacheRepo(<AlarmEntity>[alarm]);
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    await service.initialize();

    expect(cache.alarms.single, alarm);
    expect(repo.scheduled, isEmpty);
    expect(repo.deletedIds, isEmpty);
  });

  test('stops a ringing repeating alarm without dropping its schedule', () async {
    final repeatingAlarm = AlarmEntity(
      id: 1,
      time: DateTime(2026, 4, 13, 7),
      isActive: true,
      isRepeat: true,
      weekdays: const <Weekday>[Weekday.monday],
      nativeAlarmId: 'uuid-1',
    );
    final repo = RecordingAlarmRepo();
    final cache = InMemoryAlarmCacheRepo(<AlarmEntity>[repeatingAlarm]);
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    await service.dismissRingingAlarm(1);

    expect(repo.stoppedIds, <int>[1]);
    expect(repo.deletedIds, isEmpty);
    expect(cache.alarms, hasLength(1));
  });
}
