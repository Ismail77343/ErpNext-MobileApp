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
  static const List<String> _statusFilters = [
    'All',
    'Open',
    'Completed',
    'Cancelled',
    'On Hold',
  ];

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

    final visibleProjects = provider.projects;

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
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _statusFilters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = _statusFilters[index];
                final selected = provider.statusFilter == status;
                return ChoiceChip(
                  label: Text(status),
                  selected: selected,
                  onSelected: (_) => provider.setStatusFilter(status),
                );
              },
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                ? _ProjectsStateCard(
                    title: 'Unable to load projects',
                    message: provider.error!,
                    icon: Icons.cloud_off_rounded,
                    isError: true,
                    onRefresh: () => provider.fetchProjects(),
                  )
                : visibleProjects.isEmpty
                ? _ProjectsStateCard(
                    title: provider.hasAnyFilter
                        ? 'No projects match your filters'
                        : 'No projects assigned to your user',
                    message: provider.hasAnyFilter
                        ? 'Search: ${provider.searchQuery.isEmpty ? 'none' : provider.searchQuery}\nStatus: ${provider.statusFilter}'
                        : 'The app is showing projects returned by get_my_projects for the current logged-in user.',
                    icon: provider.hasAnyFilter
                        ? Icons.filter_alt_off_rounded
                        : Icons.work_off_outlined,
                    onRefresh: () => provider.fetchProjects(),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    itemCount:
                        visibleProjects.length +
                        (provider.canLoadMore || provider.isLoadingMore
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      if (index >= visibleProjects.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final project = visibleProjects[index];
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
                              builder: (_) =>
                                  ProjectDetailsPage(projectName: project.name),
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

class _ProjectsStateCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final bool isError;
  final VoidCallback onRefresh;

  const _ProjectsStateCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.onRefresh,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFBE123C) : const Color(0xFF0E7490);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(color: Color(0xFF475569), height: 1.35),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
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
                    backgroundColor: const Color(
                      0xFF0E7490,
                    ).withValues(alpha: 0.14),
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
