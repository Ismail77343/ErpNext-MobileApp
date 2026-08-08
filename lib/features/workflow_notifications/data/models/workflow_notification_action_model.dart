import '../../domain/entities/workflow_notification_action.dart';

class WorkflowNotificationActionModel extends WorkflowNotificationAction {
  const WorkflowNotificationActionModel({
    required super.action,
    required super.allowed,
    required super.nextState,
    required super.state,
  });

  factory WorkflowNotificationActionModel.fromJson(Map<String, dynamic> json) {
    return WorkflowNotificationActionModel(
      action: json['action']?.toString() ?? '',
      allowed: json['allowed']?.toString() ?? '',
      nextState: json['next_state']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
    );
  }
}
