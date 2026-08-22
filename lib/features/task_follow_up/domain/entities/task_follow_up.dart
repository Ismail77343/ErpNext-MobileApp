class TaskFollowUp {
  final String name;
  final String subject;
  final String details;
  final String priority;
  final String status;
  final int progress;
  final String project;
  final String task;
  final String assignedToUser;
  final String assignedToEmployee;
  final String assignedBy;
  final String startDate;
  final String dueDate;
  final String modified;
  final bool read;
  final bool canClose;

  const TaskFollowUp({
    required this.name,
    required this.subject,
    required this.details,
    required this.priority,
    required this.status,
    required this.progress,
    required this.project,
    required this.task,
    required this.assignedToUser,
    required this.assignedToEmployee,
    required this.assignedBy,
    required this.startDate,
    required this.dueDate,
    required this.modified,
    required this.read,
    required this.canClose,
  });
}
