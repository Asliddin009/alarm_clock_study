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
  final Stream<int> _ringStream;

  Stream<int> get ringStream => _ringStream;

  /// Whether an alarm set here survives the app being terminated.
  bool get ringsWhenAppIsTerminated => _alarmRepo.ringsWhenAppIsTerminated;

  Future<void> initialize() async {
    await _alarmRepo.requestPermissions();
    await syncWithSystem();
  }

  /// Reconciles the cache against what the operating system actually holds.
  ///
  /// The system is the source of truth. An alarm the OS no longer knows about
  /// was dropped by a reboot or a termination, and silently stays "on" in the
  /// UI while never ringing again — the single biggest cause of a missed alarm.
  /// Re-arming here is what makes the list mean something.
  Future<List<AlarmEntity>> syncWithSystem() async {
    final alarms = await loadAlarms();
    if (alarms.isEmpty) {
      return alarms;
    }

    final Set<int> scheduledIds;
    try {
      scheduledIds = await _alarmRepo.getScheduledAlarmIds(alarms);
    } on Object {
      // A platform that cannot report its schedule gives us nothing to
      // reconcile against; leaving the cache untouched beats guessing.
      return alarms;
    }

    final now = DateTime.now();
    for (final alarm in alarms) {
      if (!alarm.isActive || scheduledIds.contains(alarm.id)) {
        continue;
      }
      final isExpiredOneShot =
          !alarm.isRepeat && alarm.weekdays.isEmpty && !alarm.time.isAfter(now);
      if (isExpiredOneShot) {
        await _alarmCacheRepo.delete(alarm.id);
        continue;
      }
      await _rearm(alarm);
    }

    return loadAlarms();
  }

  /// Ids of the alarms ringing right now.
  ///
  /// On iOS 26+ an alarm can fire into a process that was launched for it, so
  /// the live [ringStream] may never have been listened to — asking the system
  /// on startup and on resume is what catches those.
  Future<Set<int>> getRingingAlarmIds() async {
    try {
      return await _alarmRepo.getRingingAlarmIds(await loadAlarms());
    } on Object {
      return const <int>{};
    }
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

    final scheduledAlarm = await _alarmRepo.scheduleAlarm(
      alarm: alarm,
      notificationTitle: _notificationTitle(alarm),
      notificationBody: _notificationBody(alarm),
    );
    try {
      await _alarmCacheRepo.save(scheduledAlarm);
    } on Object {
      await _alarmRepo.deleteAlarm(
        id: scheduledAlarm.id,
        nativeAlarmId: scheduledAlarm.nativeAlarmId,
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

    // Carry the native handle over: the caller edits a UI-shaped entity and has
    // no reason to know the system's identifier for it.
    final updatedAlarm = await _alarmRepo.updateAlarm(
      alarm: alarm.copyWith(nativeAlarmId: previousAlarm.nativeAlarmId),
      notificationTitle: _notificationTitle(alarm),
      notificationBody: _notificationBody(alarm),
    );
    try {
      await _alarmCacheRepo.update(updatedAlarm);
    } on Object {
      await _alarmRepo.updateAlarm(
        alarm: previousAlarm.copyWith(
          nativeAlarmId: updatedAlarm.nativeAlarmId,
        ),
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

    await _alarmRepo.deleteAlarm(
      id: id,
      nativeAlarmId: previousAlarm.nativeAlarmId,
    );
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

  Future<List<AlarmEntity>> dismissRingingAlarm(int id) async {
    final alarms = await loadAlarms();
    final alarm = _findAlarm(alarms, id);

    if (alarm == null) {
      await _alarmRepo.stopAlarm(id: id);
      return alarms;
    }

    // Exactly one call per path: on platforms without a native "silence but
    // keep scheduled", stop and cancel are the same operation, and calling
    // both would fail on the second.
    if (!alarm.isRepeat && alarm.weekdays.isEmpty) {
      await _alarmRepo.deleteAlarm(id: id, nativeAlarmId: alarm.nativeAlarmId);
      await _alarmCacheRepo.delete(id);
      return loadAlarms();
    }

    await _alarmRepo.stopAlarm(id: id, nativeAlarmId: alarm.nativeAlarmId);
    if (!_alarmRepo.supportsNativeRecurrence) {
      // That stop also wiped the repeat off the schedule — put it back.
      await _rearm(alarm);
      return loadAlarms();
    }

    return alarms;
  }

  /// Schedules [alarm] again for its next occurrence and persists the result.
  Future<void> _rearm(AlarmEntity alarm) async {
    final nextAlarm = alarm.copyWith(
      time: alarm.nextOccurrenceAfter(DateTime.now()),
    );
    final scheduledAlarm = await _alarmRepo.scheduleAlarm(
      alarm: nextAlarm,
      notificationTitle: _notificationTitle(nextAlarm),
      notificationBody: _notificationBody(nextAlarm),
    );
    await _alarmCacheRepo.update(scheduledAlarm);
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
