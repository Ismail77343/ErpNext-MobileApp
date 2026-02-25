import 'package:flutter/material.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/datasources/project_remote_datasource.dart';
import '../../domain/entities/project_details.dart';
import 'task_details_page.dart';

class ProjectDetailsPage extends StatefulWidget {
  final String projectName;

  const ProjectDetailsPage({super.key, required this.projectName});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  final ProjectRemoteDataSource _remoteDataSource = ProjectRemoteDataSource();
  bool _isLoading = false;
  ProjectDetails? _projectDetails;
  String? _error;

  @override
  void initState() {
    super.initState();
    AppLogger.nav('open project details page: ${widget.projectName}');
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final details = await _remoteDataSource.getProjectDetails(
        widget.projectName,
      );
      if (!mounted) return;
      setState(() => _projectDetails = details);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Project ${widget.projectName}")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _projectDetails == null
                  ? const Center(child: Text("No project details found"))
                  : RefreshIndicator(
                      onRefresh: _loadDetails,
                      child: _DetailsView(details: _projectDetails!),
                    ),
    );
  }
}

class _DetailsView extends StatelessWidget {
  final ProjectDetails details;

  const _DetailsView({required this.details});

  @override
  Widget build(BuildContext context) {
    final percent = details.percentComplete.clamp(0, 100).toDouble();
    final color = _progressColor(percent);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.projectName.isNotEmpty ? details.projectName : details.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text("Code: ${details.name}"),
                const SizedBox(height: 4),
                Text("Status: ${details.status}"),
                const SizedBox(height: 4),
                Text("Customer: ${details.customer}"),
                const SizedBox(height: 4),
                Text("Company: ${details.company}"),
                const SizedBox(height: 4),
                Text(
                  "From ${_displayDate(details.expectedStartDate)} to ${_displayDate(details.expectedEndDate)}",
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Project Progress",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "${percent.toStringAsFixed(0)}%",
                      style: TextStyle(fontWeight: FontWeight.w700, color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: 10,
                  color: color,
                  backgroundColor: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tasks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              "${details.tasks.length}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (details.tasks.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text("No tasks found for this project"),
            ),
          )
        else
          ...details.tasks.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final task = entry.value;
              final taskProgress = task.progress.clamp(0, 100).toDouble();
              final taskColor = _progressColor(taskProgress);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  onTap: () {
                    AppLogger.nav('open task details from project: ${task.name}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailsPage(taskName: task.name),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF0E7490).withValues(alpha: 0.12),
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        color: Color(0xFF0E7490),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(task.title.isNotEmpty ? task.title : task.name),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${task.status} • Due: ${_displayDate(task.dueDate)}"),
                        Text(
                          "From ${_displayDate(task.expectedStartDate)} to ${_displayDate(task.expectedEndDate)}",
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: taskProgress / 100,
                            minHeight: 7,
                            color: taskColor,
                            backgroundColor: const Color(0xFFE2E8F0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Text(
                    "${taskProgress.toStringAsFixed(0)}%",
                    style: TextStyle(
                      color: taskColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Color _progressColor(double percent) {
    if (percent < 35) return const Color(0xFFDC2626);
    if (percent < 70) return const Color(0xFFD97706);
    return const Color(0xFF16A34A);
  }
}

String _displayDate(String value) {
  final d = DateTime.tryParse(value);
  if (d == null) return value.isEmpty ? "-" : value;
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return "$y-$m-$day";
}
