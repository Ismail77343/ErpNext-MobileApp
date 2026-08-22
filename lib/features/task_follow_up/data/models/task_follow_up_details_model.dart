import '../../domain/entities/task_follow_up_details.dart';
import 'task_follow_up_model.dart';
import 'task_follow_up_update_model.dart';

class TaskFollowUpDetailsModel extends TaskFollowUpDetails {
  const TaskFollowUpDetailsModel({
    required super.name,
    required super.subject,
    required super.details,
    required super.priority,
    required super.status,
    required super.progress,
    required super.project,
    required super.task,
    required super.assignedToUser,
    required super.assignedToEmployee,
    required super.assignedBy,
    required super.startDate,
    required super.dueDate,
    required super.modified,
    required super.read,
    required super.canClose,
    required super.updates,
  });

  factory TaskFollowUpDetailsModel.fromJson(Map<String, dynamic> json) {
    final base = TaskFollowUpModel.fromJson(json);
    final updatesRaw = _extractList(json, const [
      'updates',
      'follow_ups',
      'logs',
    ]);
    return TaskFollowUpDetailsModel(
      name: base.name,
      subject: base.subject,
      details: base.details,
      priority: base.priority,
      status: base.status,
      progress: base.progress,
      project: base.project,
      task: base.task,
      assignedToUser: base.assignedToUser,
      assignedToEmployee: base.assignedToEmployee,
      assignedBy: base.assignedBy,
      startDate: base.startDate,
      dueDate: base.dueDate,
      modified: base.modified,
      read: base.read,
      canClose: base.canClose,
      updates: updatesRaw
          .whereType<Map<String, dynamic>>()
          .map(TaskFollowUpUpdateModel.fromJson)
          .toList(),
    );
  }
}

List<dynamic> _extractList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) return value;
  }
  return const [];
}
