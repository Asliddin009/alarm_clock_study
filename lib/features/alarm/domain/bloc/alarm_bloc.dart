import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/i_alarm_cache.dart';
import 'package:alearn/features/alarm/domain/i_alarm_repo.dart';
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
  }) : super(AlarmInitial()) {
    // Подписываемся на события
    on<GetAllAlarmsEvent>(_onGetAllAlarmsEvent);
    on<CreateAlarmEvent>(_onCreateAlarmEvent);
    on<DeleteAlarmEvent>(_onDeleteAlarmEvent);
  }

  // Обработка события GetAllAlarmsEvent
  Future<void> _onGetAllAlarmsEvent(
    GetAllAlarmsEvent event,
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

  // Обработка события CreateAlarmEvent
  Future<void> _onCreateAlarmEvent(
    CreateAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    if (state is! AlarmDoneState) return;

    final currentState = state as AlarmDoneState;
    final listAlarm = currentState.listAlarm;

    try {
      final newAlarm = AlarmEntity(
        id: listAlarm.isNotEmpty ? listAlarm.last.id + 1 : 1,
        time: event.dateTime,
        isActive: true,
        isRepeat: event.isRepeat,
        weekdays: event.weekdays,
      );

      final flag = await alarmRepo.addAlarm(
        time: newAlarm.time,
        id: newAlarm.id,
        notificationTitle: '',
        notificationBody: '',
      );

      if (!flag) {
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
    DeleteAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    if (state is! AlarmDoneState) return;

    try {
      final isDeleteCache = await alarmCashRepo.deleteAlarm(event.id);

      if (!isDeleteCache) {
        emit(const AlarmErrorState('Ошибка при удалении будильника (кеш)'));
        return;
      }

      final isDeleteRepo = await alarmRepo.deleteAlarm(event.id);

      if (!isDeleteRepo) {
        emit(const AlarmErrorState('Ошибка при удалении будильника (сервисы)'));
        return;
      }

      final updatedAlarms = await alarmCashRepo.getAllAlarms();
      emit(AlarmDoneState(updatedAlarms));
    } catch (e) {
      emit(const AlarmErrorState('Ошибка при удалении будильника'));
    }
  }
}
