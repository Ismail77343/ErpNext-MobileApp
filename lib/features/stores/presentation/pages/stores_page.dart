import 'package:flutter/material.dart';

import 'material_handovers_page.dart';

class StoresPage extends StatelessWidget {
  const StoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stores')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF7ED), Color(0xFFF8FAFC)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).padding.bottom + 28,
          ),
          children: [
            const _StoresHeroCard(),
            const SizedBox(height: 18),
            const Text(
              'Stores Services',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            _StoreServiceCard(
              title: 'Material Transfer Handover',
              subtitle: 'Confirm pickup, delivery, and return unused material.',
              icon: Icons.inventory_2_outlined,
              enabled: true,
              gradient: const [Color(0xFF92400E), Color(0xFFF97316)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MaterialHandoversPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            const _StoreServiceCard(
              title: 'Stock Balance',
              subtitle: 'View item availability by warehouse.',
              icon: Icons.warehouse_outlined,
              enabled: false,
            ),
            const SizedBox(height: 12),
            const _StoreServiceCard(
              title: 'Stock Requests',
              subtitle: 'Request materials for projects and operations.',
              icon: Icons.assignment_add,
              enabled: false,
            ),
            const SizedBox(height: 12),
            const _StoreServiceCard(
              title: 'Stock Reports',
              subtitle: 'Review transfers, returns, and consumption reports.',
              icon: Icons.bar_chart_rounded,
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _StoresHeroCard extends StatelessWidget {
  const _StoresHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF431407), Color(0xFFB45309), Color(0xFFF97316)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB45309).withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                child: Icon(
                  Icons.warehouse_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              Spacer(),
              Chip(label: Text('Stores Mode')),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'Stores',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Document material pickup, delivery, and returns with photo evidence.',
            style: TextStyle(color: Colors.white70, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _StoreServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final List<Color>? gradient;
  final VoidCallback? onTap;

  const _StoreServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.62,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: enabled ? LinearGradient(colors: gradient!) : null,
                  color: enabled ? null : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: enabled ? Colors.white : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (!enabled) const _SoonBadge(),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        height: 1.28,
                      ),
                    ),
                  ],
                ),
              ),
              if (enabled)
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoonBadge extends StatelessWidget {
  const _SoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Coming Soon',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}
