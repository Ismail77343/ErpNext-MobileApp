import '../entities/workflow_notification.dart';
import '../entities/workflow_notifications_summary.dart';

abstract class WorkflowNotificationsRepository {
  Future<List<WorkflowNotification>> getNotifications({
    required int start,
    required int limit,
  });

  Future<WorkflowNotificationsSummary> getSummary();
}
