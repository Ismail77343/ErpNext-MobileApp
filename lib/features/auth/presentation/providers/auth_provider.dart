import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/auth_session.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  AuthProvider(this.loginUseCase);

  bool _isInitializing = true;
  bool _isLoading = false;
  User? _user;
  String? _error;

  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  User? get user => _user;
  String? get error => _error;

  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;
      if (!rememberMe) return;

      final cookie = prefs.getString('session_cookie');
      final token = prefs.getString('session_token');
      final name = prefs.getString('session_user_name') ?? '';
      final email = prefs.getString('session_user_email') ?? '';
      final roles = prefs.getStringList('session_user_roles') ?? const <String>[];

      if ((cookie == null || cookie.isEmpty) &&
          (token == null || token.isEmpty)) {
        return;
      }

      AuthSession.saveCookie(cookie);
      AuthSession.saveToken(token);
      _user = User(name: name, email: email, roles: roles);
      AppLogger.auth('session restored for ${_user?.email ?? "unknown"}');
    } catch (e) {
      AppLogger.error('restore session failed: $e');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password, {bool rememberMe = false}) async {
    AppLogger.auth('auth provider login start');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await loginUseCase.call(email, password);
      _user = result;
      await _persistSession(rememberMe);
      AppLogger.auth('auth provider login success for ${result.email}');
    } catch (e) {
      _user = null;
      _error = e.toString();
      AppLogger.error('auth provider login failed: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    AppLogger.auth('logout start');
    AuthSession.clear();
    _clearPersistedSession();
    _user = null;
    AppLogger.auth('logout success, auth session cleared');
    notifyListeners();
  }

  Future<void> _persistSession(bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', rememberMe);

    if (!rememberMe || _user == null) {
      await _clearPersistedSession();
      return;
    }

    await prefs.setString('session_cookie', AuthSession.cookie ?? '');
    await prefs.setString('session_token', AuthSession.token ?? '');
    await prefs.setString('session_user_name', _user!.name);
    await prefs.setString('session_user_email', _user!.email);
    await prefs.setStringList('session_user_roles', _user!.roles);
  }

  Future<void> _clearPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remember_me');
    await prefs.remove('session_cookie');
    await prefs.remove('session_token');
    await prefs.remove('session_user_name');
    await prefs.remove('session_user_email');
    await prefs.remove('session_user_roles');
  }
}
