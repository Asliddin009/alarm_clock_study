// import 'package:alarm/alarm.dart';
// import 'package:alearn/features/alarm/data/permission.dart';
// import 'package:alearn/features/alarm/domain/alarm_exception.dart';
// import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
// import 'package:alearn/features/alarm/domain/repo/i_alarm_repo.dart';
// import 'package:flutter_alarmkit/flutter_alarmkit.dart' as alarmkit;

// final class AlarmKitRepo implements IAlarmRepo {
//   AlarmKitRepo({
//     required AlarmPermissionService permissionService,
//     alarmkit.FlutterAlarmkit? plugin,
//   }) : _permissionService = permissionService,
//        _plugin = plugin ?? alarmkit.FlutterAlarmkit();

//   final AlarmPermissionService _permissionService;
//   final alarmkit.FlutterAlarmkit _plugin;

//   @override
//   Stream<AlarmSettings> get ringStream => const Stream<AlarmSettings>.empty();

//   @override
//   Future<void> requestPermissions() {
//     return _permissionService.requestPermissions();
//   }

//   @override
//   Future<AlarmEntity> scheduleAlarm({
//     required AlarmEntity alarm,
//     required String notificationTitle,
//     required String notificationBody,
//   }) async {
//     try {
//       final nativeAlarmId = await _scheduleNativeAlarm(
//         alarm: alarm,
//         notificationTitle: notificationTitle,
//       );
//       return alarm.copyWith(nativeAlarmId: nativeAlarmId);
//     } on Object catch (error) {
//       throw AlarmRepositoryException(
//         'Не удалось запланировать системный будильник iOS.',
//         cause: error,
//       );
//     }
//   }

//   @override
//   Future<AlarmEntity> updateAlarm({
//     required AlarmEntity alarm,
//     required String notificationTitle,
//     required String notificationBody,
//   }) async {
//     try {
//       if (alarm.nativeAlarmId case final nativeAlarmId?
//           when nativeAlarmId.isNotEmpty) {
//         final didCancel = await _plugin.cancelAlarm(alarmId: nativeAlarmId);
//         if (!didCancel) {
//           throw const AlarmRepositoryException(
//             'Не удалось отменить предыдущий iOS будильник перед обновлением.',
//           );
//         }
//       }

//       final nextNativeAlarmId = await _scheduleNativeAlarm(
//         alarm: alarm,
//         notificationTitle: notificationTitle,
//       );
//       return alarm.copyWith(nativeAlarmId: nextNativeAlarmId);
//     } on Object catch (error) {
//       throw AlarmRepositoryException(
//         'Не удалось обновить системный будильник iOS.',
//         cause: error,
//       );
//     }
//   }

//   @override
//   Future<void> deleteAlarm({required int id, String? nativeAlarmId}) async {
//     final resolvedNativeAlarmId = _requireNativeAlarmId(nativeAlarmId);
//     final didCancel = await _plugin.cancelAlarm(alarmId: resolvedNativeAlarmId);
//     if (!didCancel) {
//       throw const AlarmRepositoryException(
//         'Не удалось удалить системный будильник iOS.',
//       );
//     }
//   }

//   @override
//   Future<void> stopAlarm({required int id, String? nativeAlarmId}) async {
//     final resolvedNativeAlarmId = _requireNativeAlarmId(nativeAlarmId);
//     final didStop = await _plugin.stopAlarm(alarmId: resolvedNativeAlarmId);
//     if (!didStop) {
//       throw const AlarmRepositoryException(
//         'Не удалось остановить активный будильник iOS.',
//       );
//     }
//   }

//   Future<String> _scheduleNativeAlarm({
//     required AlarmEntity alarm,
//     required String notificationTitle,
//   }) {
//     if (alarm.isRepeat || alarm.weekdays.isNotEmpty) {
//       return _plugin.scheduleRecurrentAlarm(
//         weekdays: alarm.weekdays.map(_mapWeekday).toSet(),
//         hour: alarm.time.hour,
//         minute: alarm.time.minute,
//         label: notificationTitle,
//         tintColor: '#1F6F5C',
//         soundPath: _resolveAlarmKitSoundPath(alarm.assetAudioPath),
//       );
//     }

//     return _plugin.scheduleOneShotAlarm(
//       timestamp: alarm.time.millisecondsSinceEpoch.toDouble(),
//       label: notificationTitle,
//       tintColor: '#1F6F5C',
//       soundPath: _resolveAlarmKitSoundPath(alarm.assetAudioPath),
//     );
//   }

//   String _requireNativeAlarmId(String? nativeAlarmId) {
//     if (nativeAlarmId != null && nativeAlarmId.isNotEmpty) {
//       return nativeAlarmId;
//     }
//     throw const AlarmRepositoryException(
//       'Не найден системный идентификатор iOS будильника.',
//     );
//   }

//   alarmkit.Weekday _mapWeekday(Weekday weekday) {
//     return switch (weekday) {
//       Weekday.monday => alarmkit.Weekday.monday,
//       Weekday.tuesday => alarmkit.Weekday.tuesday,
//       Weekday.wednesday => alarmkit.Weekday.wednesday,
//       Weekday.thursday => alarmkit.Weekday.thursday,
//       Weekday.friday => alarmkit.Weekday.friday,
//       Weekday.saturday => alarmkit.Weekday.saturday,
//       Weekday.sunday => alarmkit.Weekday.sunday,
//     };
//   }

//   String? _resolveAlarmKitSoundPath(String assetAudioPath) {
//     final lowerCasePath = assetAudioPath.toLowerCase();
//     final isSupportedExtension =
//         lowerCasePath.endsWith('.caf') ||
//         lowerCasePath.endsWith('.wav') ||
//         lowerCasePath.endsWith('.aiff');
//     return isSupportedExtension ? assetAudioPath : null;
//   }
// }
