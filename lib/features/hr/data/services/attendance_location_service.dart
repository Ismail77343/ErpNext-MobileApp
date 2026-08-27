import 'package:geolocator/geolocator.dart';

class AttendanceLocation {
  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isMocked;

  const AttendanceLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.isMocked,
  });
}

class AttendanceLocationService {
  Future<AttendanceLocation> getCurrentLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Enable it from settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return AttendanceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      isMocked: position.isMocked,
    );
  }
}
