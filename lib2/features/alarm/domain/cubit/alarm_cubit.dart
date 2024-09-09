import '../entity/alarm_entity.dart';
import '../i_alarm_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'alarm_state.dart';

class AlarmCubit extends Cubit<AlarmState> {
  AlarmCubit(this.alarmRepo) : super(AlarmInitial());
  IAlarmRepo alarmRepo;

  Future<void> getAllAlarm() async {
    emit(const AlarmLoadingState(message: 'Загрузка будильников'));
    final listAlarm = await alarmRepo.getAllAlarms();
    emit(AlarmDoneState(listAlarm));
  }

  Future<void> createAlarm(DateTime dateTime) async {
    final listAlarm = (state as AlarmDoneState).listAlarm;
    emit(const AlarmLoadingState(message: 'Загрузка будильников'));
    final newAlarm = await alarmRepo.addAlarm(time: dateTime);
    emit(AlarmDoneState([...listAlarm, newAlarm]));
  }

  Future<void> deleteAlarm(int id) async {
    alarmRepo.deleteAlarm(id);
    await getAllAlarm();
  }
}
