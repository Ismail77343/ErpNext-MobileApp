import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import '../constants/api_constants.dart';
import '../network/auth_session.dart';
import '../utils/app_logger.dart';
import 'app_notification_payload.dart';
import 'local_notification_service.dart';

class RealtimeNotificationService {
  RealtimeNotificationService._();

  static final RealtimeNotificationService instance =
      RealtimeNotificationService._();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  bool _started = false;
  final Set<String> _seenNotificationIds = <String>{};

  void Function()? onNotificationReceived;

  Future<void> start() async {
    if (_started || !AuthSession.hasAuth) return;
    _started = true;
    await LocalNotificationService.instance.initialize();
    _connect();
  }

  Future<void> stop() async {
    _started = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  void _connect() {
    if (!_started || !AuthSession.hasAuth) return;

    try {
      _channel = IOWebSocketChannel.connect(
        ApiConstants.notificationsWebSocketUri,
        headers: AuthSession.authHeaders(withJson: false),
      );
      _subscription = _channel!.stream.listen(
        _handleSocketMessage,
        onError: (error) {
          AppLogger.error('notification websocket error: $error');
          _scheduleReconnect();
        },
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
    } catch (e) {
      AppLogger.error('notification websocket connect failed: $e');
      _scheduleReconnect();
    }
  }

  Future<void> _handleSocketMessage(dynamic event) async {
    final payload = _parsePayload(event);
    if (payload == null) return;
    if (!_seenNotificationIds.add(payload.id)) return;

    await LocalNotificationService.instance.show(payload);
    onNotificationReceived?.call();
  }

  AppNotificationPayload? _parsePayload(dynamic event) {
    try {
      final decoded = event is String ? jsonDecode(event) : event;
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          return AppNotificationPayload.fromJson(data);
        }
        final message = decoded['message'];
        if (message is Map<String, dynamic>) {
          return AppNotificationPayload.fromJson(message);
        }
        return AppNotificationPayload.fromJson(decoded);
      }
    } catch (e) {
      AppLogger.error('invalid notification websocket payload: $e');
    }
    return null;
  }

  void _scheduleReconnect() {
    if (!_started) return;
    _subscription?.cancel();
    _subscription = null;
    _channel = null;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 20), _connect);
  }
}
