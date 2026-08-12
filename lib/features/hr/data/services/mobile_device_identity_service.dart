import 'dart:io';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class MobileDeviceIdentity {
  final String deviceId;
  final String deviceName;
  final String platform;
  final String appVersion;

  const MobileDeviceIdentity({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.appVersion,
  });
}

class MobileDeviceIdentityService {
  static const _deviceIdKey = 'hr_mobile_device_id';

  Future<MobileDeviceIdentity> getIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_deviceIdKey);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _generateDeviceId();
      await prefs.setString(_deviceIdKey, deviceId);
    }

    return MobileDeviceIdentity(
      deviceId: deviceId,
      deviceName: _deviceName(),
      platform: _platform(),
      appVersion: '1.0.0+1',
    );
  }

  String _platform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return Platform.operatingSystem;
  }

  String _deviceName() {
    if (Platform.isAndroid) return 'Android Mobile Device';
    if (Platform.isIOS) return 'iOS Mobile Device';
    return 'ERP Mobile Device';
  }

  String _generateDeviceId() {
    final random = Random.secure();
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final suffix = List.generate(
      16,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
    return 'erp-$timestamp-$suffix';
  }
}
