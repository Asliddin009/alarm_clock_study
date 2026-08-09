import Flutter
import UIKit
import UserNotifications
import alarm
import awesome_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate

    // Keeps the `alarm` package's background refresh alive. Only iOS 25 and
    // older rely on it — from iOS 26 the app uses AlarmKit, which needs no
    // background work of ours at all.
    SwiftAlarmPlugin.registerBackgroundTasks()

    SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
      SwiftAwesomeNotificationsPlugin.register(
        with: registry.registrar(
          forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin"
        )!
      )
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Plugins are registered here rather than in didFinishLaunchingWithOptions:
  // the scene-based lifecycle AlarmKit requires creates the Flutter engine
  // implicitly, and registering in both places would register every plugin
  // twice on the same engine.
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
