import 'task_item.dart';

class TaskActivity {
  final String name;
  final String commentBy;
  final String creation;
  final String content;

  TaskActivity({
    required this.name,
    required this.commentBy,
    required this.creation,
    required this.content,
  });
}

class TaskDetails {
  final String name;
  final String subject;
  final String status;
  final String project;
  final String description;
  final String priority;
  final String dueDate;
  final String expectedStartDate;
  final String expectedEndDate;
  final double progress;
  final List<TaskItem> childFollow;
  final List<TaskActivity> activityLog;

  TaskDetails({
    required this.name,
    required this.subject,
    required this.status,
    required this.project,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.expectedStartDate,
    required this.expectedEndDate,
    required this.progress,
    required this.childFollow,
    required this.activityLog,
  });
}
