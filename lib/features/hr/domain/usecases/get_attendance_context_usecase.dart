import '../entities/attendance_context.dart';
import '../repositories/attendance_repository.dart';

class GetAttendanceContextUseCase {
  final AttendanceRepository repository;

  GetAttendanceContextUseCase(this.repository);

  Future<AttendanceContext> call({
    String? project,
    String? deviceId,
    String? platform,
  }) {
    return repository.getAttendanceContext(
      project: project,
      deviceId: deviceId,
      platform: platform,
    );
  }
}
