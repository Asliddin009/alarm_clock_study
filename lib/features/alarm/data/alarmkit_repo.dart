import 'package:alearn/features/alarm/data/permission.dart';
import 'package:alearn/features/alarm/domain/alarm_exception.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_cache_repo.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_repo.dart';
import 'package:flutter_alarmkit/flutter_alarmkit.dart' as alarmkit;

/// Alarms registered with Apple's AlarmKit (iOS 26+).
///
/// The alarm lives in the system, not in our process, so it rings after the app
/// has been swiped away, evicted for memory, or never launched since boot. It
/// also breaks through silent mode and Focus without a Critical Alerts
/// entitlement.
///
/// The trade-off is that AlarmKit owns the ringing UI: its alert always offers
/// a Stop button, so the quiz can be an incentive but never a gate.
final class AlarmKitRepo implements IAlarmRepo {
  AlarmKitRepo({
    required AlarmPermissionService permissionService,
    required IAlarmCacheRepo alarmCacheRepo,
    alarmkit.FlutterAlarmkit? plugin,
  }) : _permissionService = permissionService,
       _alarmCacheRepo = alarmCacheRepo,
       _plugin = plugin ?? alarmkit.FlutterAlarmkit();

  /// Tint applied to the system alarm alert, matching the app's brand green.
  static const String _tintColor = '#1F6F5C';

  final AlarmPermissionService _permissionService;
  final IAlarmCacheRepo _alarmCacheRepo;
  final alarmkit.FlutterAlarmkit _plugin;

  @override
  bool get supportsNativeRecurrence => true;

  @override
  bool get ringsWhenAppIsTerminated => true;

  @override
  Stream<int> get ringStream async* {
    // The alarm may well fire into a process that has just been launched for
    // it, so this stream is a live signal only — the authoritative check on
    // startup is getRingingAlarmIds.
    await for (final event in _plugin.alarmUpdates()) {
      if (event.alarm?.state != alarmkit.AlarmState.alerting) {
        continue;
      }
      final id = await _resolveAppId(event.alarmId);
      if (id != null) {
        yield id;
      }
    }
  }

