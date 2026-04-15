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
    );

    final encoded = alarm.toEncodedJson();
    final restoredAlarm = AlarmEntity.fromEncodedJson(encoded);

    expect(restoredAlarm, alarm);
  });
}
