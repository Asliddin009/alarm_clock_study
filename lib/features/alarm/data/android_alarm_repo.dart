import 'package:alarm/alarm.dart';
import 'package:alearn/features/alarm/domain/i_alarm_repo.dart';

final class AndroidAlarmRepo implements IAlarmRepo {
  @override
  String get name => 'AndroidAlarmRepo';

  @override
  Future<bool> deleteAlarm(int id) async {
    return Alarm.stop(id);
  }

  @override
  AlarmSettings getAlarm(int id) {
    final alarm = Alarm.getAlarm(id);
    if (alarm == null) {
      throw Exception('Alarm not found');
    }
    return alarm;
  }

  @override
  List<AlarmSettings> getAllAlarms() {
    final alarms = Alarm.getAlarms()
      ..sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    return alarms;
  }

  @override
  void requestPermission() {}

  @override
  Future<bool> addAlarm({
    required DateTime time,
    required String notificationTitle,
    required String notificationBody,
    required int id,
    String urlAudio = 'assets/marimba.mp3',
    bool loopAudio = true,
    bool vibrate = true,
    double? volume,
    double fadeDuration = 0.0,
    bool enableNotificationOnKill = true,
    bool androidFullScreenIntent = true,
  }) {
    //create Alarm
    return Alarm.set(
      alarmSettings: AlarmSettings(
        id: id,
        dateTime: time,
        assetAudioPath: 'assets/marimba.mp3',
        notificationTitle: notificationTitle,
        notificationBody: notificationBody,
        loopAudio: loopAudio,
        vibrate: vibrate,
        volume: volume,
        fadeDuration: fadeDuration,
        enableNotificationOnKill: enableNotificationOnKill,
        androidFullScreenIntent: androidFullScreenIntent,
      ),
    );
  }
}
