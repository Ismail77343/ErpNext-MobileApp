import '../../domain/entities/task_follow_up_notification.dart';

class TaskFollowUpNotificationModel extends TaskFollowUpNotification {
  const TaskFollowUpNotificationModel({
    required super.id,
    required super.subject,
    required super.priority,
    required super.status,
    required super.progress,
  });

  factory TaskFollowUpNotificationModel.fromJson(Map<String, dynamic> json) {
    return TaskFollowUpNotificationModel(
      id: _readString(json, const ['id', 'name', 'document_name']),
      subject: _readString(json, const ['subject']),
      priority: _readString(json, const ['priority']),
      status: _readString(json, const ['status']),
      progress: _readInt(json, const ['progress']),
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
