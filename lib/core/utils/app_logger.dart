import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String message) {
    debugPrint('[INFO] $message');
  }

  static void auth(String message) {
    debugPrint('[AUTH] $message');
  }

  static void project(String message) {
    debugPrint('[PROJECT] $message');
  }

  static void nav(String message) {
    debugPrint('[NAV] $message');
  }

  static void error(String message) {
    debugPrint('[ERROR] $message');
  }
}
