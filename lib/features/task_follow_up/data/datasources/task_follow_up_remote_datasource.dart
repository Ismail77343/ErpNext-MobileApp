import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/auth_session.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/link_option_model.dart';
import '../models/task_follow_up_details_model.dart';
import '../models/task_follow_up_model.dart';
import '../models/task_follow_up_notification_model.dart';

class TaskFollowUpRemoteDataSource {
  Future<List<TaskFollowUpModel>> getMyTasks({
    String? status,
    bool onlyOpen = false,
    required int start,
    required int limit,
  }) {
    return _getTasks(
      endpoint: ApiConstants.myMobileTaskFollowUpsEndpoint,
      status: status,
      onlyOpen: onlyOpen,
      start: start,
      limit: limit,
      label: 'my mobile task follow ups',
    );
  }

  Future<List<TaskFollowUpModel>> getAssignedTasks({
    String? status,
    bool onlyOpen = false,
    required int start,
    required int limit,
  }) {
    return _getTasks(
      endpoint: ApiConstants.assignedMobileTaskFollowUpsEndpoint,
      status: status,
      onlyOpen: onlyOpen,
      start: start,
      limit: limit,
      label: 'assigned mobile task follow ups',
    );
  }

  Future<List<TaskFollowUpModel>> _getTasks({
    required String endpoint,
    required String label,
    String? status,
    bool onlyOpen = false,
    required int start,
    required int limit,
  }) async {
    final uri = ApiConstants.uri(endpoint).replace(
      queryParameters: {
        'limit_start': '$start',
        'limit_page_length': '$limit',
        if (status != null && status.isNotEmpty && status != 'All')
          'status': status,
        if (onlyOpen) 'only_open': '1',
      },
    );

    final response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.project(
      '$label response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load task follow ups: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    _throwIfApiError(decoded, 'Failed to load task follow ups');
    return _extractList(decoded)
        .whereType<Map<String, dynamic>>()
        .map(TaskFollowUpModel.fromJson)
        .toList();
  }

  Future<TaskFollowUpDetailsModel> getDetails(String name) async {
    final uri = ApiConstants.uri(
      ApiConstants.mobileTaskFollowUpDetailsEndpoint,
    ).replace(queryParameters: {'name': name});

    var response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.project(
      'mobile task follow up details GET response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      response = await http.post(
        ApiConstants.uri(ApiConstants.mobileTaskFollowUpDetailsEndpoint),
        headers: AuthSession.authHeaders(),
        body: jsonEncode({'name': name}),
      );
      AppLogger.project(
        'mobile task follow up details POST response=${response.statusCode} body=${_preview(response.body)}',
      );
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to load task follow up: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    _throwIfApiError(decoded, 'Failed to load task follow up');
    return TaskFollowUpDetailsModel.fromJson(_extractMap(decoded));
  }

  Future<void> createTask(Map<String, dynamic> data) async {
    final response = await http.post(
      ApiConstants.uri(ApiConstants.createMobileTaskFollowUpEndpoint),
      headers: AuthSession.authHeaders(),
      body: jsonEncode(data),
    );
    AppLogger.project(
      'create mobile task follow up response=${response.statusCode} body=${_preview(response.body)}',
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to create task follow up: ${response.statusCode}',
      );
    }
    _throwIfApiError(jsonDecode(response.body), 'Create task follow up failed');
  }

  Future<void> addUpdate({
    required String name,
    required String note,
    required int progress,
    required String status,
    String? attachment,
  }) async {
    final response = await http.post(
      ApiConstants.uri(ApiConstants.addMobileTaskFollowUpUpdateEndpoint),
      headers: AuthSession.authHeaders(),
      body: jsonEncode({
        'name': name,
        'note': note,
        'progress': progress,
        'status': status,
        if (attachment != null && attachment.isNotEmpty)
          'attachment': attachment,
      }),
    );
    AppLogger.project(
      'add mobile task follow up update response=${response.statusCode} body=${_preview(response.body)}',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add update: ${response.statusCode}');
    }
    _throwIfApiError(jsonDecode(response.body), 'Add update failed');
  }

  Future<void> closeTask({
    required String name,
    required String status,
    required String note,
  }) async {
    final response = await http.post(
      ApiConstants.uri(ApiConstants.closeMobileTaskFollowUpEndpoint),
      headers: AuthSession.authHeaders(),
      body: jsonEncode({'name': name, 'status': status, 'note': note}),
    );
    AppLogger.project(
      'close mobile task follow up response=${response.statusCode} body=${_preview(response.body)}',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to close task: ${response.statusCode}');
    }
    _throwIfApiError(jsonDecode(response.body), 'Close task failed');
  }

