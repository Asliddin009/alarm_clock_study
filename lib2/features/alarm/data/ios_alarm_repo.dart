import '../domain/entity/alarm_entity.dart';
import '../domain/i_alarm_repo.dart';

final class IosAlarmRepo implements IAlarmRepo {
  @override
  String get name => 'IosAlarmRepo';

  @override
  Future<AlarmEntity> addAlarm({
    required DateTime time,
    String? uid,
    Map<String, dynamic>? payload,
    Duration? screenWakeDuration,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<String> deleteAllAlarms() {
    throw UnimplementedError();
  }

  @override
  Future<AlarmEntity> getAlarm(int id) {
    throw UnimplementedError();
  }

  @override
  Future<List<AlarmEntity>> getAllAlarms() {
    throw UnimplementedError();
  }

  @override
  Future<String> requestPermission() {
    throw UnimplementedError();
  }

  @override
  void deleteAlarm(int id) {}
}
