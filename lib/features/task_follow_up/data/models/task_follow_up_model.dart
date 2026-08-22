import '../../domain/entities/task_follow_up.dart';

class TaskFollowUpModel extends TaskFollowUp {
  const TaskFollowUpModel({
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
  });

  factory TaskFollowUpModel.fromJson(Map<String, dynamic> json) {
    return TaskFollowUpModel(
      name: _readString(json, const ['name', 'id', 'document_name']),
      subject: _readString(json, const ['subject', 'title']),
      details: _readString(json, const ['details', 'description']),
      priority: _readString(json, const ['priority']),
      status: _readString(json, const ['status']),
      progress: _readInt(json, const ['progress', 'percent_complete']),
      project: _readString(json, const ['project']),
      task: _readString(json, const ['task']),
      assignedToUser: _readString(json, const [
        'assigned_to_user',
        'allocated_to',
      ]),
      assignedToEmployee: _readString(json, const ['assigned_to_employee']),
      assignedBy: _readString(json, const ['assigned_by', 'owner']),
      startDate: _readString(json, const ['start_date']),
      dueDate: _readString(json, const ['due_date']),
      modified: _readString(json, const ['modified', 'creation']),
      read: _readBool(json, const ['read', 'seen', 'is_read']),
      canClose: _readBool(json, const ['can_close']),
    );
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  return '';
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.round();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return 0;
}

bool _readBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim();
    if (text == 'true' || text == '1' || text == 'yes') return true;
  }
  return false;
}
