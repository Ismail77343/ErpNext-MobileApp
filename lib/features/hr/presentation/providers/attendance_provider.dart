import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;

import '../../data/services/attendance_location_service.dart' as gps;
import '../../data/services/attendance_photo_service.dart';
import '../../data/services/attendance_security_service.dart';
import '../../data/services/mobile_device_identity_service.dart';
import '../../domain/entities/attendance_context.dart';
import '../../domain/entities/employee_checkin_result.dart';
import '../../domain/usecases/create_employee_checkin_usecase.dart';
import '../../domain/usecases/get_attendance_context_usecase.dart';
import '../../domain/usecases/request_mobile_device_verification_usecase.dart';

class AttendanceActionPreview {
  final String logType;
  final gps.AttendanceLocation position;
  final AttendanceLocation? selectedLocation;
  final double? distanceMeters;
  final AttendancePhotoCapture? photo;
  final bool photoRequired;

  const AttendanceActionPreview({
    required this.logType,
    required this.position,
    required this.selectedLocation,
    required this.distanceMeters,
    required this.photo,
    required this.photoRequired,
  });

  bool get isOutsideRange {
    final location = selectedLocation;
    final distance = distanceMeters;
    if (location == null || distance == null) return false;
    return distance > location.radiusMeters;
  }
}

class AttendanceProvider extends ChangeNotifier {
  final GetAttendanceContextUseCase getAttendanceContextUseCase;
  final CreateEmployeeCheckinUseCase createEmployeeCheckinUseCase;
  final RequestMobileDeviceVerificationUseCase
  requestMobileDeviceVerificationUseCase;
  final AttendanceSecurityService securityService;
  final gps.AttendanceLocationService locationService;
  final MobileDeviceIdentityService deviceIdentityService;
  final AttendancePhotoService photoService;

  AttendanceProvider({
    required this.getAttendanceContextUseCase,
    required this.createEmployeeCheckinUseCase,
    required this.requestMobileDeviceVerificationUseCase,
    required this.securityService,
    required this.locationService,
    required this.deviceIdentityService,
    required this.photoService,
  });

  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;
  AttendanceContext? _context;
  AttendanceLocation? _selectedLocation;
  EmployeeCheckinResult? _lastResult;
  MobileDeviceIdentity? _deviceIdentity;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  AttendanceContext? get contextData => _context;
  AttendanceLocation? get selectedLocation => _selectedLocation;
  EmployeeCheckinResult? get lastResult => _lastResult;
  MobileDeviceIdentity? get deviceIdentity => _deviceIdentity;

  bool get isCheckedIn => _context?.lastCheckin?.isIn ?? false;
  bool get hasEmployee => _context?.employee != null;
  bool get isEnabled => _context?.enabled ?? false;
  bool get canCheckWithoutAssignment =>
      _context?.settings.allowCheckinWithoutAssignment ?? false;
  bool get hasAllowedLocation => _context?.allowedLocations.isNotEmpty ?? false;
  bool get canSubmitAttendance {
    final context = _context;
    if (context == null || !context.enabled || context.employee == null) {
      return false;
    }
    if (!context.canCheckin) return false;
    if (!hasAllowedLocation &&
        !context.settings.allowCheckinWithoutAssignment) {
      return false;
    }
    return true;
  }

  AttendanceDeviceVerification? get deviceVerification =>
      _context?.deviceVerification;

  bool get canOpenAttendance {
    final verification = deviceVerification;
    return verification == null ||
        !verification.required ||
        verification.canCheckin;
  }

  String get nextLogType => isCheckedIn ? 'OUT' : 'IN';

  Future<void> load({String? project}) async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      _deviceIdentity = await deviceIdentityService.getIdentity();
      _context = await getAttendanceContextUseCase(
        project: project,
        deviceId: _deviceIdentity?.deviceId,
        platform: _deviceIdentity?.platform,
      );
      _selectedLocation = _chooseSelectedLocation(_context!, _selectedLocation);
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<bool> requestDeviceVerification(String phoneNumber) async {
    final cleanPhone = phoneNumber.trim();
    if (cleanPhone.isEmpty) {
      _error = 'Phone number is required to request device verification.';
      _safeNotifyListeners();
      return false;
    }

    _isProcessing = true;
    _error = null;
    _safeNotifyListeners();

    try {
      final identity =
          _deviceIdentity ?? await deviceIdentityService.getIdentity();
      _deviceIdentity = identity;
      await requestMobileDeviceVerificationUseCase(
        deviceId: identity.deviceId,
        deviceName: identity.deviceName,
        platform: identity.platform,
        appVersion: identity.appVersion,
        phoneNumber: cleanPhone,
      );
      await load();
      return true;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _isProcessing = false;
      _safeNotifyListeners();
    }
  }

