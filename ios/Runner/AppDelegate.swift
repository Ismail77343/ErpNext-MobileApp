import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var apnsToken: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    configurePushNotificationChannel()
    configureAttendanceSecurityChannel()
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .badge, .sound]
    ) { granted, _ in
      guard granted else { return }
      DispatchQueue.main.async {
        application.registerForRemoteNotifications()
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    apnsToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    apnsToken = nil
  }

  private func configurePushNotificationChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "tpg_nexus/push_notifications",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      if call.method == "getApnsToken" {
        result(self?.apnsToken)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func configureAttendanceSecurityChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "tpg_nexus/attendance_security",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "getAttendanceSecurityRisk" {
        result([
          "root_or_jailbreak_detected": self.isJailbrokenDevice(),
          "developer_mode_detected": false,
          "mock_location_enabled": false
        ])
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func isJailbrokenDevice() -> Bool {
    #if targetEnvironment(simulator)
    return false
    #else
    let suspiciousPaths = [
      "/Applications/Cydia.app",
      "/Library/MobileSubstrate/MobileSubstrate.dylib",
      "/bin/bash",
      "/usr/sbin/sshd",
      "/etc/apt",
      "/private/var/lib/apt"
    ]

    if suspiciousPaths.contains(where: { FileManager.default.fileExists(atPath: $0) }) {
      return true
    }

    let testPath = "/private/tpg_nexus_jailbreak_test.txt"
    do {
      try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
      try FileManager.default.removeItem(atPath: testPath)
      return true
    } catch {
      return false
    }
    #endif
  }
}
