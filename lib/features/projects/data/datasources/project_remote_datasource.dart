import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/auth_session.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/project_details_model.dart';
import '../models/project_model.dart';
import '../models/task_details_model.dart';

class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getProjects({
    required int start,
    required int limit,
  }) async {
    AppLogger.project(
      'project remote datasource: GET projects start=$start limit=$limit',
    );
    final uri = ApiConstants.uri(ApiConstants.projectsEndpoint).replace(
      queryParameters: {'limit_start': '$start', 'limit_page_length': '$limit'},
    );
    final response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.project(
      'project remote datasource: response ${response.statusCode}',
    );

    if (response.statusCode != 200) {
      AppLogger.error(
        'projects GET failed body: ${response.body.substring(0, response.body.length > 350 ? 350 : response.body.length)}',
      );
      throw Exception('Failed to load projects: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    AppLogger.project(
      'project remote datasource: body sample ${response.body.substring(0, response.body.length > 250 ? 250 : response.body.length)}',
    );

    final rawList = _extractProjectsList(decoded);
    if (rawList == null) {
      AppLogger.project('project remote datasource: no list found in response');
      return [];
    }

    final projects = rawList
        .whereType<Map<String, dynamic>>()
        .map(ProjectModel.fromJson)
        .toList();

    AppLogger.project('project remote datasource: parsed ${projects.length}');
    return projects;
  }

  Future<ProjectDetailsModel> getProjectDetails(String projectName) async {
    AppLogger.project('project details request start: $projectName');
    final uri = ApiConstants.uri(
      ApiConstants.projectDetailsEndpoint,
    ).replace(queryParameters: {'project_name': projectName});

    var response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.project('project details GET response: ${response.statusCode}');

    if (response.statusCode != 200) {
      AppLogger.error(
        'project details GET failed body: ${response.body.substring(0, response.body.length > 350 ? 350 : response.body.length)}',
      );
      response = await http.post(
        ApiConstants.uri(ApiConstants.projectDetailsEndpoint),
        headers: AuthSession.authHeaders(withJson: false),
        body: {'project_name': projectName},
      );
      AppLogger.project(
        'project details POST response: ${response.statusCode}',
      );
    }

    if (response.statusCode != 200) {
      AppLogger.error(
        'project details POST failed body: ${response.body.substring(0, response.body.length > 350 ? 350 : response.body.length)}',
      );
      throw Exception(
        'Failed to load project details: ${response.statusCode}. Check server error log.',
      );
    }

    final decoded = jsonDecode(response.body);
    final detailsMap = _extractDetailsMap(decoded);
    if (detailsMap == null) {
      throw Exception('Invalid project details response format');
    }

    return ProjectDetailsModel.fromJson(detailsMap);
  }

  Future<TaskDetailsModel> getTaskDetails(String taskName) async {
    AppLogger.project('task details request start: $taskName');
    final uri = ApiConstants.uri(
      ApiConstants.taskDetailsEndpoint,
    ).replace(queryParameters: {'task_name': taskName});

    var response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.project('task details GET response: ${response.statusCode}');

    if (response.statusCode != 200) {
      AppLogger.error(
        'task details GET failed body: ${response.body.substring(0, response.body.length > 350 ? 350 : response.body.length)}',
      );
      response = await http.post(
        ApiConstants.uri(ApiConstants.taskDetailsEndpoint),
        headers: AuthSession.authHeaders(withJson: false),
        body: {'task_name': taskName},
      );
      AppLogger.project('task details POST response: ${response.statusCode}');
    }

    if (response.statusCode != 200) {
      AppLogger.error(
        'task details POST failed body: ${response.body.substring(0, response.body.length > 350 ? 350 : response.body.length)}',
      );
      throw Exception(
        'Failed to load task details: ${response.statusCode}. Check server error log.',
      );
    }

    AppLogger.project(
      'task details body sample: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}',
    );

    final decoded = jsonDecode(response.body);
    final detailsMap = _extractDetailsMap(decoded);
    if (detailsMap == null) {
      throw Exception('Invalid task details response format');
    }

    final model = TaskDetailsModel.fromJson(detailsMap);
    AppLogger.project(
      'task details parsed: child_follow=${model.childFollow.length} activity=${model.activityLog.length}',
    );
    return model;
  }

  Future<void> addFollowUp({
    required String taskName,
    required String dateFollow,
    required String timeFollow,
    required int progress,
    required String followUp,
    String? attachment,
  }) async {
    AppLogger.project('add follow up start task=$taskName progress=$progress');

    final response = await http.post(
      ApiConstants.uri(ApiConstants.addFollowUpEndpoint),
      headers: AuthSession.authHeaders(withJson: false),
      body: {
        'task_name': taskName,
        'date_follow': dateFollow,
        'time_follow': timeFollow,
        'progress': '$progress',
        'follow_up': followUp,
        if (attachment != null && attachment.isNotEmpty)
          'attachment': attachment,
      },
    );

    AppLogger.project('add follow up response: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Failed to add follow up: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final payload = decoded['message'] ?? decoded['data'] ?? decoded;
      if (payload is Map<String, dynamic>) {
        final status = payload['status']?.toString().toLowerCase();
        if (status == 'error') {
          throw Exception(
            payload['message']?.toString() ?? 'Add follow up failed',
          );
        }
      }
    }

    AppLogger.project('add follow up success task=$taskName');
  }

  Future<String> uploadAttachment({
    required String filePath,
    required String doctype,
    required String docname,
  }) async {
    AppLogger.project('upload attachment start: $filePath');

    final request = http.MultipartRequest(
      'POST',
      ApiConstants.uri('/api/method/upload_file'),
    );

    final headers = AuthSession.authHeaders(withJson: false);
    request.headers.addAll(headers);
    request.fields['doctype'] = doctype;
    request.fields['docname'] = docname;
    request.fields['is_private'] = '0';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    AppLogger.project('upload attachment response: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Failed to upload attachment: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid upload response format');
    }

    final payload = decoded['message'] ?? decoded['data'] ?? decoded;
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid upload payload');
    }

    final fileUrl = payload['file_url']?.toString();
    if (fileUrl == null || fileUrl.isEmpty) {
      throw Exception('Upload succeeded but file_url missing');
    }

    AppLogger.project('upload attachment success: $fileUrl');
    return fileUrl;
  }

  List<dynamic>? _extractProjectsList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is! Map<String, dynamic>) return null;

    final candidates = [
      decoded['data'],
      decoded['message'],
      decoded['projects'],
      decoded['result'],
    ];

    for (final value in candidates) {
      if (value is List) return value;
    }

    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      final nestedCandidates = [
        data['projects'],
        data['items'],
        data['results'],
        data['message'],
      ];
      for (final value in nestedCandidates) {
        if (value is List) return value;
      }
    }

    return null;
  }

  Map<String, dynamic>? _extractDetailsMap(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final payload = _extractMapPayload(decoded);
      if (payload.isNotEmpty) {
        return payload;
      }
    }
    return null;
  }

  Map<String, dynamic> _extractMapPayload(Map<String, dynamic> decoded) {
    final data = decoded['data'];
    if (data is Map<String, dynamic>) return data;

    final message = decoded['message'];
    if (message is Map<String, dynamic>) return message;

    final result = decoded['result'];
    if (result is Map<String, dynamic>) return result;

    return decoded;
  }
}
