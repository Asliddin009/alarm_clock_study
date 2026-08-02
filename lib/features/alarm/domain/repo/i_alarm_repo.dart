import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_ring_event.dart';

/// Контракт системного планировщика будильников.
///
/// Интерфейс намеренно не знает ни про пакет `alarm`, ни про AlarmKit — иначе
/// вторая реализация не сможет его удовлетворить.
abstract interface class IAlarmRepo {
  Future<void> requestPermissions();

  Stream<AlarmRingEvent> get ringStream;

  /// Будильник, который звонит прямо сейчас, или null.
  ///
  /// [ringStream] ловит только те звонки, что случились при живом приложении.
  /// Когда приложение открывают уже звонящим будильником, узнать об этом можно
  /// лишь опросом системы на старте.
  Future<AlarmRingEvent?> getRingingAlarm();

  /// Возвращает будильник с проставленным [AlarmEntity.nativeAlarmId].
  ///
  /// Вызывающая сторона обязана сохранить в кэш именно результат, а не
  /// исходную сущность, иначе системный идентификатор потеряется и будильник
  /// станет неотменяемым.
  Future<AlarmEntity> scheduleAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  });

  /// Смотри замечание про возвращаемое значение в [scheduleAlarm].
  Future<AlarmEntity> updateAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  });

  /// Снимает будильник с расписания насовсем.
  Future<void> deleteAlarm({required int id, String? nativeAlarmId});

  /// Глушит звонящий будильник, не трогая повторяющееся расписание.
  Future<void> stopAlarm({required int id, String? nativeAlarmId});

  /// Ключи будильников, реально стоящих в системном планировщике.
  ///
  /// Ключ — это `nativeAlarmId`, а если реализация адресует будильники по
  /// доменному id (как пакет `alarm`), то `id.toString()`. Нужно для сверки
  /// кэша с системой на старте приложения.
  Future<Set<String>> getScheduledAlarmKeys();
}
