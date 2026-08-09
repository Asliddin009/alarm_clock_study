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
    if (_isAndroid) {
      await _requestIfNeeded(Permission.scheduleExactAlarm);
    }
  }

  Future<bool> hasPermissions() async {
    try {
      final trackedStatuses = <PermissionStatus>[
        await Permission.notification.status,
        if (_isAndroid) await Permission.scheduleExactAlarm.status,
      ];
      return trackedStatuses.every(_isUsable);
    } on Object {
      return false;
    }
  }

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool _isUsable(PermissionStatus status) {
    return status.isGranted || status.isLimited || status.isProvisional;
  }

  Future<void> _requestIfNeeded(Permission permission) async {
    final status = await permission.status;
    if (_isUsable(status)) {
      return;
    }
    await permission.request();
  }
}
