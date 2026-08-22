import '../../domain/entities/link_option.dart';
import '../../domain/entities/task_follow_up.dart';
import '../../domain/entities/task_follow_up_details.dart';
import '../../domain/entities/task_follow_up_notification.dart';
import '../../domain/repositories/task_follow_up_repository.dart';
import '../datasources/task_follow_up_remote_datasource.dart';

class TaskFollowUpRepositoryImpl implements TaskFollowUpRepository {
  const TaskFollowUpRepositoryImpl(this._remoteDataSource);

  final TaskFollowUpRemoteDataSource _remoteDataSource;

  @override
  Future<List<TaskFollowUp>> getMyTasks({
    String? status,
    bool onlyOpen = false,
    required int start,
    required int limit,
  }) {
    return _remoteDataSource.getMyTasks(
      status: status,
      onlyOpen: onlyOpen,
      start: start,
      limit: limit,
    );
  }

  @override
  Future<List<TaskFollowUp>> getAssignedTasks({
    String? status,
    bool onlyOpen = false,
    required int start,
    required int limit,
  }) {
    return _remoteDataSource.getAssignedTasks(
      status: status,
      onlyOpen: onlyOpen,
      start: start,
      limit: limit,
    );
  }

  @override
  Future<TaskFollowUpDetails> getDetails(String name) {
    return _remoteDataSource.getDetails(name);
  }

  @override
  Future<void> createTask(Map<String, dynamic> data) {
    return _remoteDataSource.createTask(data);
  }

  @override
  Future<void> addUpdate({
    required String name,
    required String note,
    required int progress,
    required String status,
    String? attachment,
  }) {
    return _remoteDataSource.addUpdate(
      name: name,
      note: note,
      progress: progress,
      status: status,
      attachment: attachment,
    );
  }

  @override
  Future<void> closeTask({
    required String name,
    required String status,
    required String note,
  }) {
    return _remoteDataSource.closeTask(name: name, status: status, note: note);
  }

  @override
  Future<List<TaskFollowUpNotification>> getNotifications() {
    return _remoteDataSource.getNotifications();
  }

  @override
  Future<void> markAsRead(String name) {
    return _remoteDataSource.markAsRead(name);
  }

  @override
  Future<List<LinkOption>> searchLinkOptions({
    required String doctype,
    String query = '',
  }) {
    return _remoteDataSource.searchLinkOptions(doctype: doctype, query: query);
  }

  @override
  Future<String> uploadAttachment({
    required String filePath,
    required String docname,
  }) {
    return _remoteDataSource.uploadAttachment(
      filePath: filePath,
      docname: docname,
    );
  }
}
