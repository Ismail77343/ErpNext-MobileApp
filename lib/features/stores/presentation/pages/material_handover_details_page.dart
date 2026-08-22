import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/material_handover_details.dart';
import '../../domain/entities/material_handover_item.dart';
import '../providers/material_handovers_provider.dart';
import 'material_return_page.dart';

class MaterialHandoverDetailsPage extends StatefulWidget {
  const MaterialHandoverDetailsPage({super.key, required this.handoverName});

  final String handoverName;

  @override
  State<MaterialHandoverDetailsPage> createState() =>
      _MaterialHandoverDetailsPageState();
}

class _MaterialHandoverDetailsPageState
    extends State<MaterialHandoverDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MaterialHandoversProvider>().loadDetails(
        widget.handoverName,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MaterialHandoversProvider>();
    final details = provider.details;
    return Scaffold(
      appBar: AppBar(title: Text(widget.handoverName)),
      body: provider.isLoading && details == null
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null && details == null
          ? _ErrorState(
              message: provider.error!,
              onRetry: () => provider.loadDetails(widget.handoverName),
            )
          : details == null
          ? const Center(child: Text('No handover details found'))
          : RefreshIndicator(
              onRefresh: () => provider.loadDetails(widget.handoverName),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  _Header(details: details),
                  const SizedBox(height: 12),
                  _Actions(provider: provider, details: details),
                  const SizedBox(height: 18),
                  const Text(
                    'Items',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  if (details.items.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No items found'),
                      ),
                    )
                  else
                    ...details.items.map(_ItemCard.new),
                ],
              ),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.details});

  final MaterialHandoverDetails details;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    details.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _Badge(label: details.status),
              ],
            ),
            const SizedBox(height: 10),
            if (details.stockEntry.isNotEmpty)
              Text('Stock Entry: ${details.stockEntry}'),
            if (details.company.isNotEmpty) Text('Company: ${details.company}'),
            if (details.fromWarehouse.isNotEmpty)
              Text('From: ${details.fromWarehouse}'),
            if (details.toWarehouse.isNotEmpty)
              Text('To: ${details.toWarehouse}'),
            if (details.receiverUser.isNotEmpty)
              Text('Receiver: ${details.receiverUser}'),
            if (details.project.isNotEmpty) Text('Project: ${details.project}'),
            if (details.task.isNotEmpty) Text('Task: ${details.task}'),
            if (details.lastReturnStockEntry.isNotEmpty)
              Text('Last Return Request: ${details.lastReturnStockEntry}'),
            if (details.notes.isNotEmpty) ...[
              const Divider(height: 24),
              Text(details.notes),
            ],
          ],
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.provider, required this.details});

  final MaterialHandoversProvider provider;
  final MaterialHandoverDetails details;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      if (details.canConfirmPickup)
        FilledButton.icon(
          onPressed: provider.isProcessing
              ? null
              : () => _confirm(context, provider, 'Confirm Pickup'),
          icon: const Icon(Icons.local_shipping_outlined),
          label: const Text('Confirm Pickup'),
        ),
      if (details.canConfirmDelivery)
        FilledButton.icon(
          onPressed: provider.isProcessing
              ? null
              : () => _confirm(context, provider, 'Confirm Delivery'),
          icon: const Icon(Icons.inventory_rounded),
          label: const Text('Confirm Delivery'),
        ),
      if (details.canCreateReturn)
        OutlinedButton.icon(
          onPressed: provider.isProcessing
              ? null
              : () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MaterialReturnPage(handoverName: details.name),
                    ),
                  );
                  if (context.mounted) {
                    provider.loadDetails(details.name);
                  }
                },
          icon: const Icon(Icons.assignment_return_rounded),
          label: const Text('Create Return Request'),
        ),
    ];

    if (actions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Text('No mobile actions are available for this handover.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(spacing: 10, runSpacing: 10, children: actions),
      ),
    );
  }

  Future<void> _confirm(
    BuildContext context,
    MaterialHandoversProvider provider,
    String title,
  ) async {
    final notes = await _notesDialog(context, title);
    if (notes == null || !context.mounted) return;
    final success = title.contains('Pickup')
        ? await provider.confirmPickup(notes)
        : await provider.confirmDelivery(notes);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '$title completed successfully.'
              : provider.error ?? '$title failed.',
        ),
      ),
    );
  }

  Future<String?> _notesDialog(BuildContext context, String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'Add handover notes...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Continue to Camera'),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard(this.item);

  final MaterialHandoverItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.itemName.isEmpty ? item.itemCode : item.itemName,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            if (item.itemCode.isNotEmpty) Text('Code: ${item.itemCode}'),
            Text('Qty: ${_qty(item.qty)} ${item.uom}'),
            if (item.returnedQty > 0)
              Text('Returned: ${_qty(item.returnedQty)} ${item.uom}'),
            if (item.remainingQty > 0)
              Text('Remaining: ${_qty(item.remainingQty)} ${item.uom}'),
            if (item.sourceWarehouse.isNotEmpty)
              Text('Source: ${item.sourceWarehouse}'),
            if (item.targetWarehouse.isNotEmpty)
              Text('Target: ${item.targetWarehouse}'),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDD5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.isEmpty ? '-' : label,
        style: const TextStyle(
          color: Color(0xFF9A3412),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 44,
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
    );
  }
}

String _qty(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}
