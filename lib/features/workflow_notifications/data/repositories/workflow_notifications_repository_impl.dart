import '../../domain/entities/workflow_notification.dart';
import '../../domain/entities/workflow_notifications_summary.dart';
import '../../domain/repositories/workflow_notifications_repository.dart';
import '../datasources/workflow_notifications_remote_datasource.dart';

class WorkflowNotificationsRepositoryImpl
    implements WorkflowNotificationsRepository {
  final WorkflowNotificationsRemoteDataSource remoteDataSource;

  WorkflowNotificationsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<WorkflowNotification>> getNotifications({
    required int start,
    required int limit,
  }) {
    return remoteDataSource.getNotifications(start: start, limit: limit);
  }

  @override
  Future<WorkflowNotificationsSummary> getSummary() {
    return remoteDataSource.getSummary();
  }
}
