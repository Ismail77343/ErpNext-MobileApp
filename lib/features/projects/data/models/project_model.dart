import '../../domain/entities/project.dart';

class ProjectModel extends Project {
  ProjectModel({
    required super.name,
    required super.projectName,
    required super.status,
    required super.customer,
    required super.percentComplete,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final percent = json['percent_complete'];
    return ProjectModel(
      name: json['name']?.toString() ?? '',
      projectName: json['project_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      customer: json['customer']?.toString() ?? '',
      percentComplete: percent is num
          ? percent.toDouble()
          : double.tryParse(percent?.toString() ?? "0") ?? 0,
    );
  }
}
