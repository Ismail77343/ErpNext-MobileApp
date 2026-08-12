import '../../domain/entities/attendance_context.dart';

class AttendanceContextModel extends AttendanceContext {
  const AttendanceContextModel({
    required super.enabled,
    required super.settings,
    required super.employee,
    required super.allowedLocations,
    required super.lastCheckin,
    required super.deviceVerification,
  });

  factory AttendanceContextModel.fromJson(Map<String, dynamic> json) {
    final root = _extractPayload(json);
    final locations = root['allowed_locations'];

    return AttendanceContextModel(
      enabled: _readBool(root['enabled']),
      settings: AttendanceSettingsModel.fromJson(_readMap(root['settings'])),
      employee: root['employee'] is Map
          ? AttendanceEmployeeModel.fromJson(_readMap(root['employee']))
          : null,
      allowedLocations: locations is List
          ? locations
                .whereType<Map>()
                .map(
                  (item) => AttendanceLocationModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
      lastCheckin: root['last_checkin'] is Map
          ? LastCheckinModel.fromJson(_readMap(root['last_checkin']))
          : null,
      deviceVerification: AttendanceDeviceVerificationModel.fromJson(root),
    );
  }
}

class AttendanceSettingsModel extends AttendanceSettings {
  const AttendanceSettingsModel({
    required super.requireGeoLocation,
    required super.enforceGeofence,
    required super.defaultRadiusMeters,
    required super.allowManualNotes,
    required super.defaultLogType,
    required super.skipAutoAttendance,
    required super.allowCheckinWithoutAssignment,
    required super.requireVerifiedMobileDevice,
    required super.allowMultipleVerifiedDevices,
    required super.deviceVerificationApproverRole,
    required super.requireCheckinPhoto,
    required super.photoRequiredFor,
    required super.maxPhotoSizeKb,
  });

  factory AttendanceSettingsModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSettingsModel(
      requireGeoLocation: _readBool(json['require_geo_location']),
      enforceGeofence: _readBool(json['enforce_geofence']),
      defaultRadiusMeters: _readDouble(json['default_radius_meters']) ?? 100,
      allowManualNotes: _readBool(json['allow_manual_notes']),
      defaultLogType: _readString(json['default_log_type'], fallback: 'IN'),
      skipAutoAttendance: _readBool(json['skip_auto_attendance']),
      allowCheckinWithoutAssignment: _readBool(
        json['allow_checkin_without_assignment'],
      ),
      requireVerifiedMobileDevice: _readBool(
        json['require_verified_mobile_device'],
      ),
      allowMultipleVerifiedDevices: _readBool(
        json['allow_multiple_verified_devices'],
      ),
      deviceVerificationApproverRole: _readString(
        json['device_verification_approver_role'],
      ),
      requireCheckinPhoto: _readBool(json['require_checkin_photo']),
      photoRequiredFor: _readString(
        json['photo_required_for'],
        fallback: 'Optional',
      ),
      maxPhotoSizeKb: _readInt(json['max_photo_size_kb']) ?? 2048,
    );
  }
}

class AttendanceDeviceVerificationModel extends AttendanceDeviceVerification {
  const AttendanceDeviceVerificationModel({
    required super.required,
    required super.verified,
    required super.status,
    required super.requestName,
    required super.canRequest,
    required super.canCheckin,
    required super.blockingReason,
  });

  factory AttendanceDeviceVerificationModel.fromJson(
    Map<String, dynamic> root,
  ) {
    final nested = _readMap(root['device_verification']);
    final required = nested.isNotEmpty
        ? _readBool(nested['required'])
        : _readBool(root['device_verification_required']);
    final verified = nested.isNotEmpty
        ? _readBool(nested['verified'])
        : _readBool(root['device_verified']);
    final canCheckin = nested.isNotEmpty
        ? _readBool(nested['can_checkin'])
        : (required ? _readBool(root['can_checkin']) : true);

    return AttendanceDeviceVerificationModel(
      required: required,
      verified: verified,
      status: nested.isNotEmpty
          ? _readString(nested['status'], fallback: verified ? 'Approved' : '')
          : _readString(
              root['device_verification_status'] ?? root['verification_status'],
              fallback: verified ? 'Approved' : '',
            ),
      requestName: nested.isNotEmpty
          ? _readString(nested['request_name'])
          : _readString(
              root['device_verification_request_name'] ?? root['request_name'],
            ),
      canRequest: nested.isNotEmpty
          ? _readBool(nested['can_request'])
          : _readBool(root['device_verification_can_request']),
      canCheckin: canCheckin || (!required && root['can_checkin'] == null),
      blockingReason: nested.isNotEmpty
          ? _readString(nested['blocking_reason'])
          : _readString(root['blocking_reason']),
    );
  }
}

class AttendanceEmployeeModel extends AttendanceEmployee {
  const AttendanceEmployeeModel({
    required super.name,
    required super.employeeName,
    required super.department,
    required super.branch,
    required super.company,
  });

  factory AttendanceEmployeeModel.fromJson(Map<String, dynamic> json) {
    return AttendanceEmployeeModel(
      name: _readString(json['name']),
      employeeName: _readString(json['employee_name']),
      department: _readString(json['department']),
      branch: _readString(json['branch']),
      company: _readString(json['company']),
    );
  }
}

class AttendanceLocationModel extends AttendanceLocation {
  const AttendanceLocationModel({
    required super.name,
    required super.locationName,
    required super.locationType,
    required super.company,
    required super.branch,
    required super.department,
    required super.project,
    required super.latitude,
    required super.longitude,
    required super.radiusMeters,
    required super.address,
  });

  factory AttendanceLocationModel.fromJson(Map<String, dynamic> json) {
    return AttendanceLocationModel(
      name: _readString(json['name']),
      locationName: _readString(json['location_name']),
      locationType: _readString(json['location_type']),
      company: _readString(json['company']),
      branch: _readString(json['branch']),
      department: _readString(json['department']),
      project: _readString(json['project']),
      latitude: _readDouble(json['latitude']),
      longitude: _readDouble(json['longitude']),
      radiusMeters: _readDouble(json['radius_meters']) ?? 100,
      address: _readString(json['address']),
    );
  }
}

class LastCheckinModel extends LastCheckin {
  const LastCheckinModel({
    required super.name,
    required super.time,
    required super.logType,
    required super.attendanceLocation,
    required super.geofenceStatus,
  });

  factory LastCheckinModel.fromJson(Map<String, dynamic> json) {
    return LastCheckinModel(
      name: _readString(json['name']),
      time: _readDate(json['time']),
      logType: _readString(json['log_type']),
      attendanceLocation: _readString(json['attendance_location']),
      geofenceStatus: _readString(json['geofence_status']),
    );
  }
}

Map<String, dynamic> _extractPayload(Map<String, dynamic> json) {
  final message = json['message'];
  if (message is Map<String, dynamic>) return message;
  final data = json['data'];
  if (data is Map<String, dynamic>) return data;
  return json;
}

Map<String, dynamic> _readMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

String _readString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString();
  return text.isEmpty ? fallback : text;
}

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == '1' || text == 'true' || text == 'yes';
}

double? _readDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _readInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

DateTime? _readDate(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text) ??
      DateTime.tryParse(text.replaceFirst(' ', 'T'));
}
