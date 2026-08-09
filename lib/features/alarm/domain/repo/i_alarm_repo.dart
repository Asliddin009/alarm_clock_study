import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';

/// Access to whatever alarm scheduler the current platform offers.
///
/// Deliberately free of plugin types: on iOS 26+ this is backed by the system
/// AlarmKit scheduler, everywhere else by the `alarm` package, and nothing in
/// the domain layer should be able to tell which one it got.
abstract interface class IAlarmRepo {
  /// Whether the platform keeps repeating alarms armed on its own.
  ///
  /// When false the app has to re-arm a repeating alarm itself after it rings.
  bool get supportsNativeRecurrence;

  /// Whether an alarm scheduled here survives the app being terminated.
  ///
  /// False means the alarm only rings while the process is alive, and the user
  /// deserves to be told so.
  bool get ringsWhenAppIsTerminated;

  Future<void> requestPermissions();

  /// Whether every permission needed to actually ring an alarm is granted.
  Future<bool> hasPermissions();

  /// Emits [AlarmEntity.id] when the system starts ringing that alarm.
  Stream<int> get ringStream;

  /// Schedules [alarm] and returns it carrying the system's identifier.
  ///
  /// The returned entity — not the one passed in — is what callers must
  /// persist: dropping the identifier leaves an alarm nothing can cancel.
  Future<AlarmEntity> scheduleAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  });

  /// Reschedules [alarm] and returns it carrying the system's identifier.
  Future<AlarmEntity> updateAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  });

  /// Removes the alarm from the system schedule for good.
  Future<void> deleteAlarm({required int id, String? nativeAlarmId});

  /// Silences an alarm that is ringing right now, leaving its schedule intact.
  Future<void> stopAlarm({required int id, String? nativeAlarmId});

  /// The subset of [alarms] the system still has on its schedule.
  ///
  /// The system is the source of truth: anything missing here was dropped by
  /// the OS (reboot, app termination, manual removal) and needs re-arming.
  Future<Set<int>> getScheduledAlarmIds(List<AlarmEntity> alarms);

  /// The subset of [alarms] that are ringing at this very moment.
  Future<Set<int>> getRingingAlarmIds(List<AlarmEntity> alarms);
}
