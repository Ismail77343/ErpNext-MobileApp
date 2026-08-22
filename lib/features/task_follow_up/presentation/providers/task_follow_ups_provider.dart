import 'package:flutter/material.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/task_follow_up.dart';
import '../../domain/usecases/get_assigned_task_follow_ups_usecase.dart';
import '../../domain/usecases/get_my_task_follow_ups_usecase.dart';

enum TaskFollowUpTab { assignedToMe, assignedByMe }

class TaskFollowUpsProvider extends ChangeNotifier {
  TaskFollowUpsProvider(
    this._getMyTaskFollowUpsUseCase,
    this._getAssignedTaskFollowUpsUseCase,
  );

  final GetMyTaskFollowUpsUseCase _getMyTaskFollowUpsUseCase;
  final GetAssignedTaskFollowUpsUseCase _getAssignedTaskFollowUpsUseCase;

  static const int _pageSize = 20;

  TaskFollowUpTab _tab = TaskFollowUpTab.assignedToMe;
  String _statusFilter = 'All';
  String _searchQuery = '';
  bool _onlyOpen = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _nextStart = 0;
  String? _error;
  List<TaskFollowUp> _items = [];

  TaskFollowUpTab get tab => _tab;
  String get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;
  bool get onlyOpen => _onlyOpen;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  bool get canLoadMore => !_isLoading && !_isLoadingMore && _hasMore;

  List<TaskFollowUp> get items {
    if (_searchQuery.isEmpty) return _items;
    final q = _searchQuery.toLowerCase();
    return _items.where((item) {
      return item.name.toLowerCase().contains(q) ||
          item.subject.toLowerCase().contains(q) ||
          item.project.toLowerCase().contains(q) ||
          item.task.toLowerCase().contains(q) ||
          item.status.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> initialize() => fetch(refresh: true);

  Future<void> fetch({bool refresh = false}) async {
    if (_isLoading || _isLoadingMore) return;
    if (!refresh && !_hasMore) return;

    if (refresh) {
      _isLoading = true;
      _items = [];
      _nextStart = 0;
      _hasMore = true;
    } else {
      _isLoadingMore = true;
    }
    _error = null;
    notifyListeners();

    try {
      final status = _statusFilter == 'All' ? null : _statusFilter;
      final batch = _tab == TaskFollowUpTab.assignedToMe
          ? await _getMyTaskFollowUpsUseCase.call(
              status: status,
              onlyOpen: _onlyOpen,
              start: _nextStart,
              limit: _pageSize,
            )
          : await _getAssignedTaskFollowUpsUseCase.call(
              status: status,
              onlyOpen: _onlyOpen,
              start: _nextStart,
              limit: _pageSize,
            );
      final existing = _items.map((item) => item.name).toSet();
      _items = [
        ..._items,
        ...batch.where((item) => !existing.contains(item.name)),
      ];
      _nextStart += batch.length;
      _hasMore = batch.length == _pageSize;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('task follow ups fetch failed: $_error');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetch(refresh: true);

  void setTab(TaskFollowUpTab value) {
    if (_tab == value) return;
    _tab = value;
    _onlyOpen = value == TaskFollowUpTab.assignedToMe;
    refresh();
  }

  void setStatusFilter(String value) {
    if (_statusFilter == value) return;
    _statusFilter = value;
    refresh();
  }

  void setOnlyOpen(bool value) {
    if (_onlyOpen == value) return;
    _onlyOpen = value;
    refresh();
  }

  void setSearchQuery(String value) {
    _searchQuery = value.trim();
    notifyListeners();
  }
}
