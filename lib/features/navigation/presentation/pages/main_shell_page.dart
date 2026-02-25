import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_links.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../projects/presentation/pages/projects_page.dart';
import '../../../purchases/presentation/pages/purchases_page.dart';
import '../../../sales/presentation/pages/sales_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  static const _titles = ["Home", "Projects", "Sales", "Purchases"];

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
    final pages = [
      HomePage(
        embedded: true,
        onOpenProjectsTab: () => _goTo(1),
        onOpenSalesTab: () => _goTo(2),
      ),
      const ProjectsPage(embedded: true),
      const SalesPage(embedded: true),
      const PurchasesPage(embedded: true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(
                title: Text(
                  "ERP Menu",
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
                leading: const Icon(Icons.storefront_outlined),
                title: const Text("Sales"),
                onTap: () => _goTo(2),
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: const Text("Purchases"),
                onTap: () => _goTo(3),
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
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      extendBody: true,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            label: "Sales",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: "Purchases",
          ),
        ],
      ),
    );
  }
}
