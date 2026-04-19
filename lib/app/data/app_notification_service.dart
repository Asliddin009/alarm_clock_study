import 'dart:developer' as developer;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppNotificationService {
  const AppNotificationService();

  static const String studyChannelGroupKey = 'study_channel_group';
  static const String studyChannelKey = 'study_alerts';

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: studyChannelGroupKey,
          channelKey: studyChannelKey,
          channelName: 'Study alerts',
          channelDescription: 'Alarm and study reminder notifications',
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Public,
          defaultColor: const Color(0xFF1F6F5C),
          playSound: true,
          enableVibration: true,
          channelShowBadge: true,
          onlyAlertOnce: false,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: studyChannelGroupKey,
          channelGroupName: 'Study notifications',
        ),
      ],
      debug: kDebugMode,
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
    );
  }

  Future<bool> isNotificationAllowed() {
    return AwesomeNotifications().isNotificationAllowed();
  }

  Future<bool> requestPermission() async {
    final isAllowed = await isNotificationAllowed();
    if (isAllowed) {
      return true;
    }

    return AwesomeNotifications().requestPermissionToSendNotifications(
      channelKey: studyChannelKey,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    developer.log(
      'Awesome notification action received: '
      'channel=${receivedAction.channelKey}, '
      'button=${receivedAction.buttonKeyPressed}',
      name: 'AppNotificationService',
    );
  }
}
