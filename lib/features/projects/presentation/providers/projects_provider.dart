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

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get hasMore => _hasMoreFromServer;
  bool get canLoadMore => _searchQuery.isEmpty && _hasMoreFromServer;

  List<Project> get projects {
    if (_searchQuery.isEmpty) return _projects;
    final q = _searchQuery.toLowerCase();
    return _projects.where((project) {
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
        '==== fetched project==== batch=${batch.length} total=${_projects.length} nextStart=$_nextStart hasMore=$_hasMoreFromServer',
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
    if (_searchQuery.isNotEmpty) return;

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
        'project load more done batch=${batch.length} added=${newItems.length} total=${_projects.length} nextStart=$_nextStart hasMore=$_hasMoreFromServer',
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
}
