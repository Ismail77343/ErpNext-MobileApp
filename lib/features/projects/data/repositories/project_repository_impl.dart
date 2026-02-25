import '../../domain/entities/project.dart';
import '../../domain/entities/project_details.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_datasource.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;

  ProjectRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Project>> getProjects({required int start, required int limit}) {
    return remoteDataSource.getProjects(start: start, limit: limit);
  }

  @override
  Future<ProjectDetails> getProjectDetails(String projectName) {
    return remoteDataSource.getProjectDetails(projectName);
  }
}
