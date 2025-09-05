import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_cache_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefAlarmCache implements IAlarmCashRepo {
  @override
  String get name => 'SharedPrefAlarmCache';
  final String key = 'ALARM_LIST';

  @override
  Future<List<AlarmEntity>> getAllAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];
    return list.map(AlarmEntity.fromString).toList();
  }

  @override
  Future<bool> saveAlarmEntity(AlarmEntity alarm) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(key) ?? [];
      await prefs.setStringList(
        key,
        [...list, alarm.toString()],
      );
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteAlarm(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(key) ?? [];
      final newList = list.where((element) => AlarmEntity.fromString(element).id != id).toList();
      await prefs.setStringList(key, newList);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> updateAlarmEntity(AlarmEntity alarm) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(key) ?? [];
      final newList = list.map((element) {
        final alarmEntity = AlarmEntity.fromString(element);
        if (alarmEntity.id == alarm.id) {
          return alarm.toString();
        }
        return element;
      }).toList();
      await prefs.setStringList(key, newList);
      return true;
    } catch (_) {
      return false;
    }
  }
}
