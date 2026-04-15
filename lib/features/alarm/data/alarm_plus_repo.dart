import 'package:alarm/alarm.dart';
import 'package:alearn/features/alarm/data/permission.dart';
import 'package:alearn/features/alarm/domain/alarm_exception.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_repo.dart';

final class AlarmPlusRepo implements IAlarmRepo {
  AlarmPlusRepo({
    required AlarmPermissionService permissionService,
  }) : _permissionService = permissionService;

  final AlarmPermissionService _permissionService;

  @override
  Stream<AlarmSettings> get ringStream => Alarm.ringStream.stream;

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
        notificationTitle: notificationTitle,
        notificationBody: notificationBody,
        loopAudio: true,
        vibrate: alarm.vibrate,
        volume: alarm.volume,
        androidFullScreenIntent: true,
      ),
    );
    if (!didSet) {
      throw AlarmRepositoryException('Не удалось запланировать системный будильник.');
    }
  }
}

final class UnsupportedAlarmRepo implements IAlarmRepo {
  const UnsupportedAlarmRepo({required this.platformName});

  final String platformName;

  @override
  Stream<AlarmSettings> get ringStream => const Stream<AlarmSettings>.empty();

  @override
  Future<void> requestPermissions() async {}

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
