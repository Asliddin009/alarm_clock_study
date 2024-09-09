import 'entity/alarm_entity.dart';

abstract interface class IAlarmRepo {
  String get name;

  void requestPermission();
  Future<AlarmEntity> getAlarm(int id);
  Future<List<AlarmEntity>> getAllAlarms();
  Future<AlarmEntity> addAlarm({
    required DateTime time,
    String uid = 'TEST UID',
    Map<String, dynamic> payload = const {'holy': 'Moly'},
    Duration? screenWakeDuration,
  });
  void deleteAlarm(int id);
  void deleteAllAlarms();
}
