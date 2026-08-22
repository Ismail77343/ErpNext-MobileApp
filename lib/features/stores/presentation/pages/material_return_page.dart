import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/material_handover_item.dart';
import '../../domain/entities/material_return_line.dart';
import '../providers/material_handovers_provider.dart';

class MaterialReturnPage extends StatefulWidget {
  const MaterialReturnPage({super.key, required this.handoverName});

  final String handoverName;

  @override
  State<MaterialReturnPage> createState() => _MaterialReturnPageState();
}

class _MaterialReturnPageState extends State<MaterialReturnPage> {
  final _notesController = TextEditingController();
  final Map<String, TextEditingController> _qtyControllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MaterialHandoversProvider>().loadReturnOptions(
        widget.handoverName,
      );
    });
  }

  @override
  void dispose() {
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MaterialHandoversProvider>();
    final options = provider.returnOptions;
    return Scaffold(
      appBar: AppBar(title: const Text('Create Return Request')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null && options.isEmpty
          ? _State(
              message: provider.error!,
              onRetry: () => provider.loadReturnOptions(widget.handoverName),
            )
          : options.isEmpty
          ? _State(
              message: 'No returnable items are available.',
              onRetry: () => provider.loadReturnOptions(widget.handoverName),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                const Text(
                  'Select quantities to return',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                ...options.map(_returnItemEditor),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Return Notes',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (provider.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: provider.isProcessing || options.isEmpty
                ? null
                : _submit,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(
              provider.isProcessing
                  ? 'Creating...'
                  : 'Capture Photo & Create Request',
            ),
          ),
        ),
      ),
    );
  }

  Widget _returnItemEditor(MaterialHandoverItem item) {
    final controller = _qtyControllers.putIfAbsent(
      item.stockEntryDetail,
      () => TextEditingController(),
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.itemName.isEmpty ? item.itemCode : item.itemName,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text('Remaining: ${_qty(item.remainingQty)} ${item.uom}'),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Return Qty',
                helperText: 'Max ${_qty(item.remainingQty)}',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final provider = context.read<MaterialHandoversProvider>();
    final lines = <MaterialReturnLine>[];
    for (final item in provider.returnOptions) {
      final value =
          double.tryParse(
            _qtyControllers[item.stockEntryDetail]?.text.trim() ?? '',
          ) ??
          0;
      if (value <= 0) continue;
      if (value > item.remainingQty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item.itemCode} return qty cannot exceed ${_qty(item.remainingQty)}.',
            ),
          ),
        );
        return;
      }
      lines.add(
        MaterialReturnLine(stockEntryDetail: item.stockEntryDetail, qty: value),
      );
    }

    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one return qty.')),
      );
      return;
    }

    final ok = await provider.createReturn(
      items: lines,
      notes: _notesController.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? provider.lastReturnDraft?.isNotEmpty == true
                    ? 'Return request created: ${provider.lastReturnDraft}'
                    : 'Return request created successfully.'
              : provider.error ?? 'Return request failed.',
        ),
      ),
    );
    if (ok) Navigator.pop(context, true);
  }
}

class _State extends StatelessWidget {
  const _State({required this.message, required this.onRetry});

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
            const Icon(Icons.assignment_return_outlined, size: 44),
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
