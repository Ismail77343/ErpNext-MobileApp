import '../../domain/entities/task_details.dart';
import '../../domain/entities/task_item.dart';

class TaskActivityModel extends TaskActivity {
  TaskActivityModel({
    required super.name,
    required super.commentBy,
    required super.creation,
    required super.content,
  });

  factory TaskActivityModel.fromJson(Map<String, dynamic> json) {
    return TaskActivityModel(
      name: json['name']?.toString() ?? '',
      commentBy: json['comment_by']?.toString() ?? '',
      creation: json['creation']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
  }
}

class TaskDetailsModel extends TaskDetails {
  TaskDetailsModel({
    required super.name,
    required super.subject,
    required super.status,
    required super.project,
    required super.description,
    required super.priority,
    required super.dueDate,
    required super.expectedStartDate,
    required super.expectedEndDate,
    required super.progress,
    required super.childFollow,
    required super.activityLog,
  });

  factory TaskDetailsModel.fromJson(Map<String, dynamic> json) {
    final progressRaw = json['progress'];
    final childRaw = json['child_follow'];
    final activityRaw = json['activity_log'];

    final childFollow = _parseChildFollow(childRaw);

    final activityLog = activityRaw is List
        ? activityRaw
            .whereType<Map<String, dynamic>>()
            .map(TaskActivityModel.fromJson)
            .toList()
        : <TaskActivityModel>[];

    childFollow.sort((a, b) {
      final aDate = DateTime.tryParse(a.dueDate);
      final bDate = DateTime.tryParse(b.dueDate);
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });

    return TaskDetailsModel(
      name: json['name']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      project: json['project']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      expectedStartDate: json['exp_start_date']?.toString() ?? '',
      expectedEndDate: json['exp_end_date']?.toString() ?? '',
      progress: progressRaw is num
          ? progressRaw.toDouble()
          : double.tryParse(progressRaw?.toString() ?? '0') ?? 0,
      childFollow: childFollow,
      activityLog: activityLog,
    );
  }

  static List<TaskItem> _parseChildFollow(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(_taskItemFromJson)
          .toList();
    }

    if (raw is Map<String, dynamic>) {
      return raw.values
          .whereType<Map<String, dynamic>>()
          .map(_taskItemFromJson)
          .toList();
    }

    return <TaskItem>[];
  }

  static TaskItem _taskItemFromJson(Map<String, dynamic> json) {
    final progressRaw = json['progress'] ?? json['percent_complete'];
    final attachment = _extractAttachment(json);

    return TaskItem(
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? json['subject']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? json['exp_end_date']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      assignedTo: json['assigned_to']?.toString() ?? '',
      expectedStartDate: json['exp_start_date']?.toString() ?? '',
      expectedEndDate: json['exp_end_date']?.toString() ?? '',
      progress: progressRaw is num
          ? progressRaw.toDouble()
          : double.tryParse(progressRaw?.toString() ?? '0') ?? 0,
      followUp: json['follow_up']?.toString() ?? json['followup']?.toString() ?? '',
      dateFollow: json['date_follow']?.toString() ?? json['date']?.toString() ?? '',
      timeFollow: json['time_follow']?.toString() ?? '',
      registrationDateTime: json['date_time_registration']?.toString() ?? '',
      attachment: attachment,
    );
  }

  static String _extractAttachment(Map<String, dynamic> json) {
    dynamic raw =
        json['file'] ??
        json['attachment'] ??
        json['file_url'] ??
        json['attach'] ??
        json['image'];

    // Fallback: pick any key that looks like an attachment field.
    raw ??= () {
      for (final entry in json.entries) {
        final k = entry.key.toLowerCase();
        if (k.contains('file') || k.contains('attach') || k.contains('url')) {
          final value = entry.value?.toString() ?? '';
          if (value.isNotEmpty && value != 'None' && value != 'null') {
            return value;
          }
        }
      }
      return null;
    }();

    var value = raw?.toString().trim() ?? '';
    if (value.isEmpty || value == 'None' || value == 'null') return '';

    // Handle HTML anchors returned by some ERP fields.
    if (value.contains('href=')) {
      final match = RegExp(r'''href=['"]([^'"]+)''').firstMatch(value);
      if (match != null) value = match.group(1) ?? value;
    }

    return value.trim();
  }
}
