import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../lead/presentation/pages/leads_page.dart';
import '../../opportunity/presentation/pages/opportunities_page.dart';
import '../../opportunity/presentation/widgets/opportunity_scope.dart';
import '../../quotation/presentation/pages/quotations_page.dart';
import '../../quotation/presentation/widgets/quotation_scope.dart';

class SalesPage extends StatelessWidget {
  final bool embedded;

  const SalesPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
        children: [
          _SalesCard(
            title: l10n.salesLeads,
            subtitle: l10n.salesLeadsSubtitle,
            icon: Icons.person_add_alt_1_rounded,
            color: Color(0xFFFFEDD5),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeadsPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _SalesCard(
            title: l10n.salesOpportunities,
            subtitle: l10n.salesOpportunitiesSubtitle,
            icon: Icons.trending_up_rounded,
            color: Color(0xFFFFF3C7),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const OpportunityScope(child: OpportunitiesPage()),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _SalesCard(
            title: l10n.salesQuotations,
            subtitle: l10n.salesQuotationsSubtitle,
            icon: Icons.request_quote_rounded,
            color: Color(0xFFE0F2FE),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const QuotationScope(child: QuotationsPage()),
                ),
              );
            },
          ),
        ],
      ),
    );

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.salesTitle)),
      body: body,
    );
  }
}

class _SalesCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SalesCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(icon, color: const Color(0xFF7C2D12)),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ),
      ),
    );
  }
}
