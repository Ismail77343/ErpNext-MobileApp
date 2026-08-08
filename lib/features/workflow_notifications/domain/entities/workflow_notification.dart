import 'workflow_notification_action.dart';

class WorkflowNotification {
  final String id;
  final String notificationType;
  final String allocatedTo;
  final String doctype;
  final String documentName;
  final String displayName;
  final String workflowState;
  final String status;
  final String priority;
  final String todoStatus;
  final String dueDate;
  final String modified;
  final String message;
  final String documentUrl;
  final String mobileMethod;
  final String mobileParamKey;
  final String mobileParamValue;
  final int actionCount;
  final List<WorkflowNotificationAction> actions;

  const WorkflowNotification({
    required this.id,
    required this.notificationType,
    required this.allocatedTo,
    required this.doctype,
    required this.documentName,
    required this.displayName,
    required this.workflowState,
    required this.status,
    required this.priority,
    required this.todoStatus,
    required this.dueDate,
    required this.modified,
    required this.message,
    required this.documentUrl,
    required this.mobileMethod,
    required this.mobileParamKey,
    required this.mobileParamValue,
    required this.actionCount,
    required this.actions,
  });
}
