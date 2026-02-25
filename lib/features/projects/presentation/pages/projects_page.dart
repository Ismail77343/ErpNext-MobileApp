import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/project.dart';
import 'project_details_page.dart';
import '../providers/projects_provider.dart';

class ProjectsPage extends StatefulWidget {
  final bool embedded;

  const ProjectsPage({super.key, this.embedded = false});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    AppLogger.project('projects page opened');
    _searchController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final threshold = _scrollController.position.maxScrollExtent - 180;
      if (_scrollController.position.pixels >= threshold) {
        final provider = context.read<ProjectsProvider>();
        if (provider.canLoadMore) {
          provider.loadMoreProjects();
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProjectsProvider>().fetchProjects();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectsProvider>();

    final body = Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F6FB), Color(0xFFF4F8FB)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: provider.setSearchQuery,
                decoration: InputDecoration(
                  hintText: "Search by name, customer, status...",
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            provider.setSearchQuery('');
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              provider.error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : provider.projects.isEmpty
                          ? const Center(child: Text("No projects found"))
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.projects.length +
                                  (provider.canLoadMore || provider.isLoadingMore
                                      ? 1
                                      : 0),
                              itemBuilder: (context, index) {
                                if (index >= provider.projects.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final project = provider.projects[index];
                                return _ProjectCard(
                                  index: index,
                                  project: project,
                                  onTap: () {
                                    AppLogger.nav(
                                      'open project details from projects page: ${project.name}',
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProjectDetailsPage(
                                          projectName: project.name,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text("Projects")),
      body: body,
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final int index;
  final Project project;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.index,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = project.percentComplete.clamp(0, 100).toDouble();
    final progressColor = _progressColor(percent);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF0E7490).withValues(
                      alpha: 0.14,
                    ),
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        color: Color(0xFF0E7490),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      project.projectName.isNotEmpty
                          ? project.projectName
                          : project.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      "${percent.toStringAsFixed(0)}%",
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Code: ${project.name}",
                style: const TextStyle(color: Color(0xFF334155)),
              ),
              const SizedBox(height: 4),
              Text(
                "Customer: ${project.customer}",
                style: const TextStyle(color: Color(0xFF334155)),
              ),
              const SizedBox(height: 4),
              Text(
                "Status: ${project.status}",
                style: const TextStyle(color: Color(0xFF334155)),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: percent / 100,
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                color: progressColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _progressColor(double percent) {
    if (percent < 35) return const Color(0xFFDC2626);
    if (percent < 70) return const Color(0xFFD97706);
    return const Color(0xFF16A34A);
  }
}
