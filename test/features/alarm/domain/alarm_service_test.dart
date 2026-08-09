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

  test('persists the native id the system handed back', () async {
    final repo = RecordingAlarmRepo();
    final cache = InMemoryAlarmCacheRepo();
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    await service.createAlarm(
      dateTime: DateTime(2026, 4, 13, 7, 30),
      isRepeat: false,
      weekdays: const <Weekday>[],
      categoryIds: const <int>[],
    );

    // Without this the alarm becomes an uncancellable ghost: AlarmKit's UUID is
    // the only handle to it, and it has to outlive the process.
    expect(cache.alarms.single.nativeAlarmId, 'native-1');
  });

  test('re-arms an alarm the system has dropped', () async {
    final alarm = AlarmEntity(
      id: 1,
      time: DateTime.now().add(const Duration(days: 1)),
      isActive: true,
    );
    final repo = RecordingAlarmRepo()..systemScheduledIds = <int>{};
    final cache = InMemoryAlarmCacheRepo(<AlarmEntity>[alarm]);
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    await service.syncWithSystem();

    expect(repo.scheduled.single.id, 1);
    expect(cache.alarms.single.nativeAlarmId, 'native-1');
  });

  test('leaves alarms the system still holds untouched', () async {
    final alarm = AlarmEntity(
      id: 1,
      time: DateTime.now().add(const Duration(days: 1)),
      isActive: true,
      nativeAlarmId: 'native-1',
    );
    final repo = RecordingAlarmRepo()..systemScheduledIds = <int>{1};
    final cache = InMemoryAlarmCacheRepo(<AlarmEntity>[alarm]);
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    await service.syncWithSystem();

    expect(repo.scheduled, isEmpty);
  });

  test('drops a one-shot alarm whose time has already passed', () async {
    final alarm = AlarmEntity(
      id: 1,
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isActive: true,
    );
    final repo = RecordingAlarmRepo()..systemScheduledIds = <int>{};
    final cache = InMemoryAlarmCacheRepo(<AlarmEntity>[alarm]);
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    final alarms = await service.syncWithSystem();

    expect(alarms, isEmpty);
    expect(repo.scheduled, isEmpty);
  });

  test('re-arms a repeat after dismissal when the platform cannot', () async {
    final alarm = AlarmEntity(
      id: 1,
      time: DateTime(2026, 4, 13, 7),
      isActive: true,
      isRepeat: true,
      weekdays: const <Weekday>[Weekday.monday],
    );
    final repo = RecordingAlarmRepo(supportsNativeRecurrence: false);
    final cache = InMemoryAlarmCacheRepo(<AlarmEntity>[alarm]);
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    await service.dismissRingingAlarm(1);

    expect(repo.stoppedIds, <int>[1]);
    // Stopping also cancels the schedule on such a platform, so the repeat has
    // to be put back or it never rings again.
    expect(repo.scheduled.single.time.weekday, DateTime.monday);
    expect(cache.alarms.single.id, 1);
  });

  test('lets the platform keep its own repeat schedule', () async {
    final alarm = AlarmEntity(
      id: 1,
      time: DateTime(2026, 4, 13, 7),
      isActive: true,
      isRepeat: true,
      weekdays: const <Weekday>[Weekday.monday],
      nativeAlarmId: 'native-1',
    );
    final repo = RecordingAlarmRepo();
    final cache = InMemoryAlarmCacheRepo(<AlarmEntity>[alarm]);
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    await service.dismissRingingAlarm(1);

    expect(repo.stoppedIds, <int>[1]);
    expect(repo.scheduled, isEmpty);
    expect(repo.deletedIds, isEmpty);
  });

  test('deletes a one-shot alarm once dismissed', () async {
    final alarm = AlarmEntity(
      id: 1,
      time: DateTime(2026, 4, 13, 7),
      isActive: true,
      nativeAlarmId: 'native-1',
    );
    final repo = RecordingAlarmRepo();
    final cache = InMemoryAlarmCacheRepo(<AlarmEntity>[alarm]);
    final service = AlarmService(alarmRepo: repo, alarmCacheRepo: cache);

    final alarms = await service.dismissRingingAlarm(1);

    expect(alarms, isEmpty);
    expect(repo.deletedIds, <int>[1]);
    // Stop and delete are the same call on some platforms, so only one fires.
    expect(repo.stoppedIds, isEmpty);
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