  void selectLocation(AttendanceLocation location) {
    _selectedLocation = location;
    _safeNotifyListeners();
  }

  Future<AttendanceActionPreview?> prepareAttendanceAction() async {
    if (!canSubmitAttendance) {
      _error = _disabledReason();
      _safeNotifyListeners();
      return null;
    }

    _isProcessing = true;
    _error = null;
    _safeNotifyListeners();

    try {
      await securityService.verifyDeviceOwner();
      final position = await locationService.getCurrentLocation();
      final distance = _distanceToSelectedLocation(position);
      final photoRequired = _isPhotoRequiredFor(nextLogType);
      final photo = photoRequired
          ? await photoService.captureFacePhoto(
              logType: nextLogType,
              maxSizeKb: _context?.settings.maxPhotoSizeKb ?? 2048,
            )
          : null;

      return AttendanceActionPreview(
        logType: nextLogType,
        position: position,
        selectedLocation: _selectedLocation,
        distanceMeters: distance,
        photo: photo,
        photoRequired: photoRequired,
      );
    } catch (e) {
      _error = _cleanError(e);
      return null;
    } finally {
      _isProcessing = false;
      _safeNotifyListeners();
    }
  }

  Future<bool> submitAttendanceAction(
    AttendanceActionPreview preview, {
    String? notes,
    String? project,
  }) async {
    _isProcessing = true;
    _error = null;
    _safeNotifyListeners();

    try {
      _lastResult = await createEmployeeCheckinUseCase(
        logType: preview.logType,
        latitude: preview.position.latitude,
        longitude: preview.position.longitude,
        accuracy: preview.position.accuracy,
        attendanceLocation: preview.selectedLocation?.name,
        notes: notes,
        project: project,
        deviceId: _deviceIdentity?.deviceId,
        photoBase64: preview.photo?.base64,
        photoFilename: preview.photo?.filename,
        photoMimeType: preview.photo?.mimeType,
      );
      await load(project: project);
      return true;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _isProcessing = false;
      _safeNotifyListeners();
    }
  }

  AttendanceLocation? _chooseSelectedLocation(
    AttendanceContext context,
    AttendanceLocation? current,
  ) {
    if (context.allowedLocations.isEmpty) return null;
    if (current != null &&
        context.allowedLocations.any((item) => item.name == current.name)) {
      return current;
    }
    return context.allowedLocations.first;
  }

  double? _distanceToSelectedLocation(gps.AttendanceLocation position) {
    final location = _selectedLocation;
    if (location == null || !location.hasCoordinates) return null;

    return geo.Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      location.latitude!,
      location.longitude!,
    );
  }

  bool _isPhotoRequiredFor(String logType) {
    return _context?.settings.isPhotoRequiredFor(logType) ?? false;
  }

  String _disabledReason() {
    final context = _context;
    if (context == null) return 'Attendance context is not loaded.';
    if (!context.enabled) return 'Attendance from mobile is disabled.';
    if (context.employee == null) {
      return 'No active employee is linked to your user.';
    }
    if (!context.canCheckin) {
      return _deviceVerificationMessage(context.deviceVerification);
    }
    if (!hasAllowedLocation &&
        !context.settings.allowCheckinWithoutAssignment) {
      return 'No attendance location assigned.';
    }
    return 'Attendance action is not available.';
  }

  String deviceVerificationMessage() {
    final verification = deviceVerification;
    if (verification == null || !verification.required) {
      return 'This device does not require HR approval.';
    }
    return _deviceVerificationMessage(verification);
  }

  String _deviceVerificationMessage(AttendanceDeviceVerification verification) {
    if (verification.canCheckin || verification.verified) {
      return 'This device is approved for mobile attendance.';
    }
    if (verification.isPending) {
      return 'Your mobile device verification request is pending HR approval.';
    }
    if (verification.isRejected) {
      return 'Your mobile device verification request was rejected. You can request verification again if allowed.';
    }
    if (verification.isRevoked) {
      return 'This mobile device approval was revoked. Please request verification again.';
    }
    if (verification.isNotRequested) {
      return 'Please request mobile device verification before using attendance.';
    }
    return verification.blockingReason.isNotEmpty
        ? verification.blockingReason
        : 'Mobile device verification is required.';
  }

  String _cleanError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ')
        ? text.substring('Exception: '.length)
        : text;
  }

  void _safeNotifyListeners() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
