import '../entities/attendance_context.dart';
import '../repositories/attendance_repository.dart';

class RequestMobileDeviceVerificationUseCase {
  final AttendanceRepository repository;

  RequestMobileDeviceVerificationUseCase(this.repository);

  Future<AttendanceDeviceVerification> call({
    required String deviceId,
    required String deviceName,
    required String platform,
    required String appVersion,
    required String phoneNumber,
  }) {
    return repository.requestMobileDeviceVerification(
      deviceId: deviceId,
      deviceName: deviceName,
      platform: platform,
      appVersion: appVersion,
      phoneNumber: phoneNumber,
    );
  }
}
