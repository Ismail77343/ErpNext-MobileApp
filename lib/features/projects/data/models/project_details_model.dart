import '../../domain/entities/project_details.dart';
import '../../domain/entities/task_item.dart';

class ProjectDetailsModel extends ProjectDetails {
  ProjectDetailsModel({
    required super.name,
    required super.projectName,
    required super.status,
    required super.customer,
    required super.percentComplete,
    required super.company,
    required super.expectedStartDate,
    required super.expectedEndDate,
    required super.tasks,
  });

  factory ProjectDetailsModel.fromJson(Map<String, dynamic> json) {
    final percent = json['percent_complete'];
    final tasksRaw = json['tasks'];

    final tasks = tasksRaw is List
        ? tasksRaw
            .whereType<Map<String, dynamic>>()
            .map(_taskFromJson)
            .toList()
        : <TaskItem>[];

    tasks.sort((a, b) {
      final aDate = DateTime.tryParse(a.dueDate);
      final bDate = DateTime.tryParse(b.dueDate);
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });

    return ProjectDetailsModel(
      name: json['name']?.toString() ?? '',
      projectName: json['project_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      customer: json['customer']?.toString() ?? '',
      percentComplete: percent is num
          ? percent.toDouble()
          : double.tryParse(percent?.toString() ?? '0') ?? 0,
      company: json['company']?.toString() ?? '',
      expectedStartDate: json['expected_start_date']?.toString() ?? '',
      expectedEndDate: json['expected_end_date']?.toString() ?? '',
      tasks: tasks,
    );
  }

  static TaskItem _taskFromJson(Map<String, dynamic> json) {
    final progressRaw = json['progress'] ?? json['percent_complete'];
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
      followUp: json['follow_up']?.toString() ?? '',
      dateFollow: json['date_follow']?.toString() ?? '',
      timeFollow: json['time_follow']?.toString() ?? '',
      registrationDateTime: json['date_time_registration']?.toString() ?? '',
      attachment: json['file']?.toString() ?? '',
    );
  }
}
