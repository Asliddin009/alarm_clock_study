import 'package:alarm/alarm.dart';
import 'package:alearn/features/alarm/data/permission.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_repo.dart';

final class AlarmPlusRepo implements IAlarmRepo {
  @override
  String get name => 'AlarmPlusRepo';

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
    final alarms = Alarm.getAlarms()..sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    return alarms;
  }

  @override
  Future<void> requestPermission() async {
    await AlarmPermissions.checkAndroidNotificationPermission();
    await AlarmPermissions.checkAndroidScheduleExactAlarmPermission();
    await AlarmPermissions.checkAndroidExternalStoragePermission();
  }

  @override
  Future<bool> createAlarm({
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
        assetAudioPath: urlAudio,
        notificationTitle: notificationTitle,
        notificationBody: notificationBody,
        loopAudio: loopAudio,
        vibrate: vibrate,
        volume: 0,
        fadeDuration: fadeDuration,
        enableNotificationOnKill: enableNotificationOnKill,
        androidFullScreenIntent: androidFullScreenIntent,
      ),
    );
  }

  @override
  Stream getRingStream() {
    return Alarm.ringStream.stream;
  }
}
