import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task_follow_up.dart';
import '../providers/task_follow_up_notifications_provider.dart';
import '../providers/task_follow_ups_provider.dart';
import 'create_task_follow_up_page.dart';
import 'task_follow_up_details_page.dart';

class TaskFollowUpsPage extends StatefulWidget {
  final bool embedded;

  const TaskFollowUpsPage({super.key, this.embedded = false});

  @override
  State<TaskFollowUpsPage> createState() => _TaskFollowUpsPageState();
}

class _TaskFollowUpsPageState extends State<TaskFollowUpsPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  static const _statuses = [
    'All',
    'Open',
    'Working',
    'Blocked',
    'Overdue',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final threshold = _scrollController.position.maxScrollExtent - 180;
      if (_scrollController.position.pixels >= threshold) {
        context.read<TaskFollowUpsProvider>().fetch();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TaskFollowUpsProvider>().initialize();
      context.read<TaskFollowUpNotificationsProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskFollowUpsProvider>();
    final notifications = context.watch<TaskFollowUpNotificationsProvider>();

    final body = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF7FA), Color(0xFFF7FBFD)],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([provider.refresh(), notifications.refresh()]);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    _HeroCard(unreadCount: notifications.unreadCount),
                    const SizedBox(height: 14),
                    _SearchBox(
                      controller: _searchController,
                      onChanged: provider.setSearchQuery,
                    ),
                    const SizedBox(height: 10),
                    _TabSelector(provider: provider),
                    const SizedBox(height: 10),
                    _StatusFilters(
                      statuses: _statuses,
                      selected: provider.statusFilter,
                      onSelected: provider.setStatusFilter,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: provider.onlyOpen,
                      onChanged: provider.setOnlyOpen,
                      title: const Text('Open tasks only'),
                      subtitle: const Text(
                        'Hide completed and cancelled tasks',
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
                  title: 'Unable to load task follow ups',
                  message: provider.error!,
                  icon: Icons.cloud_off_rounded,
                  onRetry: provider.refresh,
                  isError: true,
                ),
              )
            else if (provider.items.isEmpty)
              SliverFillRemaining(
                child: _StateCard(
                  title: 'No task follow ups found',
                  message:
                      'Try changing the tab, status filter, or open-only switch.',
                  icon: Icons.task_alt_rounded,
                  onRetry: provider.refresh,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                sliver: SliverList.builder(
                  itemCount:
                      provider.items.length + (provider.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= provider.items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(18),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final item = provider.items[index];
                    return _TaskFollowUpCard(
                      item: item,
                      assignedToMe:
                          provider.tab == TaskFollowUpTab.assignedToMe,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskFollowUpDetailsPage(
                              taskName: item.name,
                              assignedToMe:
                                  provider.tab == TaskFollowUpTab.assignedToMe,
                            ),
                          ),
                        );
                        if (context.mounted) {
                          context.read<TaskFollowUpsProvider>().refresh();
                          context
                              .read<TaskFollowUpNotificationsProvider>()
                              .refresh();
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

    final page = Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(title: const Text('Task Follow Ups')),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateTaskFollowUpPage()),
          );
          if (created == true && context.mounted) {
            context.read<TaskFollowUpsProvider>().refresh();
          }
        },
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Create Task'),
      ),
    );

    return page;
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF072F5F), Color(0xFF0077FF), Color(0xFF06B6D4)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.task_alt_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Follow Ups',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Track assigned work and updates',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Chip(
            label: Text('$unreadCount unread'),
            backgroundColor: Colors.white,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search subject, project, task...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({required this.provider});

  final TaskFollowUpsProvider provider;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TaskFollowUpTab>(
      segments: const [
        ButtonSegment(
          value: TaskFollowUpTab.assignedToMe,
          label: Text('Assigned to Me'),
          icon: Icon(Icons.inbox_rounded),
        ),
        ButtonSegment(
          value: TaskFollowUpTab.assignedByMe,
          label: Text('Assigned by Me'),
          icon: Icon(Icons.outbox_rounded),
        ),
      ],
      selected: {provider.tab},
      onSelectionChanged: (value) => provider.setTab(value.first),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({
    required this.statuses,
    required this.selected,
    required this.onSelected,
  });

  final List<String> statuses;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];
          return ChoiceChip(
            label: Text(status),
            selected: selected == status,
            onSelected: (_) => onSelected(status),
          );
        },
      ),
    );
  }
}

class _TaskFollowUpCard extends StatelessWidget {
  const _TaskFollowUpCard({
    required this.item,
    required this.onTap,
    required this.assignedToMe,
  });

  final TaskFollowUp item;
  final VoidCallback onTap;
  final bool assignedToMe;

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
                      item.subject.isEmpty ? item.name : item.subject,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _Badge(
                    label: item.status.isEmpty ? 'Open' : item.status,
                    color: color,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Code: ${item.name}'),
              if (item.project.isNotEmpty) Text('Project: ${item.project}'),
              if (item.task.isNotEmpty) Text('Task: ${item.task}'),
              Text(
                assignedToMe
                    ? 'Assigned by: ${item.assignedBy.isEmpty ? '-' : item.assignedBy}'
                    : 'Assigned to: ${item.assignedToUser.isEmpty ? item.assignedToEmployee : item.assignedToUser}',
                style: const TextStyle(color: Color(0xFF475569)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: item.progress.clamp(0, 100) / 100,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${item.progress.clamp(0, 100)}%'),
                ],
              ),
              if (item.dueDate.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Due: ${_displayDate(item.dueDate)}',
                  style: const TextStyle(color: Color(0xFFB45309)),
                ),
              ],
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
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.onRetry,
    this.isError = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback onRetry;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFDC2626) : const Color(0xFF0E7490);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 44, color: color),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
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
    case 'completed':
      return const Color(0xFF16A34A);
    case 'cancelled':
      return const Color(0xFF64748B);
    case 'blocked':
      return const Color(0xFFDC2626);
    case 'overdue':
      return const Color(0xFFBE123C);
    case 'working':
      return const Color(0xFF0369A1);
    default:
      return const Color(0xFFD97706);
  }
}

String _displayDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  return '${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
}
