import 'package:alarm/alarm.dart';
import 'package:alearn/features/alarm/data/permission.dart';
import 'package:alearn/features/alarm/domain/alarm_exception.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_repo.dart';

final class AlarmPlusRepo implements IAlarmRepo {
  AlarmPlusRepo({required AlarmPermissionService permissionService})
    : _permissionService = permissionService;

  final AlarmPermissionService _permissionService;

  @override
  Stream<AlarmSettings> get ringStream async* {
    var previousIds = <int>{};

    await for (final ringingSet in Alarm.ringing) {
      final alarms = ringingSet.alarms.toList(growable: false);
      for (final alarm in alarms) {
        if (!previousIds.contains(alarm.id)) {
          yield alarm;
        }
      }
      previousIds = alarms.map((alarm) => alarm.id).toSet();
    }
  }

  @override
  Future<void> requestPermissions() {
    return _permissionService.requestPermissions();
  }

  @override
  Future<void> scheduleAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) async {
    await _setAlarm(
      alarm: alarm,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
    );
  }

  @override
  Future<void> updateAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) async {
    await _setAlarm(
      alarm: alarm,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
    );
  }

  @override
  Future<void> deleteAlarm(int id) async {
    final didDelete = await Alarm.stop(id);
    if (!didDelete) {
      throw AlarmRepositoryException('Не удалось удалить системный будильник.');
    }
  }

  Future<void> _setAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) async {
    final didSet = await Alarm.set(
      alarmSettings: AlarmSettings(
        id: alarm.id,
        dateTime: alarm.time,
        assetAudioPath: alarm.assetAudioPath,

        loopAudio: true,
        vibrate: alarm.vibrate,
        androidFullScreenIntent: true,
        volumeSettings: VolumeSettings.fixed(
          volume: alarm.volume,
          volumeEnforced: true,
        ),
        notificationSettings: NotificationSettings(
          title: notificationTitle,
          body: notificationBody,
        ),
      ),
    );
    if (!didSet) {
      throw AlarmRepositoryException(
        'Не удалось запланировать системный будильник.',
      );
    }
  }
}

final class UnsupportedAlarmRepo implements IAlarmRepo {
  const UnsupportedAlarmRepo({required this.platformName});

  final String platformName;

  @override
  Stream<AlarmSettings> get ringStream => const Stream<AlarmSettings>.empty();

  @override
  Future<void> requestPermissions() async {
    throw AlarmRepositoryException(
      'Платформа $platformName не поддерживает запрос разрешений для будильников.',
    );
  }

  @override
  Future<void> scheduleAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) {
    throw AlarmRepositoryException(
      'Платформа $platformName не поддерживает планирование будильников.',
    );
  }

  @override
  Future<void> updateAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) {
    throw AlarmRepositoryException(
      'Платформа $platformName не поддерживает обновление будильников.',
    );
  }

  @override
  Future<void> deleteAlarm(int id) {
    throw AlarmRepositoryException(
      'Платформа $platformName не поддерживает удаление будильников.',
    );
  }
}
