import '../entities/workflow_notifications_summary.dart';
import '../repositories/workflow_notifications_repository.dart';

class GetWorkflowNotificationsSummaryUseCase {
  final WorkflowNotificationsRepository repository;

  GetWorkflowNotificationsSummaryUseCase(this.repository);

  Future<WorkflowNotificationsSummary> call() {
    return repository.getSummary();
  }
}
