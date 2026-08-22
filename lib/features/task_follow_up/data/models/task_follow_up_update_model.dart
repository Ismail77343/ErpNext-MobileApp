import '../../domain/entities/task_follow_up_update.dart';

class TaskFollowUpUpdateModel extends TaskFollowUpUpdate {
  const TaskFollowUpUpdateModel({
    required super.name,
    required super.note,
    required super.status,
    required super.progress,
    required super.attachment,
    required super.owner,
    required super.creation,
  });

  factory TaskFollowUpUpdateModel.fromJson(Map<String, dynamic> json) {
    return TaskFollowUpUpdateModel(
      name: _readString(json, const ['name', 'id']),
      note: _readString(json, const ['note', 'details', 'follow_up']),
      status: _readString(json, const ['status']),
      progress: _readInt(json, const ['progress']),
      attachment: _readString(json, const ['attachment']),
      owner: _readString(json, const ['owner', 'modified_by']),
      creation: _readString(json, const ['creation', 'registered_on']),
    );
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  return '';
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.round();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return 0;
}
