import '../repositories/task_follow_up_repository.dart';

class UploadTaskFollowUpAttachmentUseCase {
  const UploadTaskFollowUpAttachmentUseCase(this._repository);

  final TaskFollowUpRepository _repository;

  Future<String> call({required String filePath, required String docname}) {
    return _repository.uploadAttachment(filePath: filePath, docname: docname);
  }
}
