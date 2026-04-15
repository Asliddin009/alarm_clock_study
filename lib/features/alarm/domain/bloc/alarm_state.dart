part of 'alarm_bloc.dart';

sealed class AlarmState extends Equatable {
  const AlarmState({
    this.alarms = const <AlarmEntity>[],
  });

  final List<AlarmEntity> alarms;

  @override
  List<Object?> get props => <Object?>[alarms];
}

final class AlarmInitialState extends AlarmState {
  const AlarmInitialState();
}

final class AlarmLoadingState extends AlarmState {
  const AlarmLoadingState({
    required this.message,
    super.alarms,
  });

  final String message;

  @override
  List<Object?> get props => <Object?>[message, alarms];
}

final class AlarmLoadedState extends AlarmState {
  const AlarmLoadedState(List<AlarmEntity> alarms) : super(alarms: alarms);
}

final class AlarmErrorState extends AlarmState {
  const AlarmErrorState({
    required this.message,
    super.alarms,
  });

  final String message;

  @override
  List<Object?> get props => <Object?>[message, alarms];
}
