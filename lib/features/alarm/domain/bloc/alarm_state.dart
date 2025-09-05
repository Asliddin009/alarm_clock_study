part of 'alarm_bloc.dart';

sealed class AlarmState extends Equatable {
  const AlarmState();

  @override
  List<Object> get props => [];
}

final class AlarmInitialState extends AlarmState {}

final class AlarmLoadingState extends AlarmState {
  const AlarmLoadingState({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

final class AlarmErrorState extends AlarmState {
  const AlarmErrorState(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}

final class AlarmDoneState extends AlarmState {
  const AlarmDoneState(this.listAlarm);

  final List<AlarmEntity> listAlarm;

  @override
  List<Object> get props => [listAlarm];
}
