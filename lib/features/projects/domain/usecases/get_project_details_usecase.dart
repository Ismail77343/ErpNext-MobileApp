import '../entities/project_details.dart';
import '../repositories/project_repository.dart';

class GetProjectDetailsUseCase {
  final ProjectRepository repository;

  GetProjectDetailsUseCase(this.repository);

  Future<ProjectDetails> call(String projectName) {
    return repository.getProjectDetails(projectName);
  }
}
