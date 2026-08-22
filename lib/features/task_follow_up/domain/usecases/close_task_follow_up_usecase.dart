import '../repositories/task_follow_up_repository.dart';

class CloseTaskFollowUpUseCase {
  const CloseTaskFollowUpUseCase(this._repository);

  final TaskFollowUpRepository _repository;

  Future<void> call({
    required String name,
    required String status,
    required String note,
  }) {
    return _repository.closeTask(name: name, status: status, note: note);
  }
}
