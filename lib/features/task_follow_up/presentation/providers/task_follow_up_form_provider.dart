import 'package:flutter/material.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/link_option.dart';
import '../../domain/usecases/create_task_follow_up_usecase.dart';
import '../../domain/usecases/search_task_follow_up_link_options_usecase.dart';

class TaskFollowUpFormProvider extends ChangeNotifier {
  TaskFollowUpFormProvider(
    this._createTaskFollowUpUseCase,
    this._searchLinkOptionsUseCase,
  );

  final CreateTaskFollowUpUseCase _createTaskFollowUpUseCase;
  final SearchTaskFollowUpLinkOptionsUseCase _searchLinkOptionsUseCase;

  final List<String> assignedEmployees = [];
  final List<String> assignedUsers = [];
  bool _isSubmitting = false;
  String? _error;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<List<LinkOption>> search({
    required String doctype,
    String query = '',
  }) {
    return _searchLinkOptionsUseCase.call(doctype: doctype, query: query);
  }

  void addEmployee(String value) {
    if (value.isNotEmpty && !assignedEmployees.contains(value)) {
      assignedEmployees.add(value);
      notifyListeners();
    }
  }

  void removeEmployee(String value) {
    assignedEmployees.remove(value);
    notifyListeners();
  }

  void addUser(String value) {
    if (value.isNotEmpty && !assignedUsers.contains(value)) {
      assignedUsers.add(value);
      notifyListeners();
    }
  }

  void removeUser(String value) {
    assignedUsers.remove(value);
    notifyListeners();
  }

  Future<bool> submit({
    required String subject,
    required String details,
    required String priority,
    required String project,
    required String task,
    required String startDate,
    required String dueDate,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      if (assignedEmployees.isEmpty && assignedUsers.isEmpty) {
        throw Exception('Please select at least one employee or user.');
      }
      if (subject.trim().isEmpty) {
        throw Exception('Subject is required.');
      }

      await _createTaskFollowUpUseCase.call({
        'assigned_to_employees': assignedEmployees,
        'assigned_to_users': assignedUsers,
        'subject': subject.trim(),
        if (details.trim().isNotEmpty) 'details': details.trim(),
        if (priority.trim().isNotEmpty) 'priority': priority.trim(),
        if (project.trim().isNotEmpty) 'project': project.trim(),
        if (task.trim().isNotEmpty) 'task': task.trim(),
        if (startDate.trim().isNotEmpty) 'start_date': startDate.trim(),
        if (dueDate.trim().isNotEmpty) 'due_date': dueDate.trim(),
      });
      return true;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('create task follow up failed: $_error');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void reset() {
    assignedEmployees.clear();
    assignedUsers.clear();
    _error = null;
    notifyListeners();
  }
}
