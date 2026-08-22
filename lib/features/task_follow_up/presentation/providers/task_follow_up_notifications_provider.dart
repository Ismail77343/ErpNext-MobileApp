import 'package:flutter/material.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/task_follow_up_notification.dart';
import '../../domain/usecases/get_task_follow_up_notifications_usecase.dart';

class TaskFollowUpNotificationsProvider extends ChangeNotifier {
  TaskFollowUpNotificationsProvider(this._getNotificationsUseCase);

  final GetTaskFollowUpNotificationsUseCase _getNotificationsUseCase;

  bool _isLoading = false;
  String? _error;
  List<TaskFollowUpNotification> _notifications = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TaskFollowUpNotification> get notifications => _notifications;
  int get unreadCount => _notifications.length;

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _notifications = await _getNotificationsUseCase.call();
    } catch (e) {
      _error = e.toString();
      AppLogger.error('task follow up notifications failed: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
