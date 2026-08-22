import '../entities/link_option.dart';
import '../entities/task_follow_up.dart';
import '../entities/task_follow_up_details.dart';
import '../entities/task_follow_up_notification.dart';

abstract class TaskFollowUpRepository {
  Future<List<TaskFollowUp>> getMyTasks({
    String? status,
    bool onlyOpen = false,
    required int start,
    required int limit,
  });

  Future<List<TaskFollowUp>> getAssignedTasks({
    String? status,
    bool onlyOpen = false,
    required int start,
    required int limit,
  });

  Future<TaskFollowUpDetails> getDetails(String name);

  Future<void> createTask(Map<String, dynamic> data);

  Future<void> addUpdate({
    required String name,
    required String note,
    required int progress,
    required String status,
    String? attachment,
  });

  Future<void> closeTask({
    required String name,
    required String status,
    required String note,
  });

  Future<List<TaskFollowUpNotification>> getNotifications();

  Future<void> markAsRead(String name);

  Future<List<LinkOption>> searchLinkOptions({
    required String doctype,
    String query = '',
  });

  Future<String> uploadAttachment({
    required String filePath,
    required String docname,
  });
}
