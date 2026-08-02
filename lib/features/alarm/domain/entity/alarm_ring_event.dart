import 'package:equatable/equatable.dart';

/// Событие «будильник зазвонил» в терминах домена.
///
/// Платформы адресуют будильники по-разному: пакет `alarm` знает доменный
/// [alarmId], AlarmKit — только свой UUID [nativeAlarmId]. Репозиторий отдаёт
/// тот идентификатор, которым располагает, а сопоставление одного с другим
/// берёт на себя `AlarmService`, потому что только у него есть доступ к кэшу.
class AlarmRingEvent extends Equatable {
  const AlarmRingEvent({this.alarmId, this.nativeAlarmId})
    : assert(
        alarmId != null || nativeAlarmId != null,
        'Событие звонка должно нести хотя бы один идентификатор.',
      );

  final int? alarmId;
  final String? nativeAlarmId;

  @override
  List<Object?> get props => <Object?>[alarmId, nativeAlarmId];
}
