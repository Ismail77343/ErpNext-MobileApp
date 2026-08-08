import '../entities/workflow_notification.dart';
import '../repositories/workflow_notifications_repository.dart';

class GetWorkflowNotificationsUseCase {
  final WorkflowNotificationsRepository repository;

  GetWorkflowNotificationsUseCase(this.repository);

  Future<List<WorkflowNotification>> call({
    required int start,
    required int limit,
  }) {
    return repository.getNotifications(start: start, limit: limit);
  }
}
