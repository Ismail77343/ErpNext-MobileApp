import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task_follow_up_details.dart';
import '../../domain/entities/task_follow_up_update.dart';
import '../providers/task_follow_up_details_provider.dart';

class TaskFollowUpDetailsPage extends StatefulWidget {
  final String taskName;
  final bool assignedToMe;

  const TaskFollowUpDetailsPage({
    super.key,
    required this.taskName,
    required this.assignedToMe,
  });

  @override
  State<TaskFollowUpDetailsPage> createState() =>
      _TaskFollowUpDetailsPageState();
}

class _TaskFollowUpDetailsPageState extends State<TaskFollowUpDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TaskFollowUpDetailsProvider>().load(
        widget.taskName,
        markRead: widget.assignedToMe,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskFollowUpDetailsProvider>();
    final details = provider.details;

    return Scaffold(
      appBar: AppBar(title: Text(widget.taskName)),
      floatingActionButton: details == null
          ? null
          : FloatingActionButton.extended(
              onPressed: provider.isSubmitting
                  ? null
                  : () => _showUpdateSheet(
                      context,
                      provider,
                      details,
                      assignedToMe: widget.assignedToMe,
                    ),
              icon: const Icon(Icons.add_comment_rounded),
              label: Text(
                widget.assignedToMe ? 'Add Update' : 'Manager Review',
              ),
            ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? _ErrorState(
              message: provider.error!,
              onRetry: () {
                provider.load(widget.taskName, markRead: widget.assignedToMe);
              },
            )
          : details == null
          ? const Center(child: Text('No details found'))
          : RefreshIndicator(
              onRefresh: () => provider.load(widget.taskName),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  _DetailsHeader(details: details),
                  const SizedBox(height: 14),
                  if (details.canClose)
                    _CloseActions(provider: provider, details: details),
                  const SizedBox(height: 14),
                  const Text(
                    'Updates',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  if (details.updates.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text('No updates yet'),
                      ),
                    )
                  else
                    ...details.updates.map(_UpdateCard.new),
                ],
              ),
            ),
    );
  }

  Future<void> _showUpdateSheet(
    BuildContext context,
    TaskFollowUpDetailsProvider provider,
    TaskFollowUpDetails details, {
    required bool assignedToMe,
  }) async {
    final noteController = TextEditingController();
    final progressController = TextEditingController(
      text: details.progress.toString(),
    );
    String status = details.status.isEmpty ? 'Working' : details.status;
    String? attachmentPath;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignedToMe ? 'Add Update' : 'Manager Review',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        (assignedToMe
                                ? const [
                                    'Open',
                                    'Working',
                                    'Blocked',
                                    'Overdue',
                                  ]
                                : const [
                                    'Open',
                                    'Working',
                                    'Blocked',
                                    'Overdue',
                                    'Completed',
                                    'Cancelled',
                                  ])
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) setSheetState(() => status = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: progressController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Progress %',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles();
                      final path = result?.files.single.path;
                      if (path != null) {
                        setSheetState(() => attachmentPath = path);
                      }
                    },
                    icon: const Icon(Icons.attach_file_rounded),
                    label: Text(
                      attachmentPath == null ? 'Attach File' : 'File selected',
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(sheetContext, true),
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Submit Update'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (ok != true || !context.mounted) return;
    final success = await provider.addUpdate(
      note: noteController.text.trim(),
      progress:
          int.tryParse(progressController.text.trim()) ?? details.progress,
      status: status,
      attachmentPath: attachmentPath,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Update added successfully'
                : provider.error ?? 'Update failed',
          ),
        ),
      );
    }
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({required this.details});

  final TaskFollowUpDetails details;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              details.subject.isEmpty ? details.name : details.subject,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text('Code: ${details.name}'),
            Text('Status: ${details.status.isEmpty ? 'Open' : details.status}'),
            Text(
              'Priority: ${details.priority.isEmpty ? '-' : details.priority}',
            ),
            if (details.project.isNotEmpty) Text('Project: ${details.project}'),
            if (details.task.isNotEmpty) Text('Task: ${details.task}'),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: details.progress.clamp(0, 100) / 100,
              minHeight: 10,
              borderRadius: BorderRadius.circular(99),
            ),
            const SizedBox(height: 8),
            Text('${details.progress.clamp(0, 100)}% complete'),
            if (details.details.isNotEmpty) ...[
              const Divider(height: 24),
              Text(details.details),
            ],
          ],
        ),
      ),
    );
  }
}

class _CloseActions extends StatelessWidget {
  const _CloseActions({required this.provider, required this.details});

  final TaskFollowUpDetailsProvider provider;
  final TaskFollowUpDetails details;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: provider.isSubmitting
                  ? null
                  : () => _confirm(context, 'Completed'),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Complete'),
            ),
            OutlinedButton.icon(
              onPressed: provider.isSubmitting
                  ? null
                  : () => _confirm(context, 'Cancelled'),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, String status) async {
    final noteController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$status task?'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(labelText: 'Note'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final success = await provider.closeTask(
      status: status,
      note: noteController.text.trim(),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Task updated successfully'
                : provider.error ?? 'Action failed',
          ),
        ),
      );
    }
  }
}

class _UpdateCard extends StatelessWidget {
  const _UpdateCard(this.update);

  final TaskFollowUpUpdate update;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    update.status.isEmpty ? 'Update' : update.status,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Text('${update.progress}%'),
              ],
            ),
            if (update.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(update.note),
            ],
            if (update.attachment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Attachment: ${update.attachment}'),
            ],
            const SizedBox(height: 6),
            Text(
              '${update.owner} • ${update.creation}',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
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
              size: 44,
              color: Colors.red,
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
