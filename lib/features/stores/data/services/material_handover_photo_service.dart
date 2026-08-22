import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../domain/entities/material_handover_photo.dart';

class MaterialHandoverPhotoService {
  MaterialHandoverPhotoService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<MaterialHandoverPhoto> captureEvidence({
    required String action,
    int maxSizeKb = 2048,
  }) async {
    final limit = maxSizeKb <= 0 ? 2048 : maxSizeKb;
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: _qualityForLimit(limit),
      maxWidth: 1600,
    );

    if (file == null) {
      throw Exception('Photo is required to continue.');
    }

    final bytes = await file.readAsBytes();
    final sizeKb = bytes.length / 1024;
    if (sizeKb > limit) {
      throw Exception(
        'Photo is too large (${sizeKb.toStringAsFixed(0)} KB). Maximum allowed size is $limit KB.',
      );
    }

    return MaterialHandoverPhoto(
      base64: base64Encode(bytes),
      filename: _filename(action, file.path),
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

  String _filename(String action, String path) {
    final now = DateTime.now();
    final ext = path.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
    final stamp = [
      now.year.toString().padLeft(4, '0'),
      now.month.toString().padLeft(2, '0'),
      now.day.toString().padLeft(2, '0'),
      now.hour.toString().padLeft(2, '0'),
      now.minute.toString().padLeft(2, '0'),
      now.second.toString().padLeft(2, '0'),
    ].join('_');
    return 'material_handover_${action.toLowerCase()}_$stamp.$ext';
  }

  String _mimeType(String path) {
    final name = path.split(Platform.pathSeparator).last.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }
}
