part of 'alarm_cubit.dart';

sealed class AlarmState extends Equatable {
  const AlarmState();

  @override
  List<Object> get props => [];
}

final class AlarmInitial extends AlarmState {}

final class AlarmLoadingState extends AlarmState {
  const AlarmLoadingState({required this.message});
  final String message;
}

final class AlarmErrorState extends AlarmState {
  const AlarmErrorState(this.error);
  final String error;
}

final class AlarmDoneState extends AlarmState {
  const AlarmDoneState(this.listAlarm);
  final List<AlarmEntity> listAlarm;
}
