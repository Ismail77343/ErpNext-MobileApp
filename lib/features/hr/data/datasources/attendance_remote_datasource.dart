import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/auth_session.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/attendance_context_model.dart';
import '../models/employee_checkin_result_model.dart';

class AttendanceRemoteDataSource {
  Future<AttendanceContextModel> getAttendanceContext({
    String? project,
    String? deviceId,
    String? platform,
  }) async {
    final body = {
      if (project != null && project.isNotEmpty) 'project': project,
      if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
      if (platform != null && platform.isNotEmpty) 'platform': platform,
    };

    final response = await http.post(
      ApiConstants.uri(ApiConstants.hrAttendanceContextEndpoint),
      headers: AuthSession.authHeaders(),
      body: jsonEncode(body),
    );
    AppLogger.info(
      '[HR] attendance context response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(_extractApiError(response.body));
    }

    final decoded = jsonDecode(response.body);
    _throwIfApiPayloadError(decoded);
    return AttendanceContextModel.fromJson(
      decoded is Map<String, dynamic> ? decoded : <String, dynamic>{},
    );
  }

  Future<AttendanceDeviceVerificationModel> requestMobileDeviceVerification({
    required String deviceId,
    required String deviceName,
    required String platform,
    required String appVersion,
    required String phoneNumber,
  }) async {
    final body = {
      'device_id': deviceId,
      'device_name': deviceName,
      'platform': platform,
      'app_version': appVersion,
      'phone_number': phoneNumber,
    };

    AppLogger.info('[HR] device verification request=${jsonEncode(body)}');
    final response = await http.post(
      ApiConstants.uri(ApiConstants.requestMobileDeviceVerificationEndpoint),
      headers: AuthSession.authHeaders(),
      body: jsonEncode(body),
    );
    AppLogger.info(
      '[HR] device verification response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(_extractApiError(response.body));
    }

    final decoded = jsonDecode(response.body);
    _throwIfApiPayloadError(decoded);
    return AttendanceDeviceVerificationModel.fromJson(
      decoded is Map<String, dynamic>
          ? _extractMessageMap(decoded)
          : <String, dynamic>{},
    );
  }

  Future<EmployeeCheckinResultModel> createEmployeeCheckin({
    required String logType,
    required double latitude,
    required double longitude,
    required double accuracy,
    String? attendanceLocation,
    String? deviceId,
    String? notes,
    String? project,
    String? photoBase64,
    String? photoFilename,
    String? photoMimeType,
  }) async {
    final body = {
      'log_type': logType,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      if (attendanceLocation != null && attendanceLocation.isNotEmpty)
        'attendance_location': attendanceLocation,
      if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      if (project != null && project.isNotEmpty) 'project': project,
      if (photoBase64 != null && photoBase64.isNotEmpty)
        'photo_base64': photoBase64,
      if (photoFilename != null && photoFilename.isNotEmpty)
        'photo_filename': photoFilename,
      if (photoMimeType != null && photoMimeType.isNotEmpty)
        'photo_mime_type': photoMimeType,
    };

    AppLogger.info(
      '[HR] employee checkin payload=${jsonEncode(_redactLargePayload(body))}',
    );
    final response = await http.post(
      ApiConstants.uri(ApiConstants.mobileEmployeeCheckinEndpoint),
      headers: AuthSession.authHeaders(),
      body: jsonEncode(body),
    );
    AppLogger.info(
      '[HR] employee checkin response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(_extractApiError(response.body));
    }

    final decoded = jsonDecode(response.body);
    _throwIfApiPayloadError(decoded);
    return EmployeeCheckinResultModel.fromJson(
      decoded is Map<String, dynamic> ? decoded : <String, dynamic>{},
    );
  }

  void _throwIfApiPayloadError(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) return;

    final candidates = [
      decoded,
      if (decoded['message'] is Map<String, dynamic>) decoded['message'],
      if (decoded['data'] is Map<String, dynamic>) decoded['data'],
    ];

    for (final candidate in candidates) {
      if (candidate is! Map<String, dynamic>) continue;
      final status = candidate['status']?.toString().toLowerCase();
      if (status == 'error') {
        throw Exception(
          _friendlyPhotoError(
            candidate['message']?.toString() ?? 'HR API error',
          ),
        );
      }
    }
  }

  Map<String, dynamic> _redactLargePayload(Map<String, dynamic> body) {
    return {
      ...body,
      if (body.containsKey('photo_base64')) 'photo_base64': '<base64-redacted>',
    };
  }

  Map<String, dynamic> _extractMessageMap(Map<String, dynamic> decoded) {
    final message = decoded['message'];
    if (message is Map<String, dynamic>) return message;
    if (message is Map) return Map<String, dynamic>.from(message);
    return decoded;
  }

  String _extractApiError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is Map && message['message'] != null) {
          final text = message['message'].toString();
          if (text.contains('has no attribute')) {
            return 'HR attendance API is not available on the server.';
          }
          return _friendlyPhotoError(text);
        }
        final serverMessages = decoded['_server_messages'];
        if (serverMessages != null) {
          final parsed = _parseServerMessages(serverMessages.toString());
          if (parsed.contains('has no attribute')) {
            return 'HR attendance API is not available on the server.';
          }
          return _friendlyPhotoError(parsed);
        }
        final exception = decoded['exception'];
        if (exception != null) {
          final text = exception.toString();
          if (text.contains('has no attribute')) {
            return 'HR attendance API is not available on the server.';
          }
          return _friendlyPhotoError(text);
        }
      }
    } catch (_) {
      // Return a stable fallback below.
    }
    return 'Unable to complete HR attendance request.';
  }

  String _parseServerMessages(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is String) {
          final nested = jsonDecode(first);
          if (nested is Map && nested['message'] != null) {
            return nested['message'].toString();
          }
          return first;
        }
      }
    } catch (_) {
      // Return the original server message below.
    }
    return value;
  }

  String _friendlyPhotoError(String text) {
    if (text.contains('CHECKIN_PHOTO_REQUIRED')) {
      return 'Attendance photo is required. Please capture a face photo and try again.';
    }
    if (text.contains('UNSUPPORTED_CHECKIN_PHOTO_TYPE')) {
      return 'Attendance photo type is not supported. Please capture a JPEG or PNG photo.';
    }
    if (text.contains('CHECKIN_PHOTO_TOO_LARGE')) {
      return 'Attendance photo is too large. Please capture a smaller photo.';
    }
    if (text.contains('INVALID_CHECKIN_PHOTO')) {
      return 'Attendance photo is invalid. Please capture the photo again.';
    }
    return text;
  }

  String _preview(String body, {int max = 600}) {
    if (body.length <= max) return body;
    return '${body.substring(0, max)}...';
  }
}
