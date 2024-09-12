import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/i_alarm_cache.dart';
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
}