import 'package:alarm/alarm.dart';

class AlarmDto extends AlarmSettings {
  const AlarmDto({
    required super.id,
    required super.dateTime,
    required super.assetAudioPath,
    required super.notificationTitle,
    required super.notificationBody,
  });
}
