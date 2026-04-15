import 'package:alearn/features/alarm/domain/alarm_exception.dart';
import 'package:permission_handler/permission_handler.dart';

class AlarmPermissionService {
  const AlarmPermissionService();

  Future<void> requestPermissions() async {
    await _requestIfNeeded(
      Permission.notification,
      failureMessage: 'Нужно разрешение на уведомления для будильников.',
    );
    await _requestIfNeeded(
      Permission.scheduleExactAlarm,
      failureMessage: 'Нужно разрешение на точные будильники.',
    );
  }

  Future<void> _requestIfNeeded(
    Permission permission, {
    required String failureMessage,
  }) async {
    final status = await permission.status;
    if (status.isGranted || status.isLimited || status.isProvisional) {
      return;
    }
    final requestedStatus = await permission.request();
    if (!requestedStatus.isGranted &&
        !requestedStatus.isLimited &&
        !requestedStatus.isProvisional) {
      throw AlarmPermissionException(failureMessage);
    }
  }
}
