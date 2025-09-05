import 'dart:async';
import 'dart:math';

import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_cache_repo.dart';
import 'package:alearn/features/alarm/domain/repo/i_alarm_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'alarm_event.dart';
part 'alarm_state.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final IAlarmRepo alarmRepo;
  final IAlarmCashRepo alarmCashRepo;

  AlarmBloc({
    required this.alarmRepo,
    required this.alarmCashRepo,
  }) : super(AlarmInitialState()) {
    // Подписываемся на события
    on<AlarmGetAllEvent>(_onGetAllAlarmsEvent);
    on<AlarmCreateEvent>(_onCreateAlarmEvent);
    on<AlarmDeleteEvent>(_onDeleteAlarmEvent);
    on<AlarmUpdateEvent>(_onUpdateAlarmEvent);
    on<AlarmInitialEvent>(_onInitialEvent);
  }

  Future<void> _onInitialEvent(
    AlarmInitialEvent event,
    Emitter<AlarmState> emit,
  ) async {
    alarmRepo.requestPermission();
  }

  Stream getRingStream() {
    return alarmRepo.getRingStream();
  }

  Future<void> _onGetAllAlarmsEvent(
    AlarmGetAllEvent event,
    Emitter<AlarmState> emit,
  ) async {
    emit(const AlarmLoadingState(message: 'Загрузка будильников'));
    try {
      final listAlarm = await alarmCashRepo.getAllAlarms(); // Получаем будильники из кеша
      emit(AlarmDoneState(listAlarm)); // Эмитим успешное завершение
    } catch (e) {
      emit(const AlarmErrorState('Ошибка при загрузке будильников'));
    }
  }

  Future<void> _onCreateAlarmEvent(
    AlarmCreateEvent event,
    Emitter<AlarmState> emit,
  ) async {
    if (state is! AlarmDoneState) return;

    final currentState = state as AlarmDoneState;
    final listAlarm = currentState.listAlarm;

    try {
      final newAlarm = AlarmEntity(
        id: listAlarm.isNotEmpty ? listAlarm.last.id + 1 : 1,
        //в будущем лучше переписать под нормальные id
        alarmId: Random.secure().nextInt(1000000),
        time: event.dateTime,
        isActive: true,
        isRepeat: event.isRepeat,
        weekdays: event.weekdays,
        listCategoryId: event.listCategoryId,
      );
      final flagSaveInCash = await alarmCashRepo.saveAlarmEntity(newAlarm);

      //создаем будильник
      //TODO replace mock
      final date = {
        'alarmId': newAlarm.alarmId,
        'trueWord': 'alarm',
        'falseWord': 'clock, timer, stopwatch',
      };
      final flagCreateAlarm = await alarmRepo.createAlarm(
        time: newAlarm.time,
        id: newAlarm.id,
        notificationTitle: 'Доброе утро))',
        notificationBody: 'пора вставать и начинать новый день\n\n$date',
      );
      if (!flagSaveInCash || !flagCreateAlarm) {
        emit(const AlarmErrorState('Ошибка при создании будильника'));
        return;
      }

      emit(AlarmDoneState([...listAlarm, newAlarm]));
    } catch (e) {
      emit(const AlarmErrorState('Ошибка при создании будильника'));
    }
  }

  // Обработка события DeleteAlarmEvent
  Future<void> _onDeleteAlarmEvent(
    AlarmDeleteEvent event,
    Emitter<AlarmState> emit,
  ) async {
    if (state is! AlarmDoneState) return;

    try {
      //Удаление будильника из кэша
      final isDeleteCache = await alarmCashRepo.deleteAlarm(event.id);

      if (isDeleteCache == false) {
        emit(const AlarmErrorState('Ошибка при удалении будильника (кеш)'));
        return;
      }
      //Удаление будильника из сервиса
      final isDeleteRepo = await alarmRepo.deleteAlarm(event.id);

      if (isDeleteRepo == false) {
        emit(const AlarmErrorState('Ошибка при удалении будильника (сервисы)'));
        return;
      }

      final updatedAlarms = await alarmCashRepo.getAllAlarms();
      emit(AlarmDoneState(updatedAlarms));
    } catch (e) {
      emit(const AlarmErrorState('Ошибка при удалении будильника'));
    }
  }

  Future<void> _onUpdateAlarmEvent(
    AlarmUpdateEvent event,
    Emitter<AlarmState> emit,
  ) async {
    if (state is! AlarmDoneState) return;

    try {
      final flag = await alarmCashRepo.updateAlarmEntity(event.alarmEntity);
      if (flag == false) {
        emit(const AlarmErrorState('Ошибка при обновлении будильника (кеш)'));
        return;
      }
      final updatedAlarmsList = await alarmCashRepo.getAllAlarms();
      emit(AlarmDoneState(updatedAlarmsList));
    } catch (e) {
      emit(const AlarmErrorState('Ошибка при обновлении будильника'));
    }
  }
}
