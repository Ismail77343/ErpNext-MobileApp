import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app_notification_payload.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  void Function(AppNotificationPayload payload)? onNotificationTap;

  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }

    if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _initialized = true;
  }

  Future<void> show(AppNotificationPayload payload) async {
    await initialize();
    const android = AndroidNotificationDetails(
      'tpg_nexus_workflow_tasks',
      'Workflow and Task Notifications',
      channelDescription:
          'Workflow approvals and mobile task follow up notifications.',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'TPGNexus',
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      payload.id.hashCode,
      payload.title,
      payload.body,
      const NotificationDetails(android: android, iOS: ios),
      payload: payload.encode(),
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null || raw.isEmpty) return;
    try {
      onNotificationTap?.call(AppNotificationPayload.fromEncoded(raw));
    } catch (_) {
      return;
    }
  }
}
