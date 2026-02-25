import 'task_item.dart';

class ProjectDetails {
  final String name;
  final String projectName;
  final String status;
  final String customer;
  final double percentComplete;
  final String company;
  final String expectedStartDate;
  final String expectedEndDate;
  final List<TaskItem> tasks;

  ProjectDetails({
    required this.name,
    required this.projectName,
    required this.status,
    required this.customer,
    required this.percentComplete,
    required this.company,
    required this.expectedStartDate,
    required this.expectedEndDate,
    required this.tasks,
  });
}
