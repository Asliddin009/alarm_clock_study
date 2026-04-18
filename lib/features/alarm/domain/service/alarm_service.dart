import 'package:alarm/alarm.dart';
import 'package:alearn/features/alarm/domain/alarm_exception.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_cache_repo.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_repo.dart';

class AlarmService {
  AlarmService({
    required IAlarmRepo alarmRepo,
    required IAlarmCacheRepo alarmCacheRepo,
  }) : _alarmRepo = alarmRepo,
       _alarmCacheRepo = alarmCacheRepo,
       _ringStream = alarmRepo.ringStream.asBroadcastStream();

  final IAlarmRepo _alarmRepo;
  final IAlarmCacheRepo _alarmCacheRepo;
  final Stream<AlarmSettings> _ringStream;

  Stream<AlarmSettings> get ringStream => _ringStream;

  Future<void> initialize() {
    return _alarmRepo.requestPermissions();
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

    await _alarmRepo.scheduleAlarm(
      alarm: alarm,
      notificationTitle: _notificationTitle(alarm),
      notificationBody: _notificationBody(alarm),
    );
    try {
      await _alarmCacheRepo.save(alarm);
    } on Object {
      await _alarmRepo.deleteAlarm(alarm.id);
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

    await _alarmRepo.updateAlarm(
      alarm: alarm,
      notificationTitle: _notificationTitle(alarm),
      notificationBody: _notificationBody(alarm),
    );
    try {
      await _alarmCacheRepo.update(alarm);
    } on Object {
      await _alarmRepo.updateAlarm(
        alarm: previousAlarm,
        notificationTitle: _notificationTitle(previousAlarm),
        notificationBody: _notificationBody(previousAlarm),
      );
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

    await _alarmRepo.deleteAlarm(id);
    try {
      await _alarmCacheRepo.delete(id);
    } on Object {
      await _alarmRepo.scheduleAlarm(
        alarm: previousAlarm,
        notificationTitle: _notificationTitle(previousAlarm),
        notificationBody: _notificationBody(previousAlarm),
      );
      rethrow;
    }
    return loadAlarms();
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
