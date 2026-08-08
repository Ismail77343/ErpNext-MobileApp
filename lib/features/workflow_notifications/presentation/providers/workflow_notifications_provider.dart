import 'package:flutter/material.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/workflow_notification.dart';
import '../../domain/entities/workflow_notifications_summary.dart';
import '../../domain/usecases/get_workflow_notifications_summary_usecase.dart';
import '../../domain/usecases/get_workflow_notifications_usecase.dart';

class WorkflowNotificationsProvider extends ChangeNotifier {
  WorkflowNotificationsProvider(
    this._getWorkflowNotificationsUseCase,
    this._getWorkflowNotificationsSummaryUseCase,
  );

  final GetWorkflowNotificationsUseCase _getWorkflowNotificationsUseCase;
  final GetWorkflowNotificationsSummaryUseCase
      _getWorkflowNotificationsSummaryUseCase;

  static const int _pageSize = 20;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingSummary = false;
  bool _hasMore = true;
  int _nextStart = 0;
  String? _error;
  List<WorkflowNotification> _notifications = [];
  WorkflowNotificationsSummary _summary =
      const WorkflowNotificationsSummary.empty();

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingSummary => _isLoadingSummary;
  bool get hasMore => _hasMore;
  String? get error => _error;
  List<WorkflowNotification> get notifications => _notifications;
  WorkflowNotificationsSummary get summary => _summary;
  int get unreadCount => _summary.unreadCount;

  Future<void> initialize() async {
    await Future.wait([fetchNotifications(), fetchSummary()]);
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    _hasMore = true;
    _nextStart = 0;
    _notifications = [];
    notifyListeners();

    try {
      final batch = await _getWorkflowNotificationsUseCase.call(
        start: 0,
        limit: _pageSize,
      );
      _notifications = batch;
      _nextStart = batch.length;
      _hasMore = batch.length == _pageSize;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('workflow notifications fetch failed: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSummary() async {
    _isLoadingSummary = true;
    notifyListeners();

    try {
      _summary = await _getWorkflowNotificationsSummaryUseCase.call();
    } catch (e) {
      AppLogger.error('workflow notifications summary failed: $e');
      _summary = WorkflowNotificationsSummary(
        totalCount: _notifications.length,
        unreadCount: _notifications.length,
        opportunityCount:
            _notifications.where((item) => item.doctype == 'Opportunity').length,
        quotationCount:
            _notifications.where((item) => item.doctype == 'Quotation').length,
        leadCount: _notifications.where((item) => item.doctype == 'Lead').length,
        otherCount: _notifications
            .where((item) => !{'Opportunity', 'Quotation', 'Lead'}.contains(item.doctype))
            .length,
      );
    } finally {
      _isLoadingSummary = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();
    try {
      final batch = await _getWorkflowNotificationsUseCase.call(
        start: _nextStart,
        limit: _pageSize,
      );
      final existingIds = _notifications.map((item) => item.id).toSet();
      _notifications = [
        ..._notifications,
        ...batch.where((item) => !existingIds.contains(item.id)),
      ];
      _nextStart += batch.length;
      _hasMore = batch.length == _pageSize;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('workflow notifications load more failed: $_error');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await initialize();
  }
}
