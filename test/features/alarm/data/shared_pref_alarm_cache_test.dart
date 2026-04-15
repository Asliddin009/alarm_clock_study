import 'dart:convert';

import 'package:alearn/features/alarm/data/shared_pref_alarm_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('reads legacy storage and rewrites it to the new schema', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      SharedPrefAlarmCache.storageKey: <String>[
        jsonEncode(<String, dynamic>{
          'id': 1,
          'alarmId': 77,
          'time': '2026-04-13T08:03:00.000',
          'isActive': true,
          'weekdays': <String>['monday'],
          'listCategoryId': <int>[5],
        }),
      ],
    });
    final sharedPreferences = await SharedPreferences.getInstance();
    final cache = SharedPrefAlarmCache(sharedPreferences);

    final alarms = await cache.getAll();
    final normalizedJson = jsonDecode(
      sharedPreferences.getStringList(SharedPrefAlarmCache.storageKey)!.single,
    ) as Map<String, dynamic>;

    expect(alarms.single.listCategoryIds, <int>[5]);
    expect(normalizedJson.containsKey('listCategoryIds'), isTrue);
    expect(normalizedJson.containsKey('alarmId'), isFalse);
  });
}
