import 'package:flutter/material.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/project_details.dart';
import '../../domain/usecases/get_project_details_usecase.dart';

class ProjectDetailsProvider extends ChangeNotifier {
  final GetProjectDetailsUseCase getProjectDetailsUseCase;

  ProjectDetailsProvider(this.getProjectDetailsUseCase);

  bool _isLoading = false;
  ProjectDetails? _projectDetails;
  String? _error;

  bool get isLoading => _isLoading;
  ProjectDetails? get projectDetails => _projectDetails;
  String? get error => _error;

  Future<void> fetchProjectDetails(String projectName) async {
    AppLogger.project('project details loading start: $projectName');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _projectDetails = await getProjectDetailsUseCase.call(projectName);
      AppLogger.project('project details loading success: $projectName');
    } catch (e) {
      _projectDetails = null;
      _error = e.toString();
      AppLogger.error('project details loading failed: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
