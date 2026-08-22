import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../opportunity/data/datasources/opportunity_remote_datasource.dart';
import '../../../opportunity/domain/entities/opportunity.dart';
import '../../../opportunity/presentation/pages/opportunity_details_page.dart';
import '../../../opportunity/presentation/pages/opportunity_form_page.dart';
import '../../../opportunity/presentation/widgets/opportunity_scope.dart';
import '../../domain/entities/lead_activity.dart';
import '../../domain/entities/lead_follow_up.dart';
import '../providers/lead_details_provider.dart';
import 'lead_form_page.dart';

class LeadDetailsPage extends StatefulWidget {
  final String leadName;

  const LeadDetailsPage({super.key, required this.leadName});

  @override
  State<LeadDetailsPage> createState() => _LeadDetailsPageState();
}

class _LeadDetailsPageState extends State<LeadDetailsPage> {
  late Future<List<Opportunity>> _leadOpportunitiesFuture;

  @override
  void initState() {
    super.initState();
    _leadOpportunitiesFuture = _loadLeadOpportunities();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LeadDetailsProvider>().load(widget.leadName);
    });
  }

  Future<List<Opportunity>> _loadLeadOpportunities() async {
    final items = await OpportunityRemoteDataSource().getOpportunities(
      start: 0,
      limit: 50,
      search: widget.leadName,
    );
    return items.where((item) => item.partyName == widget.leadName).toList();
  }

  void _refreshLeadOpportunities() {
    setState(() {
      _leadOpportunitiesFuture = _loadLeadOpportunities();
    });
  }

  Future<void> _openEditForm() async {
    final provider = context.read<LeadDetailsProvider>();
    final navigator = Navigator.of(context);
    final details = provider.details;
    if (details == null) return;

    final changed = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            LeadFormPage(leadName: widget.leadName, initialData: details.data),
      ),
    );

    if (changed == true && mounted) {
      await provider.load(widget.leadName);
      if (!mounted) return;
      navigator.pop(true);
    }
  }

  Future<void> _openAddFollowUpDialog() async {
    final provider = context.read<LeadDetailsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _AddLeadFollowUpDialog(leadName: widget.leadName),
    );

    if (saved == true && mounted) {
      await provider.load(widget.leadName);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Follow up added successfully')),
      );
    }
  }

  Future<void> _openCreateOpportunity() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OpportunityScope(
          child: OpportunityFormPage(
            initialData: {
              'opportunity_from': 'Lead',
              'party_name': widget.leadName,
            },
          ),
        ),
      ),
    );

    if (created == true && mounted) {
      _refreshLeadOpportunities();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opportunity created for this lead')),
      );
    }
  }

  Future<void> _openOpportunity(String opportunityName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OpportunityScope(
          child: OpportunityDetailsPage(opportunityName: opportunityName),
        ),
      ),
    );
    if (mounted) _refreshLeadOpportunities();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeadDetailsProvider>();
    final details = provider.details;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.leadName),
        actions: [
          IconButton(
            onPressed: details == null ? null : _openEditForm,
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isLoading ? null : _openAddFollowUpDialog,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Add Follow Up'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          : details == null
          ? const Center(child: Text('No lead details found'))
          : RefreshIndicator(
              onRefresh: () => provider.load(widget.leadName),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  _LeadSummaryCard(data: details.data),
                  const SizedBox(height: 16),
                  _QuickActionsCard(data: details.data),
                  const SizedBox(height: 16),
                  _LeadOpportunitiesCard(
                    future: _leadOpportunitiesFuture,
                    onRefresh: _refreshLeadOpportunities,
                    onCreate: _openCreateOpportunity,
                    onOpen: _openOpportunity,
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(
                    title: 'Lead Data',
                    actionLabel: 'Edit',
                    onTap: _openEditForm,
                  ),
                  const SizedBox(height: 8),
                  ...details.data.entries
                      .where((entry) => entry.value != null)
                      .where(
                        (entry) => entry.value.toString().trim().isNotEmpty,
                      )
                      .map(
                        (entry) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(_labelFromKey(entry.key)),
                            subtitle: Text(entry.value.toString()),
                          ),
                        ),
                      ),
                  const SizedBox(height: 12),
                  _SectionTitle(
                    title: 'Follow Ups',
                    actionLabel: 'Add',
                    onTap: _openAddFollowUpDialog,
                  ),
                  const SizedBox(height: 8),
                  if (details.followUps.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No follow ups available'),
                      ),
                    )
                  else
                    ...details.followUps.map(
                      (item) => _FollowUpCard(followUp: item),
                    ),
                  const SizedBox(height: 12),
                  const _SectionTitle(title: 'Activity Log'),
                  const SizedBox(height: 8),
                  if (details.activityLog.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No activity log available'),
                      ),
                    )
                  else
                    ...details.activityLog.map(
                      (item) => _ActivityCard(activity: item),
                    ),
                ],
              ),
            ),
    );
  }
}

