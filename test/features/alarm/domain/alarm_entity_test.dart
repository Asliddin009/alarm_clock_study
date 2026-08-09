import 'dart:convert';

import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads legacy alarm json and normalizes fields', () {
    final legacyJson = jsonEncode(<String, dynamic>{
      'id': 1,
      'alarmId': 991,
      'time': '2026-04-13T08:03:00.000',
      'isActive': true,
      'isRepeat': null,
      'weekdays': <String>['monday'],
      'listCategoryId': <int>[7, 9],
    });

    final alarm = AlarmEntity.fromEncodedJson(legacyJson);

    expect(alarm.id, 1);
    expect(alarm.formattedTime, '08:03');
    expect(alarm.isRepeat, isTrue);
    expect(alarm.weekdays, <Weekday>[Weekday.monday]);
    expect(alarm.listCategoryIds, <int>[7, 9]);
  });

  test('round-trips the new alarm json format', () {
    final alarm = AlarmEntity(
      id: 5,
      time: DateTime(2026, 4, 13, 6, 45),
      isActive: true,
      isRepeat: true,
      weekdays: <Weekday>[Weekday.monday, Weekday.friday],
      listCategoryIds: <int>[1],
      nativeAlarmId: '59DEF72F-955D-4142-876B-DF477F37915E',
    );

    final encoded = alarm.toEncodedJson();
    final restoredAlarm = AlarmEntity.fromEncodedJson(encoded);

    expect(restoredAlarm, alarm);
    expect(restoredAlarm.nativeAlarmId, alarm.nativeAlarmId);
  });

  group('nextOccurrenceAfter', () {
    test('leaves a one-shot alarm on its original time', () {
      final alarm = AlarmEntity(
        id: 1,
        time: DateTime(2026, 4, 13, 7),
        isActive: true,
      );

      expect(
        alarm.nextOccurrenceAfter(DateTime(2026, 4, 20, 12)),
        DateTime(2026, 4, 13, 7),
      );
    });

    test('moves a daily repeat to tomorrow once today has passed', () {
      final alarm = AlarmEntity(
        id: 1,
        time: DateTime(2026, 4, 13, 7),
        isActive: true,
        isRepeat: true,
      );

      expect(
        alarm.nextOccurrenceAfter(DateTime(2026, 4, 13, 7, 1)),
        DateTime(2026, 4, 14, 7),
      );
    });

    test('lands on the next selected weekday', () {
      // 13 Apr 2026 is a Monday.
      final alarm = AlarmEntity(
        id: 1,
        time: DateTime(2026, 4, 13, 7),
        isActive: true,
        isRepeat: true,
        weekdays: const <Weekday>[Weekday.wednesday],
      );

      expect(
        alarm.nextOccurrenceAfter(DateTime(2026, 4, 13, 8)),
        DateTime(2026, 4, 15, 7),
      );
    });

    test('rolls a weekly repeat to next week when today is already past', () {
      final alarm = AlarmEntity(
        id: 1,
        time: DateTime(2026, 4, 13, 7),
        isActive: true,
        isRepeat: true,
        weekdays: const <Weekday>[Weekday.monday],
      );

      expect(
        alarm.nextOccurrenceAfter(DateTime(2026, 4, 13, 8)),
        DateTime(2026, 4, 20, 7),
      );
    });
  });
}
