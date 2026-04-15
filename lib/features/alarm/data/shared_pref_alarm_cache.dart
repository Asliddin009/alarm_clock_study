import 'package:alearn/features/alarm/domain/alarm_exception.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_cache_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefAlarmCache implements IAlarmCacheRepo {
  SharedPrefAlarmCache(this._sharedPreferences);

  static const String storageKey = 'ALARM_LIST';

  final SharedPreferences _sharedPreferences;

  @override
  Future<List<AlarmEntity>> getAll() async {
    try {
      final rawList = _sharedPreferences.getStringList(storageKey) ?? <String>[];
      final alarms = rawList
          .map(AlarmEntity.fromEncodedJson)
          .toList(growable: false)
        ..sort((left, right) => left.time.compareTo(right.time));
      final normalizedList = alarms
          .map((alarm) => alarm.toEncodedJson())
          .toList(growable: false);
      if (!listEquals(rawList, normalizedList)) {
        await _sharedPreferences.setStringList(storageKey, normalizedList);
      }
      return alarms;
    } on Object catch (error) {
      throw AlarmCacheException(
        'Не удалось прочитать сохранённые будильники.',
        cause: error,
      );
    }
  }

  @override
  Future<void> save(AlarmEntity alarm) async {
    final alarms = await getAll();
    final updatedAlarms = <AlarmEntity>[...alarms, alarm];
    await _write(updatedAlarms);
  }

  @override
  Future<void> update(AlarmEntity alarm) async {
    final alarms = await getAll();
    final updatedAlarms = alarms
        .map((currentAlarm) => currentAlarm.id == alarm.id ? alarm : currentAlarm)
        .toList(growable: false);
    await _write(updatedAlarms);
  }

  @override
  Future<void> delete(int id) async {
    final alarms = await getAll();
    final updatedAlarms = alarms
        .where((alarm) => alarm.id != id)
        .toList(growable: false);
    await _write(updatedAlarms);
  }

  Future<void> _write(List<AlarmEntity> alarms) async {
    final didSave = await _sharedPreferences.setStringList(
      storageKey,
      alarms.map((alarm) => alarm.toEncodedJson()).toList(growable: false),
    );
    if (!didSave) {
      throw const AlarmCacheException('Не удалось сохранить будильники.');
    }
  }
}
