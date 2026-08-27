import 'dart:io';

import 'package:flutter/services.dart';

class AttendanceDeviceRiskResult {
  final bool isMockLocation;
  final bool vpnDetected;
  final bool rootOrJailbreakDetected;
  final bool developerModeDetected;
  final List<String> flags;

  const AttendanceDeviceRiskResult({
    required this.isMockLocation,
    required this.vpnDetected,
    required this.rootOrJailbreakDetected,
    required this.developerModeDetected,
    required this.flags,
  });

  bool get hasRisk => flags.isNotEmpty;
  String get riskLevel => hasRisk ? 'high' : 'low';

  String get blockingMessage {
    if (isMockLocation) {
      return 'Fake location detected. Attendance is blocked for security reasons.';
    }
    if (vpnDetected) {
      return 'VPN connection detected. Attendance is blocked for security reasons.';
    }
    if (rootOrJailbreakDetected) {
      return 'Rooted or jailbroken device detected. Attendance is blocked for security reasons.';
    }
    if (developerModeDetected) {
      return 'Developer mode is enabled. Attendance is blocked for security reasons.';
    }
    return 'Attendance is blocked for security reasons.';
  }
}

class AttendanceDeviceRiskService {
  static const MethodChannel _channel = MethodChannel(
    'tpg_nexus/attendance_security',
  );

  Future<AttendanceDeviceRiskResult> evaluate({
    required bool isMockLocation,
  }) async {
    final vpnDetected = await _isVpnDetected();
    final native = await _readNativeRisk();
    final rootOrJailbreakDetected =
        _readBool(native['root_or_jailbreak_detected']);
    final developerModeDetected = _readBool(native['developer_mode_detected']);
    final nativeMockDetected = _readBool(native['mock_location_enabled']);

    final flags = <String>[
      if (isMockLocation || nativeMockDetected) 'mock_location',
      if (vpnDetected) 'vpn_detected',
      if (rootOrJailbreakDetected) 'root_or_jailbreak_detected',
      if (developerModeDetected) 'developer_mode_detected',
    ];

    return AttendanceDeviceRiskResult(
      isMockLocation: isMockLocation || nativeMockDetected,
      vpnDetected: vpnDetected,
      rootOrJailbreakDetected: rootOrJailbreakDetected,
      developerModeDetected: developerModeDetected,
      flags: flags,
    );
  }

  Future<bool> _isVpnDetected() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.any,
      );
      const vpnMarkers = ['tun', 'ppp', 'wg', 'ipsec', 'utun'];
      return interfaces.any((networkInterface) {
        final name = networkInterface.name.toLowerCase();
        return vpnMarkers.any((marker) => name.contains(marker));
      });
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _readNativeRisk() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'getAttendanceSecurityRisk',
      );
      return result ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  bool _readBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim();
    return text == 'true' || text == '1' || text == 'yes';
  }
}
