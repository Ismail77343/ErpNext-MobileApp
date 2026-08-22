import '../entities/task_follow_up_details.dart';
import '../repositories/task_follow_up_repository.dart';

class GetTaskFollowUpDetailsUseCase {
  const GetTaskFollowUpDetailsUseCase(this._repository);

  final TaskFollowUpRepository _repository;

  Future<TaskFollowUpDetails> call(String name) {
    return _repository.getDetails(name);
  }
}
