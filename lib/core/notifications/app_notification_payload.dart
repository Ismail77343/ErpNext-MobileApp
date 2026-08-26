import 'dart:convert';

class AppNotificationPayload {
  final String type;
  final String id;
  final String title;
  final String body;
  final String? doctype;
  final String? documentName;
  final String? taskFollowUpName;
  final String? documentUrl;

  const AppNotificationPayload({
    required this.type,
    required this.id,
    required this.title,
    required this.body,
    this.doctype,
    this.documentName,
    this.taskFollowUpName,
    this.documentUrl,
  });

  factory AppNotificationPayload.fromJson(Map<String, dynamic> json) {
    final type = _string(json, const ['type', 'notification_type']);
    final documentName = _string(json, const [
      'document_name',
      'mobileParamValue',
      'mobile_param_value',
    ]);
    final taskName = _string(json, const [
      'task_follow_up_name',
      'task_name',
      'name',
    ]);
    final id = _string(json, const ['id', 'name', 'notification_id']);
    final title = _string(json, const ['title', 'subject', 'display_name']);
    final body = _string(json, const ['body', 'message', 'content']);

    return AppNotificationPayload(
      type: type.isEmpty ? 'workflow' : type,
      id: id.isEmpty ? '${type}_$documentName$taskName' : id,
      title: title.isEmpty ? 'TPGNexus' : title,
      body: body.isEmpty ? 'New notification received' : body,
      doctype: _nullableString(json, const ['doctype']),
      documentName: documentName.isEmpty ? null : documentName,
      taskFollowUpName: taskName.isEmpty ? null : taskName,
      documentUrl: _nullableString(json, const ['document_url', 'url']),
    );
  }

  factory AppNotificationPayload.fromEncoded(String value) {
    final decoded = jsonDecode(value);
    if (decoded is Map<String, dynamic>) {
      return AppNotificationPayload.fromJson(decoded);
    }
    throw const FormatException('Notification payload must be a JSON object.');
  }

  String encode() => jsonEncode({
        'type': type,
        'id': id,
        'title': title,
        'body': body,
        if (doctype != null) 'doctype': doctype,
        if (documentName != null) 'document_name': documentName,
        if (taskFollowUpName != null) 'task_follow_up_name': taskFollowUpName,
        if (documentUrl != null) 'document_url': documentUrl,
      });

  static String _string(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty && value != 'null') return value;
    }
    return '';
  }

  static String? _nullableString(Map<String, dynamic> json, List<String> keys) {
    final value = _string(json, keys);
    return value.isEmpty ? null : value;
  }
}
