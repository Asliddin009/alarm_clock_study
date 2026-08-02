import 'package:alearn/features/alarm/domain/alarm_exception.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_ring_event.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_cache_repo.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_repo.dart';

class AlarmService {
  AlarmService({
    required IAlarmRepo alarmRepo,
    required IAlarmCacheRepo alarmCacheRepo,
  }) : _alarmRepo = alarmRepo,
       _alarmCacheRepo = alarmCacheRepo {
    _ringStream = _alarmRepo.ringStream
        .asyncMap(_resolveRingingAlarmId)
        .where((id) => id != null)
        .cast<int>()
        .asBroadcastStream();
  }

  final IAlarmRepo _alarmRepo;
  final IAlarmCacheRepo _alarmCacheRepo;
  late final Stream<int> _ringStream;

  /// Идентификаторы зазвонивших будильников в доменных терминах.
  Stream<int> get ringStream => _ringStream;

  /// Будильник, звонящий прямо сейчас, — для случая, когда приложение
  /// открыли уже во время звонка и [ringStream] ничего не успел прислать.
  Future<int?> findRingingAlarmId() async {
    final AlarmRingEvent? event;
    try {
      event = await _alarmRepo.getRingingAlarm();
    } on Object {
      return null;
    }
    if (event == null) {
      return null;
    }
    return _resolveRingingAlarmId(event);
  }

  Future<void> initialize() async {
    await _alarmRepo.requestPermissions();
    await _reconcileWithSystem();
  }

  Future<List<AlarmEntity>> loadAlarms() async {
    final alarms = await _alarmCacheRepo.getAll();
    alarms.sort((left, right) => left.time.compareTo(right.time));
    return alarms;
  }

  Future<List<AlarmEntity>> createAlarm({
    required DateTime dateTime,
    required bool isRepeat,
    required List<Weekday> weekdays,
    required List<int> categoryIds,
  }) async {
    final alarms = await loadAlarms();
    final nextId = alarms.isEmpty
        ? 1
        : alarms.map((alarm) => alarm.id).reduce((a, b) => a > b ? a : b) + 1;
    final alarm = AlarmEntity(
      id: nextId,
      time: dateTime,
      isActive: true,
      isRepeat: isRepeat,
      weekdays: weekdays,
      listCategoryIds: categoryIds,
    );

    final scheduled = await _alarmRepo.scheduleAlarm(
      alarm: alarm,
      notificationTitle: _notificationTitle(alarm),
      notificationBody: _notificationBody(alarm),
    );
    try {
      // Сохраняем именно результат: в нём проставлен nativeAlarmId.
      await _alarmCacheRepo.save(scheduled);
    } on Object {
      await _alarmRepo.deleteAlarm(
        id: scheduled.id,
        nativeAlarmId: scheduled.nativeAlarmId,
      );
      rethrow;
    }
    return loadAlarms();
  }

  Future<List<AlarmEntity>> updateAlarm(AlarmEntity alarm) async {
    final alarms = await loadAlarms();
    final previousAlarm = _findAlarm(alarms, alarm.id);
    if (previousAlarm == null) {
      throw const AlarmCacheException('Будильник для обновления не найден.');
    }

    // Нативный идентификатор живёт в кэше, а не в сущности из UI.
    final scheduled = await _alarmRepo.updateAlarm(
      alarm: alarm.copyWith(nativeAlarmId: previousAlarm.nativeAlarmId),
      notificationTitle: _notificationTitle(alarm),
      notificationBody: _notificationBody(alarm),
    );
    try {
      await _alarmCacheRepo.update(scheduled);
    } on Object {
      final restored = await _alarmRepo.updateAlarm(
        alarm: previousAlarm,
        notificationTitle: _notificationTitle(previousAlarm),
        notificationBody: _notificationBody(previousAlarm),
      );
      await _alarmCacheRepo.update(restored);
      rethrow;
    }
    return loadAlarms();
  }

  Future<List<AlarmEntity>> deleteAlarm(int id) async {
    final alarms = await loadAlarms();
    final previousAlarm = _findAlarm(alarms, id);
    if (previousAlarm == null) {
      return alarms;
    }

    await _alarmRepo.deleteAlarm(
      id: id,
      nativeAlarmId: previousAlarm.nativeAlarmId,
    );
    try {
      await _alarmCacheRepo.delete(id);
    } on Object {
      final restored = await _alarmRepo.scheduleAlarm(
        alarm: previousAlarm.withoutNativeAlarmId(),
        notificationTitle: _notificationTitle(previousAlarm),
        notificationBody: _notificationBody(previousAlarm),
      );
      await _alarmCacheRepo.update(restored);
      rethrow;
    }
    return loadAlarms();
  }

