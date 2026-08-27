import '../../domain/entities/attendance_context.dart';
import '../../domain/entities/employee_checkin_result.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl(this.remoteDataSource);

  @override
  Future<AttendanceContext> getAttendanceContext({
    String? project,
    String? deviceId,
    String? platform,
  }) {
    return remoteDataSource.getAttendanceContext(
      project: project,
      deviceId: deviceId,
      platform: platform,
    );
  }

  @override
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
    bool? isMockLocation,
    bool? vpnDetected,
    bool? rootOrJailbreakDetected,
    List<String>? securityFlags,
    String? securityRiskLevel,
  }) {
    return remoteDataSource.createEmployeeCheckin(
      logType: logType,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      attendanceLocation: attendanceLocation,
      deviceId: deviceId,
      notes: notes,
      project: project,
      photoBase64: photoBase64,
      photoFilename: photoFilename,
      photoMimeType: photoMimeType,
      isMockLocation: isMockLocation,
      vpnDetected: vpnDetected,
      rootOrJailbreakDetected: rootOrJailbreakDetected,
      securityFlags: securityFlags,
      securityRiskLevel: securityRiskLevel,
    );
  }

  @override
  Future<AttendanceDeviceVerification> requestMobileDeviceVerification({
    required String deviceId,
    required String deviceName,
    required String platform,
    required String appVersion,
    required String phoneNumber,
  }) {
    return remoteDataSource.requestMobileDeviceVerification(
      deviceId: deviceId,
      deviceName: deviceName,
      platform: platform,
      appVersion: appVersion,
      phoneNumber: phoneNumber,
    );
  }
}
