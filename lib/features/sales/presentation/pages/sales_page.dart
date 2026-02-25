import 'package:flutter/material.dart';

class SalesPage extends StatelessWidget {
  final bool embedded;

  const SalesPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final body = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF7ED), Color(0xFFF8FAFC)],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SalesCard(
            title: "Leads",
            subtitle: "Potential customers and contacts",
            icon: Icons.person_add_alt_1_rounded,
            color: Color(0xFFFFEDD5),
          ),
          SizedBox(height: 12),
          _SalesCard(
            title: "Opportunities",
            subtitle: "Open sales opportunities",
            icon: Icons.trending_up_rounded,
            color: Color(0xFFFFF3C7),
          ),
          SizedBox(height: 12),
          _SalesCard(
            title: "Quotations",
            subtitle: "Sales quotations overview",
            icon: Icons.request_quote_rounded,
            color: Color(0xFFE0F2FE),
          ),
        ],
      ),
    );

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text("Sales")),
      body: body,
    );
  }
}

class _SalesCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SalesCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(icon, color: const Color(0xFF7C2D12)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
