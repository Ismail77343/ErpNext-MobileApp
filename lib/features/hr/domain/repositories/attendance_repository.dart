import '../entities/attendance_context.dart';
import '../entities/employee_checkin_result.dart';

abstract class AttendanceRepository {
  Future<AttendanceContext> getAttendanceContext({
    String? project,
    String? deviceId,
    String? platform,
  });

  Future<EmployeeCheckinResult> createEmployeeCheckin({
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
  });

  Future<AttendanceDeviceVerification> requestMobileDeviceVerification({
    required String deviceId,
    required String deviceName,
    required String platform,
    required String appVersion,
    required String phoneNumber,
  });
}
