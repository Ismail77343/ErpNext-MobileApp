class WorkflowNotificationAction {
  final String action;
  final String allowed;
  final String nextState;
  final String state;

  const WorkflowNotificationAction({
    required this.action,
    required this.allowed,
    required this.nextState,
    required this.state,
  });
}
