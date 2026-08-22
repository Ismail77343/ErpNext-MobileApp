import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _languageCodeKey = 'preferred_language_code';

  Locale? _locale;
  bool _isLoaded = false;

  Locale? get locale => _locale;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_languageCodeKey);
    _locale = code == null || code.isEmpty ? null : Locale(code);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    _locale = locale;
    if (locale == null) {
      await prefs.remove(_languageCodeKey);
    } else {
      await prefs.setString(_languageCodeKey, locale.languageCode);
    }
    notifyListeners();
  }
}
