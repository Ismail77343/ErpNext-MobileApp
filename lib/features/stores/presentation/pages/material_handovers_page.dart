import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/material_handover.dart';
import '../providers/material_handovers_provider.dart';
import 'material_handover_details_page.dart';

class MaterialHandoversPage extends StatefulWidget {
  const MaterialHandoversPage({super.key});

  @override
  State<MaterialHandoversPage> createState() => _MaterialHandoversPageState();
}

class _MaterialHandoversPageState extends State<MaterialHandoversPage> {
  final _scrollController = ScrollController();
  static const _statuses = [
    'All',
    'Pending Pickup',
    'Picked Up',
    'Delivered',
    'Return Draft Created',
    'Closed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final threshold = _scrollController.position.maxScrollExtent - 180;
      if (_scrollController.position.pixels >= threshold) {
        context.read<MaterialHandoversProvider>().fetch();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MaterialHandoversProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MaterialHandoversProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Material Handovers')),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transfer Handovers',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 46,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _statuses.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final status = _statuses[index];
                          return ChoiceChip(
                            label: Text(_displayStatus(status)),
                            selected: provider.statusFilter == status,
                            onSelected: (_) => provider.setStatusFilter(status),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (provider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.error != null)
              SliverFillRemaining(
                child: _StateCard(
                  message: provider.error!,
                  isError: true,
                  onRetry: provider.refresh,
                ),
              )
            else if (provider.handovers.isEmpty)
              SliverFillRemaining(
                child: _StateCard(
                  message: 'No material transfer handovers found.',
                  onRetry: provider.refresh,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                sliver: SliverList.builder(
                  itemCount:
                      provider.handovers.length +
                      (provider.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= provider.handovers.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final item = provider.handovers[index];
                    return _HandoverCard(
                      item: item,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MaterialHandoverDetailsPage(
                              handoverName: item.name,
                            ),
                          ),
                        );
                        if (context.mounted) {
                          context.read<MaterialHandoversProvider>().refresh();
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HandoverCard extends StatelessWidget {
  const _HandoverCard({required this.item, required this.onTap});

  final MaterialHandover item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);
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
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _Badge(label: _displayStatus(item.status), color: color),
                ],
              ),
              const SizedBox(height: 8),
              if (item.stockEntry.isNotEmpty)
                Text('Stock Entry: ${item.stockEntry}'),
              if (item.fromWarehouse.isNotEmpty)
                Text('From: ${item.fromWarehouse}'),
              if (item.toWarehouse.isNotEmpty) Text('To: ${item.toWarehouse}'),
              if (item.receiverUser.isNotEmpty)
                Text('Receiver: ${item.receiverUser}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.isEmpty ? '-' : label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.message,
    required this.onRetry,
    this.isError = false,
  });

  final String message;
  final VoidCallback onRetry;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isError ? Icons.error_outline_rounded : Icons.inventory_2,
                  size: 42,
                  color: isError ? Colors.red : const Color(0xFFB45309),
                ),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending pickup':
      return const Color(0xFFD97706);
    case 'picked up':
      return const Color(0xFF0369A1);
    case 'delivered':
      return const Color(0xFF16A34A);
    case 'return draft created':
      return const Color(0xFF7C3AED);
    case 'closed':
      return const Color(0xFF0F766E);
    case 'cancelled':
      return const Color(0xFF64748B);
    default:
      return const Color(0xFFB45309);
  }
}

String _displayStatus(String status) {
  if (status.toLowerCase() == 'return draft created') {
    return 'Return Request Created';
  }
  return status;
}
