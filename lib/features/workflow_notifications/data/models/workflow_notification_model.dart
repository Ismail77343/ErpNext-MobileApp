import '../../domain/entities/workflow_notification.dart';
import 'workflow_notification_action_model.dart';

class WorkflowNotificationModel extends WorkflowNotification {
  const WorkflowNotificationModel({
    required super.id,
    required super.notificationType,
    required super.allocatedTo,
    required super.doctype,
    required super.documentName,
    required super.displayName,
    required super.workflowState,
    required super.status,
    required super.priority,
    required super.todoStatus,
    required super.dueDate,
    required super.modified,
    required super.message,
    required super.documentUrl,
    required super.mobileMethod,
    required super.mobileParamKey,
    required super.mobileParamValue,
    required super.actionCount,
    required super.actions,
  });

  factory WorkflowNotificationModel.fromJson(Map<String, dynamic> json) {
    final documentLink = json['document_link'] is Map<String, dynamic>
        ? json['document_link'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final detail = json['detail_endpoint'] is Map<String, dynamic>
        ? json['detail_endpoint'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final actions = json['actions'] is List
        ? (json['actions'] as List)
            .whereType<Map<String, dynamic>>()
            .map(WorkflowNotificationActionModel.fromJson)
            .toList()
        : const <WorkflowNotificationActionModel>[];

    return WorkflowNotificationModel(
      id: json['id']?.toString() ?? '',
      notificationType: json['notification_type']?.toString() ?? '',
      allocatedTo: json['allocated_to']?.toString() ?? '',
      doctype: json['doctype']?.toString() ?? '',
      documentName: json['document_name']?.toString() ?? '',
      displayName: json['display_name']?.toString() ??
          json['document_name']?.toString() ??
          '',
      workflowState: json['workflow_state']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      todoStatus: json['todo_status']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      documentUrl: documentLink['url']?.toString() ?? '',
      mobileMethod: detail['method']?.toString() ?? '',
      mobileParamKey: detail['param_key']?.toString() ?? '',
      mobileParamValue: detail['param_value']?.toString() ?? '',
      actionCount: int.tryParse(json['action_count']?.toString() ?? '') ??
          actions.length,
      actions: actions,
    );
  }
}
