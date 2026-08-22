import '../repositories/task_follow_up_repository.dart';

class MarkTaskFollowUpReadUseCase {
  const MarkTaskFollowUpReadUseCase(this._repository);

  final TaskFollowUpRepository _repository;

  Future<void> call(String name) {
    return _repository.markAsRead(name);
  }
}
