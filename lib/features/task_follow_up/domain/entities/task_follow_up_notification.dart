class TaskFollowUpNotification {
  final String id;
  final String subject;
  final String priority;
  final String status;
  final int progress;

  const TaskFollowUpNotification({
    required this.id,
    required this.subject,
    required this.priority,
    required this.status,
    required this.progress,
  });
}
