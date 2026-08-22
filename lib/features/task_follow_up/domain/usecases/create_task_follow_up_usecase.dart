import '../repositories/task_follow_up_repository.dart';

class CreateTaskFollowUpUseCase {
  const CreateTaskFollowUpUseCase(this._repository);

  final TaskFollowUpRepository _repository;

  Future<void> call(Map<String, dynamic> data) {
    return _repository.createTask(data);
  }
}