class _AddLeadFollowUpDialog extends StatefulWidget {
  const _AddLeadFollowUpDialog({required this.leadName});

  final String leadName;

  @override
  State<_AddLeadFollowUpDialog> createState() => _AddLeadFollowUpDialogState();
}

class _AddLeadFollowUpDialogState extends State<_AddLeadFollowUpDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _followUpDateController = TextEditingController(
    text: _today(),
  );
  final TextEditingController _expectedDateController = TextEditingController(
    text: _today(addDays: 2),
  );
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _attachmentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String? _attachmentPath;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _followUpDateController.dispose();
    _expectedDateController.dispose();
    _detailsController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  Future<void> _pickFromFiles() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.single.path == null || !mounted) return;
    setState(() {
      _attachmentPath = result.files.single.path!;
      _attachmentController.text = result.files.single.name;
    });
  }

  Future<void> _pickFromCamera() async {
    final file = await _imagePicker.pickImage(source: ImageSource.camera);
    if (file == null || !mounted) return;
    setState(() {
      _attachmentPath = file.path;
      _attachmentController.text = file.name;
    });
  }

  Future<void> _pickFromGallery() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    setState(() {
      _attachmentPath = file.path;
      _attachmentController.text = file.name;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<LeadDetailsProvider>();

    try {
      await provider.addFollowUp(
        leadName: widget.leadName,
        followUpDate: _followUpDateController.text.trim(),
        expectedResultDate: _expectedDateController.text.trim(),
        details: _detailsController.text.trim(),
        attachmentPath: _attachmentPath,
        attachment: _attachmentPath == null
            ? _attachmentController.text.trim()
            : null,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to add follow up')),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Follow Up'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DateInput(
                label: 'Follow Up Date',
                controller: _followUpDateController,
              ),
              const SizedBox(height: 10),
              _DateInput(
                label: 'Expected Result Date',
                controller: _expectedDateController,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _detailsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Details',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Details are required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _attachmentController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Attachment',
                  hintText: 'Pick file, camera, or gallery',
                  border: const OutlineInputBorder(),
                  suffixIcon: _attachmentController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              _attachmentPath = null;
                              _attachmentController.clear();
                            });
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickFromFiles,
                    icon: const Icon(Icons.attach_file_rounded),
                    label: const Text('File'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Gallery'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickFromCamera,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Camera'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _LeadSummaryCard extends StatelessWidget {
  const _LeadSummaryCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = _readDisplayName(data);
    final company = data['company_name']?.toString() ?? '';
    final status = data['status']?.toString() ?? 'Lead';
    final source = data['source']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9A3412), Color(0xFFEA580C)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (company.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(company, style: const TextStyle(color: Colors.white70)),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SummaryChip(label: status),
              if (source.isNotEmpty) _SummaryChip(label: source),
              if ((data['email_id']?.toString() ?? '').isNotEmpty)
                _SummaryChip(label: data['email_id'].toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final mobile = data['mobile_no']?.toString() ?? '';
    final whatsapp = data['whatsapp_no']?.toString() ?? mobile;
    final email = data['email_id']?.toString() ?? '';

    if (mobile.isEmpty && whatsapp.isEmpty && email.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (mobile.isNotEmpty)
              _ActionButton(
                label: 'Call',
                icon: Icons.call_rounded,
                color: const Color(0xFF0F766E),
                onTap: () => _launchUri(Uri.parse('tel:$mobile')),
              ),
            if (mobile.isNotEmpty)
              _ActionButton(
                label: 'SMS',
                icon: Icons.sms_rounded,
                color: const Color(0xFF0369A1),
                onTap: () => _launchUri(Uri.parse('sms:$mobile')),
              ),
            if (whatsapp.isNotEmpty)
              _ActionButton(
                label: 'WhatsApp',
                icon: Icons.chat_rounded,
                color: const Color(0xFF15803D),
                onTap: () => _launchUri(
                  Uri.parse('https://wa.me/${_normalizePhone(whatsapp)}'),
                ),
              ),
            if (email.isNotEmpty)
              _ActionButton(
                label: 'Email',
                icon: Icons.email_rounded,
                color: const Color(0xFF7C3AED),
                onTap: () => _launchUri(Uri.parse('mailto:$email')),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUri(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9+]'), '');
  }
}

class _LeadOpportunitiesCard extends StatelessWidget {
  const _LeadOpportunitiesCard({
    required this.future,
    required this.onRefresh,
    required this.onCreate,
    required this.onOpen,
  });

  final Future<List<Opportunity>> future;
  final VoidCallback onRefresh;
  final VoidCallback onCreate;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Opportunities',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh opportunities',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                ),
                FilledButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Opportunity>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return _InlineState(
                    icon: Icons.error_outline_rounded,
                    message: snapshot.error.toString(),
                    actionLabel: 'Retry',
                    onAction: onRefresh,
                  );
                }

                final opportunities = snapshot.data ?? const <Opportunity>[];
                if (opportunities.isEmpty) {
                  return _InlineState(
                    icon: Icons.trending_up_rounded,
                    message: 'No opportunities linked to this lead yet.',
                    actionLabel: 'Create Opportunity',
                    onAction: onCreate,
                  );
                }

                return Column(
                  children: [
                    ...opportunities
                        .take(5)
                        .map(
                          (item) => _LeadOpportunityTile(
                            opportunity: item,
                            onTap: () => onOpen(item.name),
                          ),
                        ),
                    if (opportunities.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '+${opportunities.length - 5} more linked opportunities',
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadOpportunityTile extends StatelessWidget {
  const _LeadOpportunityTile({required this.opportunity, required this.onTap});

  final Opportunity opportunity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = opportunity.firstName.trim().isEmpty
        ? opportunity.name
        : opportunity.firstName;
    final subtitleParts = [
      if (opportunity.content.trim().isNotEmpty) opportunity.content,
      if (opportunity.nextFollowUpDate.trim().isNotEmpty)
        'Next Follow Up: ${_displayDate(opportunity.nextFollowUpDate)}',
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFFFF3C7),
        child: Icon(Icons.trending_up_rounded, color: Color(0xFFB45309)),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitleParts.isEmpty ? opportunity.name : subtitleParts.join('\n'),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SmallStatusChip(label: opportunity.status),
          if ((opportunity.workflowState ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            _SmallStatusChip(
              label: opportunity.workflowState!,
              color: const Color(0xFF7C3AED),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

class _InlineState extends StatelessWidget {
  const _InlineState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFB45309)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _SmallStatusChip extends StatelessWidget {
  const _SmallStatusChip({
    required this.label,
    this.color = const Color(0xFF0F766E),
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = label.trim().isEmpty ? '-' : label.trim();
    return Container(
      constraints: const BoxConstraints(maxWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.actionLabel, this.onTap});

  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        if (actionLabel != null && onTap != null)
          TextButton(onPressed: onTap, child: Text(actionLabel!)),
      ],
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  const _FollowUpCard({required this.followUp});

  final LeadFollowUp followUp;

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
              _displayDate(followUp.followUpDate),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (followUp.expectedResultDate.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Expected Result: ${_displayDate(followUp.expectedResultDate)}',
              ),
            ],
            if (followUp.details.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(followUp.details),
            ],
            if (followUp.attachment.isNotEmpty) ...[
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: () => _openAttachment(followUp.attachment),
                icon: const Icon(Icons.attach_file_rounded),
                label: const Text('Open Attachment'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openAttachment(String path) async {
    final uri = path.startsWith('http')
        ? Uri.parse(path)
        : Uri.parse('${ApiConstants.baseUrl}$path');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final LeadActivity activity;

  @override
  Widget build(BuildContext context) {
    final parsed = _parseActivityDescription(activity.description);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFEDD5),
          child: Icon(Icons.history_rounded, color: Color(0xFF9A3412)),
        ),
        title: Text(activity.subject.isEmpty ? 'Activity' : activity.subject),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (parsed.text.isNotEmpty) Text(parsed.text),
            if (parsed.link != null) ...[
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: () => _openAttachment(parsed.link!),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open Attachment'),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '${activity.by.isEmpty ? 'System' : activity.by} • ${_displayDate(activity.date)}',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAttachment(String path) async {
    final uri = path.startsWith('http')
        ? Uri.parse(path)
        : Uri.parse('${ApiConstants.baseUrl}$path');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _DateInput extends StatelessWidget {
  const _DateInput({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today_rounded),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return '$label is required';
        return null;
      },
      onTap: () async {
        final initial = DateTime.tryParse(controller.text) ?? DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked == null) return;
        final y = picked.year.toString().padLeft(4, '0');
        final m = picked.month.toString().padLeft(2, '0');
        final d = picked.day.toString().padLeft(2, '0');
        controller.text = '$y-$m-$d';
      },
    );
  }
}

String _today({int addDays = 0}) {
  final now = DateTime.now().add(Duration(days: addDays));
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _labelFromKey(String key) {
  const customLabels = {
    'email_id': 'Email',
    'mobile_no': 'Mobile',
    'whatsapp_no': 'WhatsApp',
    'mobile_api_last_update_date': 'Last Update Date',
    'mobile_api_next_follow_up_date': 'Next Follow Up Date',
    'mobile_api_last_follow_up_report': 'Last Follow Up Report',
  };
  if (customLabels.containsKey(key)) return customLabels[key]!;

  return key
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _displayDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value.isEmpty ? '-' : value;
  final y = parsed.year.toString().padLeft(4, '0');
  final m = parsed.month.toString().padLeft(2, '0');
  final d = parsed.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _readDisplayName(Map<String, dynamic> data) {
  final values = [
    data['display_name'],
    data['first_name'],
    data['company_name'],
    data['id'],
  ];

  for (final value in values) {
    final text = value?.toString() ?? '';
    if (text.trim().isNotEmpty) return text;
  }
  return 'Lead';
}

_ParsedActivityDescription _parseActivityDescription(String raw) {
  if (raw.trim().isEmpty) {
    return const _ParsedActivityDescription(text: '');
  }

  final anchor = RegExp(
    r'<a\s+href="([^"]+)"[^>]*>([^<]+)</a>',
    caseSensitive: false,
  ).firstMatch(raw);

  if (anchor != null) {
    final href = anchor.group(1) ?? '';
    final label = anchor.group(2) ?? '';
    final prefix = raw
        .substring(0, anchor.start)
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .trim();
    final suffix = raw
        .substring(anchor.end)
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .trim();
    final textParts = [
      if (prefix.isNotEmpty) prefix,
      if (label.isNotEmpty) label,
      if (suffix.isNotEmpty) suffix,
    ];

    return _ParsedActivityDescription(
      text: textParts.join(' ').trim(),
      link: href.isEmpty ? null : href,
    );
  }

  return _ParsedActivityDescription(
    text: raw.replaceAll(RegExp(r'<[^>]+>'), '').trim(),
  );
}

class _ParsedActivityDescription {
  final String text;
  final String? link;

  const _ParsedActivityDescription({required this.text, this.link});
}
