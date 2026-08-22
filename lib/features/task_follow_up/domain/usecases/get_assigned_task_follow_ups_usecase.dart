import '../entities/task_follow_up.dart';
import '../repositories/task_follow_up_repository.dart';

class GetAssignedTaskFollowUpsUseCase {
  const GetAssignedTaskFollowUpsUseCase(this._repository);

  final TaskFollowUpRepository _repository;

  Future<List<TaskFollowUp>> call({
    String? status,
    bool onlyOpen = false,
    required int start,
    required int limit,
  }) {
    return _repository.getAssignedTasks(
      status: status,
      onlyOpen: onlyOpen,
      start: start,
      limit: limit,
    );
  }
}
