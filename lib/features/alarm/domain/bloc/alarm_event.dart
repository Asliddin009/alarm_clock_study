part of 'alarm_bloc.dart';

abstract class AlarmEvent {
  const AlarmEvent();
}

class AlarmGetAllEvent extends AlarmEvent {}

class AlarmCreateEvent extends AlarmEvent {
  final DateTime dateTime;
  final bool isRepeat;
  final List<Weekday>? weekdays;
  final List<int> listCategoryId;

  const AlarmCreateEvent({
    required this.dateTime,
    required this.isRepeat,
    required this.listCategoryId,
    this.weekdays,
  });
}

class AlarmDeleteEvent extends AlarmEvent {
  final int id;

  const AlarmDeleteEvent(this.id);
}

class AlarmUpdateEvent extends AlarmEvent {
  final AlarmEntity alarmEntity;
  const AlarmUpdateEvent(this.alarmEntity);
}

class AlarmInitialEvent extends AlarmEvent {}
