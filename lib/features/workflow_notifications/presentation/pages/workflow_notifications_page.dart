import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/workflow_notification.dart';
import '../providers/workflow_notifications_provider.dart';

class WorkflowNotificationsPage extends StatefulWidget {
  const WorkflowNotificationsPage({super.key});

  @override
  State<WorkflowNotificationsPage> createState() =>
      _WorkflowNotificationsPageState();
}

class _WorkflowNotificationsPageState extends State<WorkflowNotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final threshold = _scrollController.position.maxScrollExtent - 180;
      if (_scrollController.position.pixels >= threshold) {
        context.read<WorkflowNotificationsProvider>().loadMore();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WorkflowNotificationsProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkflowNotificationsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Workflow Notifications')),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const SizedBox(height: 80),
                            const Icon(
                              Icons.notifications_off_rounded,
                              size: 48,
                              color: Color(0xFFDC2626),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              provider.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFFB91C1C)),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: provider.refresh,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      _NotificationsSummaryCard(provider: provider),
                      const SizedBox(height: 16),
                      if (provider.notifications.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: Center(
                            child: Text('No workflow notifications found'),
                          ),
                        )
                      else
                        ...provider.notifications.map(
                          (item) => _WorkflowNotificationCard(
                            notification: item,
                          ),
                        ),
                      if (provider.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
      ),
    );
  }
}

class _NotificationsSummaryCard extends StatelessWidget {
  const _NotificationsSummaryCard({required this.provider});

  final WorkflowNotificationsProvider provider;

  @override
  Widget build(BuildContext context) {
    final summary = provider.summary;
    final items = [
      ('Unread', summary.unreadCount, const Color(0xFFDC2626)),
      ('Quotation', summary.quotationCount, const Color(0xFF7C3AED)),
      ('Opportunity', summary.opportunityCount, const Color(0xFF0369A1)),
      ('Other', summary.otherCount, const Color(0xFF0F766E)),
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 120,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: item.$3.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${item.$2}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: item.$3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WorkflowNotificationCard extends StatelessWidget {
  const _WorkflowNotificationCard({required this.notification});

  final WorkflowNotification notification;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    notification.displayName.isEmpty
                        ? notification.documentName
                        : notification.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                _WorkflowBadge(label: notification.workflowState),
              ],
            ),
            const SizedBox(height: 8),
            Text('${notification.doctype} • ${notification.documentName}'),
            if (notification.status.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Status: ${notification.status}',
                style: const TextStyle(color: Color(0xFF475569)),
              ),
            ],
            if (notification.message.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                notification.message,
                style: const TextStyle(color: Color(0xFF334155)),
              ),
            ],
            if (notification.actions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: notification.actions
                    .map((action) => Chip(label: Text(action.action)))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: notification.documentUrl.isEmpty
                      ? null
                      : () => _openUrl(notification.documentUrl),
                  icon: const Icon(Icons.open_in_browser_rounded),
                  label: const Text('Open In ERPNext'),
                ),
                if (notification.dueDate.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.event_rounded),
                    label: Text(_displayDate(notification.dueDate)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String value) async {
    final uri = value.startsWith('http')
        ? Uri.parse(value)
        : Uri.parse('${ApiConstants.baseUrl}$value');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _WorkflowBadge extends StatelessWidget {
  const _WorkflowBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.isEmpty ? '-' : label,
        style: const TextStyle(
          color: Color(0xFF7C3AED),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _displayDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  final y = parsed.year.toString().padLeft(4, '0');
  final m = parsed.month.toString().padLeft(2, '0');
  final d = parsed.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
