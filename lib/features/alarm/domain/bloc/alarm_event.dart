part of 'alarm_bloc.dart';

abstract class AlarmEvent {
  const AlarmEvent();
}

class GetAllAlarmsEvent extends AlarmEvent {}

class CreateAlarmEvent extends AlarmEvent {
  final DateTime dateTime;
  final bool isRepeat;
  final List<Weekday>? weekdays;

  const CreateAlarmEvent({
    required this.dateTime,
    required this.isRepeat,
    this.weekdays,
  });
}

class DeleteAlarmEvent extends AlarmEvent {
  final int id;

  const DeleteAlarmEvent(this.id);
}
