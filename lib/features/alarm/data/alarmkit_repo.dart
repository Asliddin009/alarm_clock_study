import 'package:alearn/features/alarm/data/permission.dart';
import 'package:alearn/features/alarm/domain/alarm_exception.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_ring_event.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_repo.dart';
import 'package:flutter_alarmkit/flutter_alarmkit.dart' as alarmkit;

/// Реализация поверх системного AlarmKit (iOS 26+).
///
/// В отличие от пакета `alarm`, будильник регистрируется в системе и не
/// зависит от того, жив ли процесс приложения. Расплата — системный UI алерта
/// не кастомизируется, и кнопка «Стоп» в нём есть всегда.
final class AlarmKitRepo implements IAlarmRepo {
  AlarmKitRepo({
    required AlarmPermissionService permissionService,
    alarmkit.FlutterAlarmkit? plugin,
    String tintColor = _defaultTintColor,
  }) : _permissionService = permissionService,
       _plugin = plugin ?? alarmkit.FlutterAlarmkit(),
       _tintColor = tintColor;

  static const String _defaultTintColor = '#1F6F5C';

  final AlarmPermissionService _permissionService;
  final alarmkit.FlutterAlarmkit _plugin;
  final String _tintColor;

  @override
  Stream<AlarmRingEvent> get ringStream async* {
    // Один звонок порождает несколько `updated`-событий, поэтому запоминаем,
    // о каком будильнике уже сообщили, и сбрасываем метку, когда он перестал
    // звонить.
    final reportedAlarmIds = <String>{};

    await for (final event in _plugin.alarmUpdates()) {
      final alarmId = event.alarmId;

      if (event.kind == alarmkit.AlarmUpdateKind.removed) {
        reportedAlarmIds.remove(alarmId);
        continue;
      }

      final isAlerting = event.alarm?.state == alarmkit.AlarmState.alerting;
      if (!isAlerting) {
        reportedAlarmIds.remove(alarmId);
        continue;
      }

      if (reportedAlarmIds.add(alarmId)) {
        yield AlarmRingEvent(nativeAlarmId: alarmId);
      }
    }
  }

  @override
  Future<void> requestPermissions() async {
    // Разрешение на уведомления нужно для догоняющих напоминаний,
    // авторизация AlarmKit — для самих будильников.
    await _permissionService.requestPermissions();

    final isAuthorized = await _plugin.requestAuthorization();
    if (!isAuthorized) {
      throw const AlarmRepositoryException(
        'Приложению не разрешили планировать будильники. '
        'Включите доступ в настройках системы.',
      );
    }
  }

