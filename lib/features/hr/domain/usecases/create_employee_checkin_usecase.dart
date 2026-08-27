import '../entities/employee_checkin_result.dart';
import '../repositories/attendance_repository.dart';

class CreateEmployeeCheckinUseCase {
  final AttendanceRepository repository;

  CreateEmployeeCheckinUseCase(this.repository);

  Future<EmployeeCheckinResult> call({
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
    return repository.createEmployeeCheckin(
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
}
