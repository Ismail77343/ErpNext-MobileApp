class AttendanceContext {
  final bool enabled;
  final AttendanceSettings settings;
  final AttendanceEmployee? employee;
  final List<AttendanceLocation> allowedLocations;
  final LastCheckin? lastCheckin;
  final AttendanceDeviceVerification deviceVerification;

  const AttendanceContext({
    required this.enabled,
    required this.settings,
    required this.employee,
    required this.allowedLocations,
    required this.lastCheckin,
    required this.deviceVerification,
  });

  bool get canCheckin => deviceVerification.canCheckin;
}

class AttendanceSettings {
  final bool requireGeoLocation;
  final bool enforceGeofence;
  final double defaultRadiusMeters;
  final bool allowManualNotes;
  final String defaultLogType;
  final bool skipAutoAttendance;
  final bool allowCheckinWithoutAssignment;
  final bool requireVerifiedMobileDevice;
  final bool allowMultipleVerifiedDevices;
  final String deviceVerificationApproverRole;
  final bool requireCheckinPhoto;
  final String photoRequiredFor;
  final int maxPhotoSizeKb;

  const AttendanceSettings({
    required this.requireGeoLocation,
    required this.enforceGeofence,
    required this.defaultRadiusMeters,
    required this.allowManualNotes,
    required this.defaultLogType,
    required this.skipAutoAttendance,
    required this.allowCheckinWithoutAssignment,
    required this.requireVerifiedMobileDevice,
    required this.allowMultipleVerifiedDevices,
    required this.deviceVerificationApproverRole,
    required this.requireCheckinPhoto,
    required this.photoRequiredFor,
    required this.maxPhotoSizeKb,
  });

  bool isPhotoRequiredFor(String logType) {
    if (!requireCheckinPhoto) return false;
    final normalizedRule = photoRequiredFor.trim().toLowerCase();
    final normalizedLogType = logType.trim().toUpperCase();

    if (normalizedRule == 'optional') return false;
    if (normalizedRule == 'in and out') return true;
    if (normalizedRule == 'in only') return normalizedLogType == 'IN';
    if (normalizedRule == 'out only') return normalizedLogType == 'OUT';
    return false;
  }
}

class AttendanceDeviceVerification {
  final bool required;
  final bool verified;
  final String status;
  final String requestName;
  final bool canRequest;
  final bool canCheckin;
  final String blockingReason;

  const AttendanceDeviceVerification({
    required this.required,
    required this.verified,
    required this.status,
    required this.requestName,
    required this.canRequest,
    required this.canCheckin,
    required this.blockingReason,
  });

  bool get isPending => blockingReason == 'PENDING_APPROVAL';
  bool get isRejected => blockingReason == 'DEVICE_REJECTED';
  bool get isRevoked => blockingReason == 'DEVICE_REVOKED';
  bool get isNotRequested =>
      blockingReason == 'DEVICE_NOT_VERIFIED' ||
      status.toLowerCase() == 'not requested';
}

class AttendanceEmployee {
  final String name;
  final String employeeName;
  final String department;
  final String branch;
  final String company;

  const AttendanceEmployee({
    required this.name,
    required this.employeeName,
    required this.department,
    required this.branch,
    required this.company,
  });
}

class AttendanceLocation {
  final String name;
  final String locationName;
  final String locationType;
  final String company;
  final String branch;
  final String department;
  final String project;
  final double? latitude;
  final double? longitude;
  final double radiusMeters;
  final String address;

  const AttendanceLocation({
    required this.name,
    required this.locationName,
    required this.locationType,
    required this.company,
    required this.branch,
    required this.department,
    required this.project,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.address,
  });

  bool get hasCoordinates => latitude != null && longitude != null;
}

class LastCheckin {
  final String name;
  final DateTime? time;
  final String logType;
  final String attendanceLocation;
  final String geofenceStatus;

  const LastCheckin({
    required this.name,
    required this.time,
    required this.logType,
    required this.attendanceLocation,
    required this.geofenceStatus,
  });

  bool get isIn => logType.toUpperCase() == 'IN';
}
