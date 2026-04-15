part of 'alarm_bloc.dart';

sealed class AlarmEvent extends Equatable {
  const AlarmEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class AlarmStarted extends AlarmEvent {
  const AlarmStarted();
}

final class AlarmRefreshRequested extends AlarmEvent {
  const AlarmRefreshRequested();
}

final class AlarmCreateRequested extends AlarmEvent {
  const AlarmCreateRequested({
    required this.dateTime,
    required this.isRepeat,
    required this.weekdays,
    required this.categoryIds,
  });

  final DateTime dateTime;
  final bool isRepeat;
  final List<Weekday> weekdays;
  final List<int> categoryIds;

  @override
  List<Object?> get props => <Object?>[dateTime, isRepeat, weekdays, categoryIds];
}

final class AlarmDeleteRequested extends AlarmEvent {
  const AlarmDeleteRequested(this.id);

  final int id;

  @override
  List<Object?> get props => <Object?>[id];
}

final class AlarmUpdateRequested extends AlarmEvent {
  const AlarmUpdateRequested(this.alarm);

  final AlarmEntity alarm;

  @override
  List<Object?> get props => <Object?>[alarm];
}
