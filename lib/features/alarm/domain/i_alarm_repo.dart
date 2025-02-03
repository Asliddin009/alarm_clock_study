import 'package:alarm/alarm.dart';

abstract interface class IAlarmRepo {
  String get name;

  /// запрашивает нужные разрешения
  void requestPermission();

  Stream getRingStream();

  /// получает будильник по [id]
  AlarmSettings getAlarm(int id);

  /// получает все будильники которые есть в системе
  List<AlarmSettings> getAllAlarms();

  /// Создает будильник который прозвучит в [time]
  Future<bool> createAlarm({
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

  /// удаляет будильник по [id]
  Future<bool> deleteAlarm(int id);
}
