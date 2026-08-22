import '../repositories/task_follow_up_repository.dart';

class AddTaskFollowUpUpdateUseCase {
  const AddTaskFollowUpUpdateUseCase(this._repository);

  final TaskFollowUpRepository _repository;

  Future<void> call({
    required String name,
    required String note,
    required int progress,
    required String status,
    String? attachment,
  }) {
    return _repository.addUpdate(
      name: name,
      note: note,
      progress: progress,
      status: status,
      attachment: attachment,
    );
  }
}