  Future<List<TaskFollowUpNotificationModel>> getNotifications() async {
    final response = await http.get(
      ApiConstants.uri(ApiConstants.mobileTaskFollowUpNotificationsEndpoint),
      headers: AuthSession.authHeaders(),
    );
    AppLogger.project(
      'mobile task follow up notifications response=${response.statusCode} body=${_preview(response.body)}',
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load task notifications: ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body);
    _throwIfApiError(decoded, 'Failed to load task notifications');
    return _extractList(decoded)
        .whereType<Map<String, dynamic>>()
        .map(TaskFollowUpNotificationModel.fromJson)
        .toList();
  }

  Future<void> markAsRead(String name) async {
    final response = await http.post(
      ApiConstants.uri(ApiConstants.markMobileTaskFollowUpReadEndpoint),
      headers: AuthSession.authHeaders(),
      body: jsonEncode({'name': name}),
    );
    AppLogger.project(
      'mark mobile task follow up read response=${response.statusCode} body=${_preview(response.body)}',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark task as read: ${response.statusCode}');
    }
    _throwIfApiError(jsonDecode(response.body), 'Mark task as read failed');
  }

  Future<List<LinkOptionModel>> searchLinkOptions({
    required String doctype,
    String query = '',
  }) async {
    final uri = ApiConstants.uri(ApiConstants.searchLinkEndpoint).replace(
      queryParameters: {
        'doctype': doctype,
        'txt': query,
        'page_length': '20',
        'reference_doctype': 'Mobile Task Follow Up',
      },
    );
    final response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.project(
      'task follow up search_link doctype=$doctype query="$query" response=${response.statusCode} body=${_preview(response.body)}',
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to search $doctype: ${response.statusCode}. ${_extractErrorMessage(response.body)}',
      );
    }
    return _extractList(jsonDecode(response.body))
        .map(LinkOptionModel.fromDynamic)
        .where((item) => item.value.isNotEmpty)
        .toList();
  }

  Future<String> uploadAttachment({
    required String filePath,
    required String docname,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      ApiConstants.uri('/api/method/upload_file'),
    );
    request.headers.addAll(AuthSession.authHeaders(withJson: false));
    request.fields['doctype'] = 'Mobile Task Follow Up';
    request.fields['docname'] = docname;
    request.fields['is_private'] = '0';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200) {
      throw Exception('Failed to upload attachment: ${response.statusCode}');
    }

    final payload = _extractMap(jsonDecode(response.body));
    final fileUrl = payload['file_url']?.toString();
    if (fileUrl == null || fileUrl.isEmpty) {
      throw Exception('Upload succeeded but file_url missing');
    }
    return fileUrl;
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is! Map<String, dynamic>) return const [];
    for (final key in const [
      'data',
      'message',
      'result',
      'items',
      'results',
      'tasks',
      'notifications',
    ]) {
      final value = decoded[key];
      if (value is List) return value;
      if (value is Map<String, dynamic>) {
        final nested = _extractList(value);
        if (nested.isNotEmpty) return nested;
      }
    }
    return const [];
  }

  Map<String, dynamic> _extractMap(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) return <String, dynamic>{};
    for (final key in const ['data', 'message', 'result']) {
      final value = decoded[key];
      if (value is Map<String, dynamic>) {
        final nested = value['data'];
        if (nested is Map<String, dynamic>) return nested;
        return value;
      }
    }
    return decoded;
  }

  void _throwIfApiError(dynamic decoded, String fallback) {
    if (decoded is! Map<String, dynamic>) return;
    for (final candidate in [decoded, decoded['message'], decoded['data']]) {
      if (candidate is! Map<String, dynamic>) continue;
      final status = candidate['status']?.toString().toLowerCase();
      if (status == 'error') {
        throw Exception(candidate['message']?.toString() ?? fallback);
      }
    }
  }

  String _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      final payload = decoded is Map<String, dynamic>
          ? (decoded['message'] ??
                decoded['exception'] ??
                decoded['_server_messages'])
          : null;
      final text = payload?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    } catch (_) {
      // Keep the original concise fallback below.
    }
    return _preview(body, max: 160);
  }

  String _preview(String body, {int max = 500}) {
    if (body.length <= max) return body;
    return '${body.substring(0, max)}...';
  }
}