  @override
  Future<void> requestPermissions() async {
    // Notifications still matter for everything the app sends outside of the
    // alarm itself, and AlarmKit has its own separate authorization.
    await _permissionService.requestPermissions();
    await _plugin.requestAuthorization();
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      final state = await _plugin.getAuthorizationState();
      return state == alarmkit.AlarmAuthorizationState.authorized;
    } on Object {
      return false;
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
        label: notificationTitle,
        subtitle: notificationBody,
      );
      return alarm.copyWith(nativeAlarmId: nativeAlarmId);
    } on AlarmRepositoryException {
      rethrow;
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
      // AlarmKit has no in-place edit: cancel first, then re-register. Doing it
      // in this order avoids briefly holding two alarms for the same slot.
      await _cancelNativeAlarm(alarm.nativeAlarmId);
      final nativeAlarmId = await _scheduleNativeAlarm(
        alarm: alarm,
        label: notificationTitle,
        subtitle: notificationBody,
      );
      return alarm.copyWith(nativeAlarmId: nativeAlarmId);
    } on AlarmRepositoryException {
      rethrow;
    } on Object catch (error) {
      throw AlarmRepositoryException(
        'Не удалось обновить системный будильник iOS.',
        cause: error,
      );
    }
  }

  @override
  Future<void> deleteAlarm({required int id, String? nativeAlarmId}) async {
    // A missing native id means the system never took the alarm (or already
    // dropped it), so there is nothing left to cancel — let the caller clean
    // up its own cache instead of failing on it.
    if (nativeAlarmId == null || nativeAlarmId.isEmpty) {
      return;
    }
    try {
      await _plugin.cancelAlarm(alarmId: nativeAlarmId);
    } on Object catch (error) {
      throw AlarmRepositoryException(
        'Не удалось удалить системный будильник iOS.',
        cause: error,
      );
    }
  }

  @override
  Future<void> stopAlarm({required int id, String? nativeAlarmId}) async {
    if (nativeAlarmId == null || nativeAlarmId.isEmpty) {
      return;
    }
    try {
      await _plugin.stopAlarm(alarmId: nativeAlarmId);
    } on Object catch (error) {
      throw AlarmRepositoryException(
        'Не удалось остановить активный будильник iOS.',
        cause: error,
      );
    }
  }

  @override
  Future<Set<int>> getScheduledAlarmIds(List<AlarmEntity> alarms) {
    return _matchSystemAlarms(alarms, (state) => true);
  }

  @override
  Future<Set<int>> getRingingAlarmIds(List<AlarmEntity> alarms) {
    return _matchSystemAlarms(
      alarms,
      (state) => state == alarmkit.AlarmState.alerting,
    );
  }

  /// Maps the alarms the system reports back onto our own ids.
  Future<Set<int>> _matchSystemAlarms(
    List<AlarmEntity> alarms,
    bool Function(alarmkit.AlarmState state) matches,
  ) async {
    final systemAlarms = await _plugin.getAlarms();
    final matchedNativeIds = <String>{
      for (final systemAlarm in systemAlarms)
        if (matches(systemAlarm.state)) systemAlarm.id,
    };
    return <int>{
      for (final alarm in alarms)
        if (alarm.nativeAlarmId case final nativeAlarmId?
            when matchedNativeIds.contains(nativeAlarmId))
          alarm.id,
    };
  }

  Future<int?> _resolveAppId(String nativeAlarmId) async {
    final alarms = await _alarmCacheRepo.getAll();
    for (final alarm in alarms) {
      if (alarm.nativeAlarmId == nativeAlarmId) {
        return alarm.id;
      }
    }
    return null;
  }

  Future<String> _scheduleNativeAlarm({
    required AlarmEntity alarm,
    required String label,
    required String subtitle,
  }) {
    final metadata = alarmkit.AlarmMetadata(
      icon: 'book.fill',
      subtitle: subtitle,
    );
    // AlarmKit's alert always carries a Stop button that really does stop the
    // alarm, so it is labelled honestly. Nudging the user into the quiz is the
    // subtitle's job until the widget extension gets a custom "Учить" button.
    const uiConfig = alarmkit.AlarmUIConfig(
      stopButton: alarmkit.AlarmButtonConfig(
        text: 'Стоп',
        icon: 'stop.fill',
        textColor: '#FFFFFF',
        tintColor: _tintColor,
      ),
    );
    final soundPath = _resolveSoundPath(alarm.assetAudioPath);

    if (alarm.isRepeat || alarm.weekdays.isNotEmpty) {
      return _plugin.scheduleRecurrentAlarm(
        // "Repeat" with no weekdays picked means every day.
        weekdays: alarm.weekdays.isEmpty
            ? alarmkit.Weekday.everyday
            : alarm.weekdays.map(_mapWeekday).toSet(),
        hour: alarm.time.hour,
        minute: alarm.time.minute,
        label: label,
        tintColor: _tintColor,
        soundPath: soundPath,
        uiConfig: uiConfig,
        metadata: metadata,
      );
    }

    return _plugin.scheduleOneShotAlarm(
      timestamp: _resolveFireTime(alarm).millisecondsSinceEpoch.toDouble(),
      label: label,
      tintColor: _tintColor,
      soundPath: soundPath,
      uiConfig: uiConfig,
      metadata: metadata,
    );
  }

  /// The moment a one-shot alarm should fire, guaranteed to be in the future.
  ///
  /// AlarmKit rejects a fixed date in the past outright
  /// (`AlarmServiceError.invalidInput`), unlike the `alarm` package, which just
  /// rings straight away. A "ring now" request is already a hair in the past by
  /// the time it reaches the system, so it is nudged forward; a time the user
  /// genuinely missed is reported instead of being silently moved.
  DateTime _resolveFireTime(AlarmEntity alarm) {
    final now = DateTime.now();
    final fireTime = alarm.nextOccurrenceAfter(now);
    if (fireTime.isAfter(now)) {
      return fireTime;
    }
    if (now.difference(fireTime) <= const Duration(minutes: 1)) {
      return now.add(const Duration(seconds: 3));
    }
    throw const AlarmRepositoryException(
      'Это время уже прошло — выберите время в будущем.',
    );
  }

  Future<void> _cancelNativeAlarm(String? nativeAlarmId) async {
    if (nativeAlarmId == null || nativeAlarmId.isEmpty) {
      return;
    }
    await _plugin.cancelAlarm(alarmId: nativeAlarmId);
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

  /// AlarmKit only plays system-sound formats, so every ringtone is shipped as
  /// a `.caf` next to its `.mp3`. Returning null falls back to the default
  /// system alarm sound rather than silence.
  String? _resolveSoundPath(String assetAudioPath) {
    const supportedExtensions = <String>['.caf', '.wav', '.aiff'];
    final lowerCasePath = assetAudioPath.toLowerCase();
    if (supportedExtensions.any(lowerCasePath.endsWith)) {
      return assetAudioPath;
    }
    if (lowerCasePath.endsWith('.mp3')) {
      return '${assetAudioPath.substring(0, assetAudioPath.length - 4)}.caf';
    }
    return null;
  }
}