  Future<List<AlarmEntity>> dismissRingingAlarm(int id) async {
    final alarms = await loadAlarms();
    final alarm = _findAlarm(alarms, id);

    await _alarmRepo.stopAlarm(id: id, nativeAlarmId: alarm?.nativeAlarmId);

    if (alarm == null) {
      return alarms;
    }

    // Повторяющееся расписание держит система — снимать его не нужно.
    if (alarm.isRepeat || alarm.weekdays.isNotEmpty) {
      return alarms;
    }

    await _alarmCacheRepo.delete(id);
    return loadAlarms();
  }

  /// Сверяет кэш с системным планировщиком.
  ///
  /// Системе доверяем больше, чем кэшу: приложение могли выгрузить, будильник
  /// мог отработать или потеряться. Без этой сверки в списке остаются
  /// «призраки», которые ничего не делают, — главная причина ощущения, что
  /// будильники работают через раз.
  Future<void> _reconcileWithSystem() async {
    final Set<String> scheduledKeys;
    try {
      scheduledKeys = await _alarmRepo.getScheduledAlarmKeys();
    } on Object {
      // Сверка — вспомогательный шаг, она не должна ронять запуск приложения.
      return;
    }

    final cachedAlarms = await _alarmCacheRepo.getAll();
    final now = DateTime.now();

    for (final alarm in cachedAlarms) {
      final key = alarm.nativeAlarmId ?? alarm.id.toString();
      final isScheduled = scheduledKeys.contains(key);

      try {
        if (alarm.isActive && !isScheduled) {
          await _restoreMissingAlarm(alarm, now);
        } else if (!alarm.isActive && isScheduled) {
          // Выключен в приложении, но всё ещё висит в системе.
          await _alarmRepo.deleteAlarm(
            id: alarm.id,
            nativeAlarmId: alarm.nativeAlarmId,
          );
          await _alarmCacheRepo.update(alarm.withoutNativeAlarmId());
        }
      } on Object {
        // Один проблемный будильник не должен останавливать сверку остальных.
        continue;
      }
    }
  }

  Future<void> _restoreMissingAlarm(AlarmEntity alarm, DateTime now) async {
    final isOneShot = !alarm.isRepeat && alarm.weekdays.isEmpty;
    if (isOneShot && alarm.time.isBefore(now)) {
      // Одноразовый будильник в прошлом уже отработал. Выключаем, но не
      // удаляем: сверка не имеет права терять данные пользователя, а
      // getScheduledAlarmKeys может вернуть пусто и по внешним причинам —
      // после переустановки приложения или сброса хранилища пакета.
      await _alarmCacheRepo.update(alarm.withoutNativeAlarmId(isActive: false));
      return;
    }

    final rescheduled = await _alarmRepo.scheduleAlarm(
      alarm: alarm.withoutNativeAlarmId(),
      notificationTitle: _notificationTitle(alarm),
      notificationBody: _notificationBody(alarm),
    );
    await _alarmCacheRepo.update(rescheduled);
  }

  /// Приводит событие звонка к доменному идентификатору будильника.
  Future<int?> _resolveRingingAlarmId(AlarmRingEvent event) async {
    if (event.alarmId != null) {
      return event.alarmId;
    }
    final nativeAlarmId = event.nativeAlarmId;
    if (nativeAlarmId == null) {
      return null;
    }

    final alarms = await _alarmCacheRepo.getAll();
    for (final alarm in alarms) {
      if (alarm.nativeAlarmId == nativeAlarmId) {
        return alarm.id;
      }
    }
    return null;
  }

  AlarmEntity? _findAlarm(List<AlarmEntity> alarms, int id) {
    for (final alarm in alarms) {
      if (alarm.id == id) {
        return alarm;
      }
    }
    return null;
  }

  String _notificationTitle(AlarmEntity alarm) {
    return 'Будильник ${alarm.formattedTime}';
  }

  String _notificationBody(AlarmEntity alarm) {
    if (alarm.listCategoryIds.isEmpty) {
      return 'Откройте приложение и решите задание, чтобы выключить будильник.';
    }
    return 'Выключите будильник через мини-квиз в приложении.';
  }
}
