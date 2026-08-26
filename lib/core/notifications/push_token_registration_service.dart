import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../network/auth_session.dart';
import '../utils/app_logger.dart';

class PushTokenRegistrationService {
  PushTokenRegistrationService._();

  static final PushTokenRegistrationService instance =
      PushTokenRegistrationService._();

  static const MethodChannel _channel = MethodChannel(
    'tpg_nexus/push_notifications',
  );

  bool _registeredThisSession = false;

  Future<void> registerCurrentDevice() async {
    if (_registeredThisSession || !AuthSession.hasAuth) return;

    final token = await _readPlatformPushToken();
    if (token == null || token.isEmpty) {
      AppLogger.info('push token not available on this platform/session');
      return;
    }

    final payload = {
      'platform': Platform.isIOS
          ? 'ios'
          : Platform.isAndroid
              ? 'android'
              : Platform.operatingSystem,
      'push_token': token,
    };

    try {
      final response = await http.post(
        ApiConstants.uri(ApiConstants.registerMobilePushTokenEndpoint),
        headers: AuthSession.authHeaders(),
        body: jsonEncode(payload),
      );
      AppLogger.info(
        'push token register response=${response.statusCode} body=${_preview(response.body)}',
      );
      _registeredThisSession = response.statusCode == 200;
    } catch (e) {
      AppLogger.error('push token registration failed: $e');
    }
  }

  Future<String?> _readPlatformPushToken() async {
    if (!Platform.isIOS) return null;
    try {
      return await _channel.invokeMethod<String>('getApnsToken');
    } catch (e) {
      AppLogger.error('failed to read APNs token: $e');
      return null;
    }
  }

  String _preview(String body, {int max = 400}) {
    if (body.length <= max) return body;
    return '${body.substring(0, max)}...';
  }
}
