import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class AttendancePhotoCapture {
  final String base64;
  final String filename;
  final String mimeType;
  final double sizeKb;
  final String path;

  const AttendancePhotoCapture({
    required this.base64,
    required this.filename,
    required this.mimeType,
    required this.sizeKb,
    required this.path,
  });
}

class AttendancePhotoService {
  final ImagePicker _picker;

  AttendancePhotoService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  Future<AttendancePhotoCapture> captureFacePhoto({
    required String logType,
    required int maxSizeKb,
  }) async {
    final limit = maxSizeKb <= 0 ? 2048 : maxSizeKb;
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: _qualityForLimit(limit),
      maxWidth: 1280,
    );

    if (file == null) {
      throw Exception('Attendance face photo is required.');
    }

    final bytes = await file.readAsBytes();
    final sizeKb = bytes.length / 1024;
    if (sizeKb > limit) {
      throw Exception(
        'Attendance photo is too large (${sizeKb.toStringAsFixed(0)} KB). Maximum allowed size is $limit KB.',
      );
    }

    return AttendancePhotoCapture(
      base64: base64Encode(bytes),
      filename: _buildFilename(logType),
      mimeType: _mimeType(file.path),
      sizeKb: sizeKb,
      path: file.path,
    );
  }

  int _qualityForLimit(int maxSizeKb) {
    if (maxSizeKb <= 512) return 45;
    if (maxSizeKb <= 1024) return 60;
    if (maxSizeKb <= 2048) return 72;
    return 82;
  }

  String _buildFilename(String logType) {
    final now = DateTime.now();
    final stamp = [
      now.year.toString().padLeft(4, '0'),
      now.month.toString().padLeft(2, '0'),
      now.day.toString().padLeft(2, '0'),
      now.hour.toString().padLeft(2, '0'),
      now.minute.toString().padLeft(2, '0'),
      now.second.toString().padLeft(2, '0'),
    ].join('_');
    return 'attendance_${logType.toLowerCase()}_$stamp.jpg';
  }

  String _mimeType(String path) {
    final extension = path.split(Platform.pathSeparator).last.toLowerCase();
    if (extension.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }
}
