import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetProjectsUseCase {
  final ProjectRepository repository;

  GetProjectsUseCase(this.repository);

  Future<List<Project>> call({required int start, required int limit}) {
    return repository.getProjects(start: start, limit: limit);
  }
}
