import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../projects/presentation/pages/project_details_page.dart';
import '../../../projects/presentation/pages/projects_page.dart';
import '../../../projects/presentation/providers/projects_provider.dart';
import '../../../sales/presentation/pages/sales_page.dart';

class HomePage extends StatefulWidget {
  final bool? embedded;
  final VoidCallback? onOpenProjectsTab;
  final VoidCallback? onOpenSalesTab;

  const HomePage({
    super.key,
    this.embedded,
    this.onOpenProjectsTab,
    this.onOpenSalesTab,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    AppLogger.info('home page opened');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProjectsProvider>().fetchProjects(limit: 5);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final projects = context.watch<ProjectsProvider>();
    final previewProjects = projects.projects.take(5).toList();
    final user = auth.user;
    final userName = (user?.name ?? '').trim().isNotEmpty
        ? user!.name
        : (user?.email ?? 'User');

    final content = RefreshIndicator(
      onRefresh: () => context.read<ProjectsProvider>().fetchProjects(limit: 5),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDFF4FA), Color(0xFFF4F8FB)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E7490), Color(0xFF14B8A6)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _HomeCard(
              title: 'Sales',
              subtitle: 'Open sales cards',
              icon: Icons.storefront_outlined,
              cardColor: const Color(0xFFFFF7E6),
              iconBg: const Color(0xFFFFD78A),
              onTap: () {
                if (widget.onOpenSalesTab != null) {
                  widget.onOpenSalesTab!.call();
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalesPage()),
                );
              },
            ),
            const SizedBox(height: 12),
            _HomeCard(
              title: 'Projects',
              subtitle: 'Go to all projects',
              icon: Icons.work_outline_rounded,
              cardColor: const Color(0xFFE9F7F5),
              iconBg: const Color(0xFFBDEEE8),
              onTap: () {
                if (widget.onOpenProjectsTab != null) {
                  widget.onOpenProjectsTab!.call();
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProjectsPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'My Projects',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (projects.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (projects.error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    projects.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (projects.projects.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No projects found'),
                ),
              )
            else
              ...previewProjects.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final project = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProjectDetailsPage(
                              projectName: project.name,
                            ),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF0E7490),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        project.projectName.isNotEmpty
                            ? project.projectName
                            : project.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${project.status} • ${project.percentComplete.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: _progressColor(project.percentComplete),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            if (projects.projects.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: TextButton(
                  onPressed: () {
                    if (widget.onOpenProjectsTab != null) {
                      widget.onOpenProjectsTab!.call();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProjectsPage()),
                      );
                    }
                  },
                  child: const Text('Show all projects'),
                ),
              ),
          ],
        ),
      ),
    );

    if ((widget.embedded ?? false)) return content;

    return Scaffold(
      appBar: AppBar(title: const Text('ERP Dashboard')),
      body: content,
    );
  }

  Color _progressColor(double percent) {
    if (percent < 35) return const Color(0xFFDC2626);
    if (percent < 70) return const Color(0xFFD97706);
    return const Color(0xFF16A34A);
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color cardColor;
  final Color iconBg;

  const _HomeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.cardColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: iconBg,
          child: Icon(icon, size: 22, color: const Color(0xFF155E75)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}
