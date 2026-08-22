import 'package:flutter/material.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/get_projects_usecase.dart';

class ProjectsProvider extends ChangeNotifier {
  final GetProjectsUseCase getProjectsUseCase;
  static const int _serverPageSize = 50;

  ProjectsProvider(this.getProjectsUseCase);

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreFromServer = true;
  int _nextStart = 0;
  List<Project> _projects = [];
  String? _error;
  String _searchQuery = '';
  String _statusFilter = 'All';

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  bool get hasMore => _hasMoreFromServer;
  bool get hasActiveSearch => _searchQuery.isNotEmpty;
  bool get hasActiveStatusFilter => _statusFilter != 'All';
  bool get hasAnyFilter => hasActiveSearch || hasActiveStatusFilter;
  bool get canLoadMore => !hasAnyFilter && _hasMoreFromServer;
  int get rawProjectsCount => _projects.length;

  List<Project> get projects {
    final filteredByStatus = _statusFilter == 'All'
        ? _projects
        : _projects.where(
            (project) =>
                project.status.trim().toLowerCase() ==
                _statusFilter.trim().toLowerCase(),
          );
    if (_searchQuery.isEmpty) return filteredByStatus.toList();
    final q = _searchQuery.toLowerCase();
    return filteredByStatus.where((project) {
      return project.name.toLowerCase().contains(q) ||
          project.projectName.toLowerCase().contains(q) ||
          project.customer.toLowerCase().contains(q) ||
          project.status.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> fetchProjects({int limit = _serverPageSize}) async {
    AppLogger.project('project loading=============');
    _isLoading = true;
    _error = null;
    _nextStart = 0;
    _hasMoreFromServer = true;
    _projects = [];
    notifyListeners();

    try {
      final batch = await getProjectsUseCase.call(
        start: _nextStart,
        limit: limit,
      );

      _projects = batch;
      _nextStart += batch.length;
      _hasMoreFromServer = batch.length == limit;

      AppLogger.project(
        'projects fetched batch=${batch.length} total=${_projects.length} first=${_projects.isEmpty ? 'none' : _projects.first.name} nextStart=$_nextStart hasMore=$_hasMoreFromServer',
      );
    } catch (e) {
      _projects = [];
      _error = e.toString();
      AppLogger.error('projects fetch failed: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreProjects() async {
    if (_isLoading || _isLoadingMore || !_hasMoreFromServer) return;
    if (hasAnyFilter) return;

    _isLoadingMore = true;
    _error = null;
    notifyListeners();
    AppLogger.project('project load more start start=$_nextStart');

    try {
      final batch = await getProjectsUseCase.call(
        start: _nextStart,
        limit: _serverPageSize,
      );

      final existingNames = _projects.map((p) => p.name).toSet();
      final newItems = batch.where((p) => !existingNames.contains(p.name));
      _projects = [..._projects, ...newItems];

      _nextStart += batch.length;
      _hasMoreFromServer = batch.length == _serverPageSize;

      AppLogger.project(
        'project load more done batch=${batch.length} added=${newItems.length} total=${_projects.length} first=${_projects.isEmpty ? 'none' : _projects.first.name} nextStart=$_nextStart hasMore=$_hasMoreFromServer',
      );
    } catch (e) {
      _error = e.toString();
      AppLogger.error('projects load more failed: $_error');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    AppLogger.project('project search query: "$_searchQuery"');
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    AppLogger.project('project status filter: "$_statusFilter"');
    notifyListeners();
  }
}
