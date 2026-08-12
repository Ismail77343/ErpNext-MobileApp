import '../../domain/entities/employee_checkin_result.dart';

class EmployeeCheckinResultModel extends EmployeeCheckinResult {
  const EmployeeCheckinResultModel({
    required super.name,
    required super.employee,
    required super.employeeName,
    required super.time,
    required super.logType,
    required super.attendanceLocation,
    required super.distanceMeters,
    required super.geofenceStatus,
    required super.photoRequired,
    required super.photoUploaded,
    required super.photoUrl,
  });

  factory EmployeeCheckinResultModel.fromJson(Map<String, dynamic> json) {
    final root = _extractPayload(json);
    final checkin = root['checkin'] is Map<String, dynamic>
        ? root['checkin'] as Map<String, dynamic>
        : root;

    return EmployeeCheckinResultModel(
      name: _readString(checkin['name']),
      employee: _readString(checkin['employee']),
      employeeName: _readString(checkin['employee_name']),
      time: _readDate(checkin['time']),
      logType: _readString(checkin['log_type']),
      attendanceLocation: _readString(checkin['attendance_location']),
      distanceMeters: _readDouble(checkin['distance_meters']),
      geofenceStatus: _readString(checkin['geofence_status']),
      photoRequired: _readBool(checkin['photo_required']),
      photoUploaded: _readBool(checkin['photo_uploaded']),
      photoUrl: _readString(checkin['photo_url']),
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

String _readString(dynamic value) => value?.toString() ?? '';

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

DateTime? _readDate(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text) ??
      DateTime.tryParse(text.replaceFirst(' ', 'T'));
}
