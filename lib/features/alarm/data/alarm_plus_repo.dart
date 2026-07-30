import 'package:alarm/alarm.dart';
import 'package:alearn/features/alarm/data/permission.dart';
import 'package:alearn/features/alarm/domain/alarm_exception.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_ring_event.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_repo.dart';

/// Реализация поверх пакета `alarm`.
///
/// Держит будильник живым через фоновую аудиосессию, поэтому не переживает
/// выгрузку приложения. Используется на Android и на iOS ниже 26, где нет
/// AlarmKit.
final class AlarmPlusRepo implements IAlarmRepo {
  AlarmPlusRepo({required AlarmPermissionService permissionService})
    : _permissionService = permissionService;

  final AlarmPermissionService _permissionService;

  @override
  Stream<AlarmRingEvent> get ringStream async* {
    var previousIds = <int>{};

    await for (final ringingSet in Alarm.ringing) {
      final alarms = ringingSet.alarms.toList(growable: false);
      for (final alarm in alarms) {
        if (!previousIds.contains(alarm.id)) {
          yield AlarmRingEvent(alarmId: alarm.id);
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
  Future<AlarmEntity> scheduleAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) async {
    await _setAlarm(
      alarm: alarm,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
    );
    // Пакет адресует будильники по доменному id, отдельный системный
    // идентификатор ему не нужен.
    return alarm;
  }

  @override
  Future<AlarmEntity> updateAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) async {
    await _setAlarm(
      alarm: alarm,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
    );
    return alarm;
  }

  @override
  Future<void> deleteAlarm({required int id, String? nativeAlarmId}) async {
    final didDelete = await Alarm.stop(id);
    if (!didDelete) {
      throw AlarmRepositoryException('Не удалось удалить системный будильник.');
    }
  }

  @override
  Future<void> stopAlarm({required int id, String? nativeAlarmId}) {
    // У пакета нет разделения «заглушить» и «снять с расписания»: повторы он
    // всё равно не планирует, каждый будильник одноразовый.
    return deleteAlarm(id: id, nativeAlarmId: nativeAlarmId);
  }

  @override
  Future<AlarmRingEvent?> getRingingAlarm() async {
    final ringingAlarms = Alarm.ringing.valueOrNull?.alarms;
    if (ringingAlarms == null || ringingAlarms.isEmpty) {
      return null;
    }
    return AlarmRingEvent(alarmId: ringingAlarms.first.id);
  }

  @override
  Future<Set<String>> getScheduledAlarmKeys() async {
    final alarms = await Alarm.getAlarms();
    return alarms.map((alarm) => alarm.id.toString()).toSet();
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
  Stream<AlarmRingEvent> get ringStream => const Stream<AlarmRingEvent>.empty();

  @override
  Future<void> requestPermissions() async {
    throw AlarmRepositoryException(
      'Платформа $platformName не поддерживает запрос разрешений для будильников.',
    );
  }

  @override
  Future<AlarmEntity> scheduleAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) {
    throw AlarmRepositoryException(
      'Платформа $platformName не поддерживает планирование будильников.',
    );
  }

  @override
  Future<AlarmEntity> updateAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) {
    throw AlarmRepositoryException(
      'Платформа $platformName не поддерживает обновление будильников.',
    );
  }

  @override
  Future<void> deleteAlarm({required int id, String? nativeAlarmId}) {
    throw AlarmRepositoryException(
      'Платформа $platformName не поддерживает удаление будильников.',
    );
  }

  @override
  Future<void> stopAlarm({required int id, String? nativeAlarmId}) {
    throw AlarmRepositoryException(
      'Платформа $platformName не поддерживает остановку будильников.',
    );
  }

  @override
  Future<AlarmRingEvent?> getRingingAlarm() async => null;

  @override
  Future<Set<String>> getScheduledAlarmKeys() async => const <String>{};
}
