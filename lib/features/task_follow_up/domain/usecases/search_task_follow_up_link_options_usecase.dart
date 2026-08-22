import '../entities/link_option.dart';
import '../repositories/task_follow_up_repository.dart';

class SearchTaskFollowUpLinkOptionsUseCase {
  const SearchTaskFollowUpLinkOptionsUseCase(this._repository);

  final TaskFollowUpRepository _repository;

  Future<List<LinkOption>> call({required String doctype, String query = ''}) {
    return _repository.searchLinkOptions(doctype: doctype, query: query);
  }
}
