import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_branding.dart';
import '../../../../core/constants/app_links.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../hr/presentation/pages/hr_page.dart';
import '../../../projects/presentation/pages/projects_page.dart';
import '../../../purchases/presentation/pages/purchases_page.dart';
import '../../../sales/presentation/pages/sales_page.dart';
import '../../../stores/presentation/pages/stores_page.dart';
import '../../../ai_advisor/presentation/pages/ai_advisor_page.dart';
import '../../../workflow_notifications/presentation/pages/workflow_notifications_page.dart';
import '../../../workflow_notifications/presentation/providers/workflow_notifications_provider.dart';
import '../../../task_follow_up/presentation/pages/task_follow_ups_page.dart';
import '../../../task_follow_up/presentation/providers/task_follow_up_notifications_provider.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WorkflowNotificationsProvider>().initialize();
      context.read<TaskFollowUpNotificationsProvider>().refresh();
    });
  }

  static const _titles = [
    "Home",
    "Projects",
    "Tasks",
    "Sales",
    "Purchases",
    "Smart Advisor",
  ];

  void _goTo(int i) {
    setState(() => _index = i);
    Navigator.of(context).maybePop();
  }

  Future<void> _openUpdateLink() async {
    final uri = Uri.parse(AppLinks.appUpdateUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open update link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workflowNotifications = context
        .watch<WorkflowNotificationsProvider>();
    final pages = [
      HomePage(
        embedded: true,
        onOpenProjectsTab: () => _goTo(1),
        onOpenSalesTab: () => _goTo(3),
      ),
      const ProjectsPage(embedded: true),
      const TaskFollowUpsPage(embedded: true),
      const SalesPage(embedded: true),
      const PurchasesPage(embedded: true),
      const AiAdvisorPage(embedded: true),
    ];
    final taskNotifications = context
        .watch<TaskFollowUpNotificationsProvider>();
    final totalUnread =
        workflowNotifications.unreadCount + taskNotifications.unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WorkflowNotificationsPage(),
                ),
              );
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded),
                if (totalUnread > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$totalUnread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(
                title: Text(
                  "${AppBranding.appName} Menu",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text("Home"),
                onTap: () => _goTo(0),
              ),
              ListTile(
                leading: const Icon(Icons.work_outline_rounded),
                title: const Text("Projects"),
                onTap: () => _goTo(1),
              ),
              ListTile(
                leading: const Icon(Icons.task_alt_rounded),
                title: const Text("Task Follow Ups"),
                onTap: () => _goTo(2),
              ),
              ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: const Text("Sales"),
                onTap: () => _goTo(3),
              ),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text("Human Resources"),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HrPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.warehouse_outlined),
                title: const Text("Stores"),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StoresPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: const Text("Purchases"),
                onTap: () => _goTo(4),
              ),
              ListTile(
                leading: const Icon(Icons.smart_toy_outlined),
                title: const Text("Smart Advisor"),
                onTap: () => _goTo(5),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.system_update_alt_rounded),
                title: const Text("Update App"),
                subtitle: const Text("Download latest version"),
                onTap: _openUpdateLink,
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text("Logout"),
                onTap: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: pages),
      extendBody: false,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: _goTo,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline_rounded),
            label: "Projects",
          ),
          BottomNavigationBarItem(icon: _TaskNavIcon(), label: "Tasks"),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            label: "Sales",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: "Purchases",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            label: "AI",
          ),
        ],
      ),
    );
  }
}

class _TaskNavIcon extends StatelessWidget {
  const _TaskNavIcon();

  @override
  Widget build(BuildContext context) {
    final unread = context
        .watch<TaskFollowUpNotificationsProvider>()
        .unreadCount;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.task_alt_rounded),
        if (unread > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
