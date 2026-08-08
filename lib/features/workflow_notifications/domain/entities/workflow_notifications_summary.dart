class WorkflowNotificationsSummary {
  final int totalCount;
  final int unreadCount;
  final int opportunityCount;
  final int quotationCount;
  final int leadCount;
  final int otherCount;

  const WorkflowNotificationsSummary({
    required this.totalCount,
    required this.unreadCount,
    required this.opportunityCount,
    required this.quotationCount,
    required this.leadCount,
    required this.otherCount,
  });

  const WorkflowNotificationsSummary.empty()
      : totalCount = 0,
        unreadCount = 0,
        opportunityCount = 0,
        quotationCount = 0,
        leadCount = 0,
        otherCount = 0;
}
