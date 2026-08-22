import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_branding.dart';
import '../../../../core/constants/app_links.dart';
import '../../../../core/localization/localization_extensions.dart';
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
import '../../../settings/presentation/pages/language_page.dart';

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

  void _goTo(int i) {
    setState(() => _index = i);
    Navigator.of(context).maybePop();
  }

  Future<void> _openUpdateLink() async {
    final uri = Uri.parse(AppLinks.appUpdateUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.couldNotOpenUpdateLink)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workflowNotifications = context
        .watch<WorkflowNotificationsProvider>();
    final l10n = context.l10n;
    final titles = [
      l10n.navHome,
      l10n.navProjects,
      l10n.navTasks,
      l10n.navSales,
      l10n.navPurchases,
      l10n.navSmartAdvisor,
    ];
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
        title: Text(titles[_index]),
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
              ListTile(
                title: Text(
                  l10n.appMenu(AppBranding.appName),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: Text(l10n.navHome),
                onTap: () => _goTo(0),
              ),
              ListTile(
                leading: const Icon(Icons.work_outline_rounded),
                title: Text(l10n.navProjects),
                onTap: () => _goTo(1),
              ),
              ListTile(
                leading: const Icon(Icons.task_alt_rounded),
                title: Text(l10n.drawerTaskFollowUps),
                onTap: () => _goTo(2),
              ),
              ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: Text(l10n.navSales),
                onTap: () => _goTo(3),
              ),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: Text(l10n.drawerHumanResources),
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
                title: Text(l10n.drawerStores),
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
                title: Text(l10n.navPurchases),
                onTap: () => _goTo(4),
              ),
              ListTile(
                leading: const Icon(Icons.smart_toy_outlined),
                title: Text(l10n.navSmartAdvisor),
                onTap: () => _goTo(5),
              ),
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: Text(l10n.language),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LanguagePage()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.system_update_alt_rounded),
                title: Text(l10n.drawerUpdateApp),
                subtitle: Text(l10n.drawerDownloadLatestVersion),
                onTap: _openUpdateLink,
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: Text(l10n.drawerLogout),
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.work_outline_rounded),
            label: l10n.navProjects,
          ),
          BottomNavigationBarItem(
            icon: const _TaskNavIcon(),
            label: l10n.navTasks,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.storefront_outlined),
            label: l10n.navSales,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag_outlined),
            label: l10n.navPurchases,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.smart_toy_outlined),
            label: l10n.navAi,
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
