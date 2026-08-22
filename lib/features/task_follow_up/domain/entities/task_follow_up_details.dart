import 'task_follow_up.dart';
import 'task_follow_up_update.dart';

class TaskFollowUpDetails extends TaskFollowUp {
  final List<TaskFollowUpUpdate> updates;

  const TaskFollowUpDetails({
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
    required this.updates,
  });
}
