import 'package:alearn/app/data/app_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class AlarmPermissionService {
  const AlarmPermissionService({
    AppNotificationService notificationService = const AppNotificationService(),
  }) : _notificationService = notificationService;

  final AppNotificationService _notificationService;

  Future<void> requestPermissions() async {
    await _notificationService.requestPermission();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _requestIfNeeded(Permission.scheduleExactAlarm);
    }
  }

  Future<void> _requestIfNeeded(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted || status.isLimited || status.isProvisional) {
      return;
    }
    await permission.request();
  }
}
