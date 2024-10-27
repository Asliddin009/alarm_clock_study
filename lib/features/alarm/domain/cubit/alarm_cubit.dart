import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/domain/i_alarm_cache.dart';
import 'package:alearn/features/alarm/domain/i_alarm_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'alarm_state.dart';

class AlarmCubit extends Cubit<AlarmState> {
  AlarmCubit(this.alarmRepo, this.alarmCashRepo) : super(AlarmInitial());
  IAlarmRepo alarmRepo;
  IAlarmCashRepo alarmCashRepo;

  Future<void> getAllAlarm() async {
    emit(const AlarmLoadingState(message: 'Загрузка будильников'));
    final listAlarm = await alarmCashRepo.getAllAlarms();
    emit(AlarmDoneState(listAlarm));
  }

  Future<void> createAlarmEntity({
    required DateTime dateTime,
    required bool isRepeat,
    List<Weekday>? weekdays,
  }) async {
    final listAlarm = (state as AlarmDoneState).listAlarm;
    //TODO: добавить слова для перевода в будущем
    final newAlarm = AlarmEntity(
      id: listAlarm.last.id + 1,
      time: dateTime,
      isActive: true,
      isRepeat: isRepeat,
      weekdays: weekdays,
    );
    await _createAlarm(newAlarm);
    emit(AlarmDoneState([...listAlarm, newAlarm]));
  }

  Future<void> _createAlarm(
    AlarmEntity alarm, {
    String notificationTitle = 'Пора Вставать))',
    String notificationBody = '',
  }) async {
    final flag = await alarmRepo.addAlarm(
      time: alarm.time,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
      id: alarm.id,
    );
    if (flag == false) {
      emit(const AlarmErrorState('Ошибка при создании будильника'));
      return;
    }
  }

  Future<void> deleteAlarm(int id) async {
    final isDelete = await alarmCashRepo.deleteAlarm(id);
    if (isDelete == false) {
      emit(const AlarmErrorState('Ошибка при удалении будильника'));
      return;
    }
    final flag = await alarmRepo.deleteAlarm(id);
    if (flag == false) {
      emit(const AlarmErrorState('Ошибка при удалении будильника'));
      return;
    }
    await getAllAlarm();
  }
}
