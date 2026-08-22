import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/link_option.dart';
import '../providers/task_follow_up_form_provider.dart';

class CreateTaskFollowUpPage extends StatefulWidget {
  const CreateTaskFollowUpPage({super.key});

  @override
  State<CreateTaskFollowUpPage> createState() => _CreateTaskFollowUpPageState();
}

class _CreateTaskFollowUpPageState extends State<CreateTaskFollowUpPage> {
  final _subjectController = TextEditingController();
  final _detailsController = TextEditingController();
  final _projectController = TextEditingController();
  final _taskController = TextEditingController();
  final _startDateController = TextEditingController();
  final _dueDateController = TextEditingController();
  String _priority = 'Medium';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TaskFollowUpFormProvider>().reset();
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _detailsController.dispose();
    _projectController.dispose();
    _taskController.dispose();
    _startDateController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskFollowUpFormProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Task Follow Up')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _SectionCard(
            title: 'Assignees',
            children: [
              _Chips(
                label: 'Employees',
                values: provider.assignedEmployees,
                onDeleted: provider.removeEmployee,
              ),
              OutlinedButton.icon(
                onPressed: () => _pickAndAdd(
                  context,
                  doctype: 'Employee',
                  title: 'Employee',
                  onSelected: provider.addEmployee,
                ),
                icon: const Icon(Icons.badge_outlined),
                label: const Text('Add Employee'),
              ),
              const SizedBox(height: 8),
              _Chips(
                label: 'Users',
                values: provider.assignedUsers,
                onDeleted: provider.removeUser,
              ),
              OutlinedButton.icon(
                onPressed: () => _pickAndAdd(
                  context,
                  doctype: 'User',
                  title: 'User',
                  onSelected: provider.addUser,
                ),
                icon: const Icon(Icons.person_add_alt_rounded),
                label: const Text('Add User'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Task Details',
            children: [
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _detailsController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Details',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const ['Low', 'Medium', 'High']
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Project Link',
            children: [
              _PickerField(
                controller: _projectController,
                label: 'Project',
                onTap: () => _pickValue(
                  context,
                  doctype: 'Project',
                  title: 'Project',
                  controller: _projectController,
                ),
              ),
              const SizedBox(height: 12),
              _PickerField(
                controller: _taskController,
                label: 'Task',
                onTap: () => _pickValue(
                  context,
                  doctype: 'Task',
                  title: 'Task',
                  controller: _taskController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Dates',
            children: [
              _DateField(controller: _startDateController, label: 'Start Date'),
              const SizedBox(height: 12),
              _DateField(controller: _dueDateController, label: 'Due Date'),
            ],
          ),
          if (provider.error != null) ...[
            const SizedBox(height: 12),
            Text(provider.error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: provider.isSubmitting ? null : () => _submit(provider),
            icon: const Icon(Icons.save_rounded),
            label: Text(provider.isSubmitting ? 'Creating...' : 'Create Task'),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(TaskFollowUpFormProvider provider) async {
    final ok = await provider.submit(
      subject: _subjectController.text,
      details: _detailsController.text,
      priority: _priority,
      project: _projectController.text,
      task: _taskController.text,
      startDate: _startDateController.text,
      dueDate: _dueDateController.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Task follow up created' : provider.error ?? 'Create failed',
        ),
      ),
    );
    if (ok) Navigator.pop(context, true);
  }

  Future<void> _pickAndAdd(
    BuildContext context, {
    required String doctype,
    required String title,
    required ValueChanged<String> onSelected,
  }) async {
    final value = await _showLinkPicker(
      context,
      doctype: doctype,
      title: title,
    );
    if (value != null) onSelected(value);
  }

  Future<void> _pickValue(
    BuildContext context, {
    required String doctype,
    required String title,
    required TextEditingController controller,
  }) async {
    final value = await _showLinkPicker(
      context,
      doctype: doctype,
      title: title,
    );
    if (value != null) setState(() => controller.text = value);
  }

  Future<String?> _showLinkPicker(
    BuildContext context, {
    required String doctype,
    required String title,
  }) async {
    final provider = context.read<TaskFollowUpFormProvider>();
    final searchController = TextEditingController();
    var loading = true;
    var error = '';
    var items = <LinkOption>[];
    final allowManualEntry = doctype == 'User';

    Future<void> load(StateSetter setSheetState, [String query = '']) async {
      if (allowManualEntry && query.trim().isEmpty) {
        setSheetState(() {
          loading = false;
          error = '';
          items = [];
        });
        return;
      }
      setSheetState(() {
        loading = true;
        error = '';
      });
      try {
        final result = await provider.search(doctype: doctype, query: query);
        setSheetState(() => items = result);
      } catch (e) {
        setSheetState(() => error = e.toString());
      } finally {
        setSheetState(() => loading = false);
      }
    }

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            if (loading && items.isEmpty && error.isEmpty) {
              Future.microtask(() => load(setSheetState));
            }
            final manualValue = searchController.text.trim();
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.72,
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search $doctype...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (value) => load(setSheetState, value),
                        onChanged: (_) => setSheetState(() {}),
                      ),
                      if (allowManualEntry && manualValue.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.pop(sheetContext, manualValue),
                            icon: const Icon(Icons.alternate_email_rounded),
                            label: Text('Use "$manualValue"'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Expanded(
                        child: loading
                            ? const Center(child: CircularProgressIndicator())
                            : error.isNotEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    allowManualEntry
                                        ? '$error\n\nYou can type the user email above and tap Use.'
                                        : error,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: items.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return ListTile(
                                    title: Text(item.label),
                                    subtitle: item.value == item.label
                                        ? null
                                        : Text(item.value),
                                    onTap: () =>
                                        Navigator.pop(sheetContext, item.value),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({
    required this.label,
    required this.values,
    required this.onDeleted,
  });

  final String label;
  final List<String> values;
  final ValueChanged<String> onDeleted;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text('$label: none selected'),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: values
            .map(
              (value) =>
                  Chip(label: Text(value), onDeleted: () => onDeleted(value)),
            )
            .toList(),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.controller,
    required this.label,
    required this.onTap,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.search_rounded),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 3),
          initialDate: now,
        );
        if (picked != null) {
          controller.text =
              '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        }
      },
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_month_rounded),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
