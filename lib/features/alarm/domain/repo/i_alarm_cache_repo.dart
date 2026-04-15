import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';

abstract interface class IAlarmCacheRepo {
  Future<List<AlarmEntity>> getAll();

  Future<void> save(AlarmEntity alarm);

  Future<void> update(AlarmEntity alarm);

  Future<void> delete(int id);
}
