import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';

abstract interface class IAlarmCashRepo {
  String get name;

  Future<bool> saveAlarmEntity(AlarmEntity alarm);
  Future<bool> updateAlarmEntity(AlarmEntity alarm);
  Future<List<AlarmEntity>> getAllAlarms();

  Future<bool> deleteAlarm(int id);
}
