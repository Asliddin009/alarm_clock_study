import 'package:alarm/alarm.dart';

abstract interface class IAlarmRepo {
  String get name;

  void requestPermission();
  AlarmSettings getAlarm(int id);
  List<AlarmSettings> getAllAlarms();
  Future<bool> addAlarm({
    required DateTime time,
    required String notificationTitle,
    required String notificationBody,
    required int id,
    String urlAudio = '',
    bool loopAudio = true,
    bool vibrate = true,
    double? volume,
    double fadeDuration = 0.0,
    bool enableNotificationOnKill = true,
    bool androidFullScreenIntent = true,
  });
  Future<bool> deleteAlarm(int id);
}
