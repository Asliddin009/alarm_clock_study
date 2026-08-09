import 'package:alarm/alarm.dart' as alarm_plugin;
import 'package:alearn/features/alarm/data/permission.dart';
import 'package:alearn/features/alarm/domain/alarm_exception.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_repo.dart';

/// Alarms backed by the `alarm` package.
///
/// On Android this is a real system alarm. On iOS it is not: the plugin keeps a
/// background audio session alive and rings from a timer inside our own
/// process, so an alarm dies the moment the app is terminated. That is why
/// [ringsWhenAppIsTerminated] is platform-dependent, and why iOS 26+ devices
/// get [AlarmKitRepo] instead.
final class AlarmPlusRepo implements IAlarmRepo {
  AlarmPlusRepo({required AlarmPermissionService permissionService})
    : _permissionService = permissionService;

  final AlarmPermissionService _permissionService;

  @override
  bool get supportsNativeRecurrence => false;

  @override
  bool get ringsWhenAppIsTerminated => alarm_plugin.Alarm.android;

  @override
  Stream<int> get ringStream async* {
    var previousIds = <int>{};

    await for (final ringingSet in alarm_plugin.Alarm.ringing) {
      final currentIds = ringingSet.alarms.map((alarm) => alarm.id).toSet();
      for (final id in currentIds) {
        if (!previousIds.contains(id)) {
          yield id;
        }
      }
      previousIds = currentIds;
    }
  }

  @override
  Future<void> requestPermissions() {
    return _permissionService.requestPermissions();
  }

  @override
  Future<bool> hasPermissions() {
    return _permissionService.hasPermissions();
  }

  @override
  Future<AlarmEntity> scheduleAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) {
    return _setAlarm(
      alarm: alarm,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
    );
  }

  @override
  Future<AlarmEntity> updateAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) {
    return _setAlarm(
      alarm: alarm,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
    );
  }

  @override
  Future<void> deleteAlarm({required int id, String? nativeAlarmId}) async {
    final didDelete = await alarm_plugin.Alarm.stop(id);
    if (!didDelete) {
      throw const AlarmRepositoryException(
        'Не удалось удалить системный будильник.',
      );
    }
  }

  @override
  Future<void> stopAlarm({required int id, String? nativeAlarmId}) {
    // The `alarm` package has no "silence but keep scheduled": stopping a ring
    // and cancelling the schedule are the same call. Re-arming a repeating
    // alarm afterwards is AlarmService's job.
    return deleteAlarm(id: id, nativeAlarmId: nativeAlarmId);
  }

  @override
  Future<Set<int>> getScheduledAlarmIds(List<AlarmEntity> alarms) async {
    final knownIds = alarms.map((alarm) => alarm.id).toSet();
    final scheduled = await alarm_plugin.Alarm.getAlarms();
    return scheduled
        .map((settings) => settings.id)
        .where(knownIds.contains)
        .toSet();
  }

  @override
  Future<Set<int>> getRingingAlarmIds(List<AlarmEntity> alarms) async {
    final knownIds = alarms.map((alarm) => alarm.id).toSet();
    final ringingIds = <int>{};
    for (final id in knownIds) {
      if (await alarm_plugin.Alarm.isRinging(id)) {
        ringingIds.add(id);
      }
    }
    return ringingIds;
  }

  Future<AlarmEntity> _setAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) async {
    final didSet = await alarm_plugin.Alarm.set(
      alarmSettings: alarm_plugin.AlarmSettings(
        id: alarm.id,
        dateTime: alarm.nextOccurrenceAfter(DateTime.now()),
        assetAudioPath: alarm.assetAudioPath,

        loopAudio: true,
        vibrate: alarm.vibrate,
        androidFullScreenIntent: true,
        volumeSettings: alarm_plugin.VolumeSettings.fixed(
          volume: alarm.volume,
          volumeEnforced: true,
        ),
        notificationSettings: alarm_plugin.NotificationSettings(
          title: notificationTitle,
          body: notificationBody,
        ),
      ),
    );
    if (!didSet) {
      throw const AlarmRepositoryException(
        'Не удалось запланировать системный будильник.',
      );
    }
    // The plugin keys alarms by our own int id, so there is no separate native
    // handle to remember.
    return alarm.copyWith(clearNativeAlarmId: true);
  }
}

final class UnsupportedAlarmRepo implements IAlarmRepo {
  const UnsupportedAlarmRepo({required this.platformName});

  final String platformName;

  @override
  bool get supportsNativeRecurrence => false;

  @override
  bool get ringsWhenAppIsTerminated => false;

  @override
  Stream<int> get ringStream => const Stream<int>.empty();

  @override
  Future<void> requestPermissions() async {
    throw AlarmRepositoryException(
      'Платформа $platformName не поддерживает запрос разрешений для будильников.',
    );
  }

  @override
  Future<bool> hasPermissions() async => false;

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
  Future<Set<int>> getScheduledAlarmIds(List<AlarmEntity> alarms) async {
    return const <int>{};
  }

  @override
  Future<Set<int>> getRingingAlarmIds(List<AlarmEntity> alarms) async {
    return const <int>{};
  }
}
