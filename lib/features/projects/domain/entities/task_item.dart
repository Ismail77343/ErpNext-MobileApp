class TaskItem {
  final String name;
  final String title;
  final String status;
  final String dueDate;
  final String priority;
  final String assignedTo;
  final String expectedStartDate;
  final String expectedEndDate;
  final double progress;
  final String followUp;
  final String dateFollow;
  final String timeFollow;
  final String registrationDateTime;
  final String attachment;

  TaskItem({
    required this.name,
    required this.title,
    required this.status,
    required this.dueDate,
    required this.priority,
    required this.assignedTo,
    required this.expectedStartDate,
    required this.expectedEndDate,
    required this.progress,
    required this.followUp,
    required this.dateFollow,
    required this.timeFollow,
    required this.registrationDateTime,
    required this.attachment,
  });
}