  @override
  Future<AlarmEntity> scheduleAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) async {
    try {
      final nativeAlarmId = await _scheduleNativeAlarm(
        alarm: alarm,
        notificationTitle: notificationTitle,
        notificationBody: notificationBody,
      );
      return alarm.copyWith(nativeAlarmId: nativeAlarmId);
    } on Object catch (error) {
      throw AlarmRepositoryException(
        'Не удалось запланировать системный будильник iOS.',
        cause: error,
      );
    }
  }

  @override
  Future<AlarmEntity> updateAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) async {
    try {
      // AlarmKit не умеет менять запланированный будильник — только снять и
      // поставить заново, получив новый UUID.
      if (alarm.nativeAlarmId case final nativeAlarmId?
          when nativeAlarmId.isNotEmpty) {
        await _plugin.cancelAlarm(alarmId: nativeAlarmId);
      }

      final nextNativeAlarmId = await _scheduleNativeAlarm(
        alarm: alarm,
        notificationTitle: notificationTitle,
        notificationBody: notificationBody,
      );
      return alarm.copyWith(nativeAlarmId: nextNativeAlarmId);
    } on Object catch (error) {
      throw AlarmRepositoryException(
        'Не удалось обновить системный будильник iOS.',
        cause: error,
      );
    }
  }

  @override
  Future<void> deleteAlarm({required int id, String? nativeAlarmId}) async {
    final resolvedId = _requireNativeAlarmId(nativeAlarmId);
    final didCancel = await _plugin.cancelAlarm(alarmId: resolvedId);
    if (!didCancel) {
      throw const AlarmRepositoryException(
        'Не удалось удалить системный будильник iOS.',
      );
    }
  }

  @override
  Future<void> stopAlarm({required int id, String? nativeAlarmId}) async {
    final resolvedId = _requireNativeAlarmId(nativeAlarmId);
    // Семантика AlarmKit ровно та, что нужна: одноразовый будильник система
    // удалит сама, повторяющийся — перенесёт на следующее срабатывание.
    final didStop = await _plugin.stopAlarm(alarmId: resolvedId);
    if (!didStop) {
      throw const AlarmRepositoryException(
        'Не удалось остановить активный будильник iOS.',
      );
    }
  }

  @override
  Future<AlarmRingEvent?> getRingingAlarm() async {
    final alarms = await _plugin.getAlarms();
    for (final alarm in alarms) {
      if (alarm.state == alarmkit.AlarmState.alerting) {
        return AlarmRingEvent(nativeAlarmId: alarm.id);
      }
    }
    return null;
  }

  @override
  Future<Set<String>> getScheduledAlarmKeys() async {
    final alarms = await _plugin.getAlarms();
    return alarms.map((alarm) => alarm.id).toSet();
  }

  Future<String> _scheduleNativeAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  }) {
    final soundPath = _resolveAlarmKitSoundPath(alarm.assetAudioPath);
    final metadata = alarmkit.AlarmMetadata(
      icon: 'book.fill',
      subtitle: notificationBody,
    );
    final uiConfig = alarmkit.AlarmUIConfig(
      stopButton: const alarmkit.AlarmButtonConfig(
        text: 'Стоп',
        icon: 'stop.circle',
        textColor: '#FFFFFF',
        tintColor: '#B3261E',
      ),
    );

    if (alarm.isRepeat || alarm.weekdays.isNotEmpty) {
      return _plugin.scheduleRecurrentAlarm(
        weekdays: alarm.weekdays.map(_mapWeekday).toSet(),
        hour: alarm.time.hour,
        minute: alarm.time.minute,
        label: notificationTitle,
        tintColor: _tintColor,
        soundPath: soundPath,
        metadata: metadata,
        uiConfig: uiConfig,
      );
    }

    return _plugin.scheduleOneShotAlarm(
      timestamp: alarm.time.millisecondsSinceEpoch.toDouble(),
      label: notificationTitle,
      tintColor: _tintColor,
      soundPath: soundPath,
      metadata: metadata,
      uiConfig: uiConfig,
    );
  }

  String _requireNativeAlarmId(String? nativeAlarmId) {
    if (nativeAlarmId != null && nativeAlarmId.isNotEmpty) {
      return nativeAlarmId;
    }
    throw const AlarmRepositoryException(
      'Не найден системный идентификатор iOS будильника.',
    );
  }

  alarmkit.Weekday _mapWeekday(Weekday weekday) {
    return switch (weekday) {
      Weekday.monday => alarmkit.Weekday.monday,
      Weekday.tuesday => alarmkit.Weekday.tuesday,
      Weekday.wednesday => alarmkit.Weekday.wednesday,
      Weekday.thursday => alarmkit.Weekday.thursday,
      Weekday.friday => alarmkit.Weekday.friday,
      Weekday.saturday => alarmkit.Weekday.saturday,
      Weekday.sunday => alarmkit.Weekday.sunday,
    };
  }

  /// AlarmKit не принимает mp3. Сущность хранит логический путь, а рядом с
  /// каждым mp3 в ассетах лежит caf-близнец — подставляем его.
  ///
  /// Если формат неизвестен, возвращаем null: система сыграет свой звук, и это
  /// лучше, чем упавшее планирование.
  String? _resolveAlarmKitSoundPath(String assetAudioPath) {
    const supportedExtensions = <String>['.caf', '.aiff', '.wav'];
    final lowerCasePath = assetAudioPath.toLowerCase();

    for (final extension in supportedExtensions) {
      if (lowerCasePath.endsWith(extension)) {
        return assetAudioPath;
      }
    }

    if (lowerCasePath.endsWith('.mp3')) {
      return '${assetAudioPath.substring(0, assetAudioPath.length - 4)}.caf';
    }

    return null;
  }
}
