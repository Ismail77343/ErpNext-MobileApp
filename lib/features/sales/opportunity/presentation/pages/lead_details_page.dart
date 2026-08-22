import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../domain/entities/opportunity_activity.dart';
import '../../domain/entities/opportunity_follow_up.dart';
import '../providers/opportunity_details_provider.dart';
import 'opportunity_form_page.dart';

class OpportunityDetailsPage extends StatefulWidget {
  final String opportunityName;

  const OpportunityDetailsPage({super.key, required this.opportunityName});

  @override
  State<OpportunityDetailsPage> createState() => _OpportunityDetailsPageState();
}

class _OpportunityDetailsPageState extends State<OpportunityDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OpportunityDetailsProvider>().load(widget.opportunityName);
    });
  }

  Future<void> _openEditForm() async {
    final provider = context.read<OpportunityDetailsProvider>();
    final navigator = Navigator.of(context);
    final details = provider.details;
    if (details == null) return;

    final changed = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (_) => OpportunityFormPage(
          opportunityName: widget.opportunityName,
          initialData: details.data,
        ),
      ),
    );

    if (changed == true && mounted) {
      await provider.load(widget.opportunityName);
      if (!mounted) return;
      navigator.pop(true);
    }
  }

  Future<void> _openAddFollowUpDialog() async {
    final provider = context.read<OpportunityDetailsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _AddOpportunityFollowUpDialog(
        opportunityName: widget.opportunityName,
      ),
    );

    if (saved == true && mounted) {
      await provider.load(widget.opportunityName);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Follow up added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OpportunityDetailsProvider>();
    final details = provider.details;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.opportunityName),
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
          ? const Center(child: Text('No opportunity details found'))
          : RefreshIndicator(
              onRefresh: () => provider.load(widget.opportunityName),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  _OpportunitySummaryCard(data: details.data),
                  const SizedBox(height: 16),
                  _QuickActionsCard(data: details.data),
                  const SizedBox(height: 16),
                  _SectionTitle(
                    title: 'Opportunity Data',
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

class _AddOpportunityFollowUpDialog extends StatefulWidget {
  const _AddOpportunityFollowUpDialog({required this.opportunityName});

  final String opportunityName;

  @override
  State<_AddOpportunityFollowUpDialog> createState() =>
      _AddOpportunityFollowUpDialogState();
}

class _AddOpportunityFollowUpDialogState
    extends State<_AddOpportunityFollowUpDialog> {
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
    final provider = context.read<OpportunityDetailsProvider>();

    try {
      await provider.addFollowUp(
        opportunityName: widget.opportunityName,
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

class _OpportunitySummaryCard extends StatelessWidget {
  const _OpportunitySummaryCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = _readDisplayName(data);
    final company = data['company_name']?.toString() ?? '';
    final status = data['status']?.toString() ?? 'Opportunity';
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

  final OpportunityFollowUp followUp;

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

  final OpportunityActivity activity;

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
  return 'Opportunity';
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
