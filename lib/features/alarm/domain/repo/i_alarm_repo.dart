import 'package:alarm/alarm.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';

abstract interface class IAlarmRepo {
  Future<void> requestPermissions();

  Stream<AlarmSettings> get ringStream;

  Future<void> scheduleAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  });

  Future<void> updateAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  });

  Future<void> deleteAlarm(int id);
}
