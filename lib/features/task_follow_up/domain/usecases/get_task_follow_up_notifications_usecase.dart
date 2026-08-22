import '../entities/task_follow_up_notification.dart';
import '../repositories/task_follow_up_repository.dart';

class GetTaskFollowUpNotificationsUseCase {
  const GetTaskFollowUpNotificationsUseCase(this._repository);

  final TaskFollowUpRepository _repository;

  Future<List<TaskFollowUpNotification>> call() {
    return _repository.getNotifications();
  }
}
