import '../domain/entity/alarm_entity.dart';
import '../domain/i_alarm_repo.dart';

final class AndroidAlarmRepo implements IAlarmRepo {
  @override
  String get name => 'AndroidAlarmRepo';

  @override
  Future<AlarmEntity> addAlarm({
    required DateTime time,
    String uid = 'io.flutter.embedding.android.NormalTheme',
    Map<String, dynamic> payload = const {'holy': 'Moly'},
    Duration? screenWakeDuration,
  }) async {
    throw Exception();
  }

  @override
  void deleteAlarm(int id) {}

  @override
  Future<String> deleteAllAlarms() {
    throw UnimplementedError();
  }

  @override
  Future<List<AlarmEntity>> getAllAlarms() async {
    return [];
    // return listAlarmItem.map((e) => _parseAlarm(e)).toList();
  }

  // AlarmEntity _parseAlarm(AlarmItem alarm) {
  //   return AlarmEntity(
  //       id: alarm.id!, time: alarm.time!, status: alarm.status.toString());
  // }

  @override
  void requestPermission() {}

  @override
  Future<AlarmEntity> getAlarm(int id) {
    throw UnimplementedError();
  }
}
