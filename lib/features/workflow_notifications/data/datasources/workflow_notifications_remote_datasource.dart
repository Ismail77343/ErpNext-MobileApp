import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/auth_session.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/workflow_notification_model.dart';
import '../models/workflow_notifications_summary_model.dart';

class WorkflowNotificationsRemoteDataSource {
  Future<List<WorkflowNotificationModel>> getNotifications({
    required int start,
    required int limit,
  }) async {
    final uri = ApiConstants.uri(ApiConstants.workflowNotificationsEndpoint)
        .replace(
          queryParameters: {
            'limit_start': '$start',
            'limit_page_length': '$limit',
          },
        );

    final response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.sales(
      'workflow notifications response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load workflow notifications');
    }

    final decoded = jsonDecode(response.body);
    _throwIfApiPayloadError(decoded, 'Workflow notifications API returned an error.');
    final list = _extractList(decoded);
    return list
        .whereType<Map<String, dynamic>>()
        .map(WorkflowNotificationModel.fromJson)
        .toList();
  }

  Future<WorkflowNotificationsSummaryModel> getSummary() async {
    final response = await http.get(
      ApiConstants.uri(ApiConstants.workflowNotificationsSummaryEndpoint),
      headers: AuthSession.authHeaders(),
    );
    AppLogger.sales(
      'workflow notifications summary response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load workflow notification summary');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    _throwIfApiPayloadError(
      decoded,
      'Workflow notifications summary API returned an error.',
    );
    return WorkflowNotificationsSummaryModel.fromJson(decoded);
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) return const [];
    if (decoded['data'] is List) return decoded['data'] as List;
    if (decoded['message'] is Map<String, dynamic>) {
      final message = decoded['message'] as Map<String, dynamic>;
      if (message['data'] is List) return message['data'] as List;
    }
    return const [];
  }

  void _throwIfApiPayloadError(dynamic decoded, String fallback) {
    if (decoded is! Map<String, dynamic>) return;
    final candidates = [
      decoded,
      if (decoded['message'] is Map<String, dynamic>) decoded['message'],
    ];
    for (final candidate in candidates) {
      if (candidate is! Map<String, dynamic>) continue;
      final status = candidate['status']?.toString().toLowerCase();
      if (status == 'error') {
        throw Exception(candidate['message']?.toString() ?? fallback);
      }
    }
  }

  String _preview(String body, {int max = 500}) {
    if (body.length <= max) return body;
    return '${body.substring(0, max)}...';
  }
}
