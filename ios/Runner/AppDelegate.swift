import FirebaseMessaging
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Route iOS notification callbacks to the Flutter plugins (FCM +
    // flutter_local_notifications). Permission is requested from Dart so
    // the user only sees the system prompt at a moment that makes sense in
    // the product flow.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "boardmate/ios_push",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        if call.method == "registerForRemoteNotifications" {
          UIApplication.shared.registerForRemoteNotifications()
          result(nil)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    // Kick off APNs registration early. The system prompt still only appears
    // when Dart calls `requestPermission()`.
    application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // FirebaseMessagingAutoInitEnabled is false in Info.plist, so we must
  // forward the APNs device token to FCM manually (swizzling is disabled).
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    NSLog("APNs registration failed: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
