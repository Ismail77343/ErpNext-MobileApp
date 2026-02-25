import '../entities/project.dart';
import '../entities/project_details.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects({required int start, required int limit});
  Future<ProjectDetails> getProjectDetails(String projectName);
}
