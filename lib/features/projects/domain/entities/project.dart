class Project {
  final String name;
  final String projectName;
  final String status;
  final String customer;
  final double percentComplete;

  Project({
    required this.name,
    required this.projectName,
    required this.status,
    required this.customer,
    required this.percentComplete,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    final percent = json['percent_complete'];
    return Project(
      name: json['name']?.toString() ?? "",
      projectName: json['project_name']?.toString() ?? "",
      status: json['status']?.toString() ?? "",
      customer: json['customer']?.toString() ?? "",
      percentComplete: percent is num
          ? percent.toDouble()
          : double.tryParse(percent?.toString() ?? "0") ?? 0,
    );
  }
}
