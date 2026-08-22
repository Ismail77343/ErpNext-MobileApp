class TaskFollowUpUpdate {
  final String name;
  final String note;
  final String status;
  final int progress;
  final String attachment;
  final String owner;
  final String creation;

  const TaskFollowUpUpdate({
    required this.name,
    required this.note,
    required this.status,
    required this.progress,
    required this.attachment,
    required this.owner,
    required this.creation,
  });
}
