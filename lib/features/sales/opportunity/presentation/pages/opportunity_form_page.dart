import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/widgets/action_loading_overlay.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../domain/entities/opportunity_field.dart';
import '../../domain/entities/opportunity_option_item.dart';
import '../providers/opportunity_form_provider.dart';

class OpportunityFormPage extends StatefulWidget {
  final String? opportunityName;
  final Map<String, dynamic>? initialData;

  const OpportunityFormPage({
    super.key,
    this.opportunityName,
    this.initialData,
  });

  @override
  State<OpportunityFormPage> createState() => _OpportunityFormPageState();
}

class _OpportunityFormPageState extends State<OpportunityFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OpportunityFormProvider>().initialize(
        opportunityName: widget.opportunityName,
        initialData: widget.initialData,
      );
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncControllers(List<OpportunityField> fields) {
    for (final field in fields) {
      final controller = _controllers.putIfAbsent(
        field.key,
        () => TextEditingController(text: field.value),
      );
      if (controller.text != field.value) {
        controller.value = TextEditingValue(
          text: field.value,
          selection: TextSelection.collapsed(offset: field.value.length),
        );
      }
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<OpportunityFormProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final success = await provider.submit();
    if (!mounted) return;

    if (!success) {
      messenger.showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Could not save opportunity')),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(content: Text(provider.successMessage ?? 'Saved')),
    );
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OpportunityFormProvider>();
    final fields = provider.fields;
    _syncControllers(fields);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.opportunityName == null
              ? 'Create Opportunity'
              : 'Edit Opportunity',
        ),
        actions: [
          IconButton(
            onPressed: provider.isLoading
                ? null
                : provider.refreshRequiredFields,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ActionLoadingOverlay(
        isLoading: provider.isSubmitting,
        message: widget.opportunityName == null
            ? 'Creating opportunity...'
            : 'Updating opportunity...',
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFEDD5), Color(0xFFFFF7ED)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.opportunityName == null
                          ? 'Dynamic Opportunity Form'
                          : 'Update Opportunity Data',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Form fields come directly from the Opportunity API, including Select, Link, and Dynamic Link fields.',
                    ),
                    if (widget.opportunityName != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Opportunity ID: ${widget.opportunityName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                    if (provider.missingKeys.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Missing: ${provider.missingKeys.join(', ')}',
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (provider.contentPreview.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Content Preview',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        provider.contentPreview,
                        style: const TextStyle(color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'This preview is generated automatically and will be built by the server on save.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ...fields.map(
                (field) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _OpportunityFieldInput(
                    field: field,
                    controller: _controllers[field.key]!,
                    onChanged: (value) {
                      AppLogger.sales('opportunity form changed ${field.key}');
                      provider.updateValue(field.key, value);
                    },
                  ),
                ),
              ),
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              FilledButton.icon(
                onPressed: provider.isSubmitting
                    ? null
                    : () => _submit(context),
                icon: provider.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  provider.isSubmitting
                      ? 'Saving...'
                      : widget.opportunityName == null
                      ? 'Create Opportunity'
                      : 'Update Opportunity',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpportunityFieldInput extends StatelessWidget {
  const _OpportunityFieldInput({
    required this.field,
    required this.controller,
    required this.onChanged,
  });

  final OpportunityField field;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    if (field.isSelectable) {
      return _SelectableField(
        field: field,
        controller: controller,
        onChanged: onChanged,
      );
    }

    final keyboardType = switch (field.type) {
      OpportunityFieldType.email => TextInputType.emailAddress,
      OpportunityFieldType.phone => TextInputType.phone,
      OpportunityFieldType.number => TextInputType.number,
      OpportunityFieldType.multiline => TextInputType.multiline,
      OpportunityFieldType.date => TextInputType.datetime,
      _ => TextInputType.text,
    };

    return TextFormField(
      controller: controller,
      readOnly: field.readOnly,
      keyboardType: keyboardType,
      maxLines: field.type == OpportunityFieldType.multiline ? 4 : 1,
      decoration: InputDecoration(
        labelText: field.required ? '${field.label} *' : field.label,
        alignLabelWithHint: field.type == OpportunityFieldType.multiline,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      validator: (value) {
        if (field.required && (value == null || value.trim().isEmpty)) {
          return '${field.label} is required';
        }
        return null;
      },
      onChanged: field.readOnly ? null : onChanged,
    );
  }
}

class _SelectableField extends StatelessWidget {
  const _SelectableField({
    required this.field,
    required this.controller,
    required this.onChanged,
  });

  final OpportunityField field;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<OpportunityOptionItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _OptionsPickerSheet(field: field),
    );

    if (selected == null) return;
    controller.text = selected.value;
    onChanged(selected.value);
  }

  @override
  Widget build(BuildContext context) {
    final helper = switch (field.type) {
      OpportunityFieldType.dynamicLink =>
        'Tap to search and choose from ${field.linkDoctype ?? 'linked list'}',
      OpportunityFieldType.link =>
        'Tap to search and choose from ${field.linkDoctype ?? 'list'}',
      _ => 'Tap to choose from list',
    };

    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: !field.readOnly,
      decoration: InputDecoration(
        labelText: field.required ? '${field.label} *' : field.label,
        helperText: helper,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!field.readOnly && controller.text.isNotEmpty)
              IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close_rounded),
              ),
            const Icon(Icons.arrow_drop_down_rounded),
            const SizedBox(width: 8),
          ],
        ),
      ),
      validator: (value) {
        if (field.required && (value == null || value.trim().isEmpty)) {
          return '${field.label} is required';
        }
        return null;
      },
      onTap: field.readOnly ? null : () => _openPicker(context),
    );
  }
}

class _OptionsPickerSheet extends StatefulWidget {
  const _OptionsPickerSheet({required this.field});

  final OpportunityField field;

  @override
  State<_OptionsPickerSheet> createState() => _OptionsPickerSheetState();
}

class _OptionsPickerSheetState extends State<_OptionsPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isLoading = true;
  String? _error;
  List<OpportunityOptionItem> _items = [];

  @override
  void initState() {
    super.initState();
    _search();
    _searchController.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), _search);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<OpportunityFormProvider>();
      final items = await provider.searchOptions(
        widget.field,
        query: _searchController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  Text(
                    widget.field.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    autofocus:
                        widget.field.type == OpportunityFieldType.link ||
                        widget.field.type == OpportunityFieldType.dynamicLink,
                    decoration: InputDecoration(
                      hintText:
                          widget.field.type == OpportunityFieldType.link ||
                              widget.field.type ==
                                  OpportunityFieldType.dynamicLink
                          ? 'Search ${widget.field.linkDoctype ?? 'items'}...'
                          : 'Search options...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  : _items.isEmpty
                  ? const Center(child: Text('No results found'))
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return ListTile(
                          title: Text(item.label),
                          subtitle: item.description.isEmpty
                              ? null
                              : Text(item.description),
                          onTap: () => Navigator.pop(context, item),
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
