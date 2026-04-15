import 'package:alarm/alarm.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/service/alarm_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'alarm_event.dart';
part 'alarm_state.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  AlarmBloc({
    required AlarmService alarmService,
  })  : _alarmService = alarmService,
        super(const AlarmInitialState()) {
    on<AlarmStarted>(_onStarted);
    on<AlarmRefreshRequested>(_onRefreshRequested);
    on<AlarmCreateRequested>(_onCreateRequested);
    on<AlarmDeleteRequested>(_onDeleteRequested);
    on<AlarmUpdateRequested>(_onUpdateRequested);
  }

  final AlarmService _alarmService;

  Stream<AlarmSettings> get ringStream => _alarmService.ringStream;

  Future<void> _onStarted(
    AlarmStarted event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmLoadingState(message: 'Подготавливаем будильники'));
    try {
      await _alarmService.initialize();
      final alarms = await _alarmService.loadAlarms();
      emit(AlarmLoadedState(alarms));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        AlarmErrorState(message: 'Не удалось запустить будильники. $error'),
      );
    }
  }

  Future<void> _onRefreshRequested(
    AlarmRefreshRequested event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmLoadingState(message: 'Загружаем будильники', alarms: state.alarms));
    try {
      final alarms = await _alarmService.loadAlarms();
      emit(AlarmLoadedState(alarms));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        AlarmErrorState(
          message: 'Не удалось загрузить будильники. $error',
          alarms: state.alarms,
        ),
      );
    }
  }

  Future<void> _onCreateRequested(
    AlarmCreateRequested event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmLoadingState(message: 'Создаём будильник', alarms: state.alarms));
    try {
      final alarms = await _alarmService.createAlarm(
        dateTime: event.dateTime,
        isRepeat: event.isRepeat,
        weekdays: event.weekdays,
        categoryIds: event.categoryIds,
      );
      emit(AlarmLoadedState(alarms));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        AlarmErrorState(
          message: 'Не удалось создать будильник. $error',
          alarms: state.alarms,
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    AlarmDeleteRequested event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmLoadingState(message: 'Удаляем будильник', alarms: state.alarms));
    try {
      final alarms = await _alarmService.deleteAlarm(event.id);
      emit(AlarmLoadedState(alarms));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        AlarmErrorState(
          message: 'Не удалось удалить будильник. $error',
          alarms: state.alarms,
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    AlarmUpdateRequested event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmLoadingState(message: 'Обновляем будильник', alarms: state.alarms));
    try {
      final alarms = await _alarmService.updateAlarm(event.alarm);
      emit(AlarmLoadedState(alarms));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        AlarmErrorState(
          message: 'Не удалось обновить будильник. $error',
          alarms: state.alarms,
        ),
      );
    }
  }
}
