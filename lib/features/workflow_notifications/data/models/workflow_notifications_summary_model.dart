import '../../domain/entities/workflow_notifications_summary.dart';

class WorkflowNotificationsSummaryModel extends WorkflowNotificationsSummary {
  const WorkflowNotificationsSummaryModel({
    required super.totalCount,
    required super.unreadCount,
    required super.opportunityCount,
    required super.quotationCount,
    required super.leadCount,
    required super.otherCount,
  });

  factory WorkflowNotificationsSummaryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final summary = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : (json['message'] is Map<String, dynamic> &&
                (json['message'] as Map<String, dynamic>)['summary']
                    is Map<String, dynamic>)
            ? (json['message'] as Map<String, dynamic>)['summary']
                as Map<String, dynamic>
            : const <String, dynamic>{};

    return WorkflowNotificationsSummaryModel(
      totalCount: int.tryParse(summary['total_count']?.toString() ?? '') ?? 0,
      unreadCount: int.tryParse(summary['unread_count']?.toString() ?? '') ?? 0,
      opportunityCount:
          int.tryParse(summary['opportunity_count']?.toString() ?? '') ?? 0,
      quotationCount:
          int.tryParse(summary['quotation_count']?.toString() ?? '') ?? 0,
      leadCount: int.tryParse(summary['lead_count']?.toString() ?? '') ?? 0,
      otherCount: int.tryParse(summary['other_count']?.toString() ?? '') ?? 0,
    );
  }
}
