class EmployeeCheckinResult {
  final String name;
  final String employee;
  final String employeeName;
  final DateTime? time;
  final String logType;
  final String attendanceLocation;
  final double? distanceMeters;
  final String geofenceStatus;
  final bool photoRequired;
  final bool photoUploaded;
  final String photoUrl;

  const EmployeeCheckinResult({
    required this.name,
    required this.employee,
    required this.employeeName,
    required this.time,
    required this.logType,
    required this.attendanceLocation,
    required this.distanceMeters,
    required this.geofenceStatus,
    required this.photoRequired,
    required this.photoUploaded,
    required this.photoUrl,
  });
}
