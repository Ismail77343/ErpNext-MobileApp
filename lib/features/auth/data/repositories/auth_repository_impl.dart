import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/auth_session.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<User> login(String email, String password) async {
    AppLogger.auth('auth repository: login request started');
    final response = await http.post(
      ApiConstants.uri(ApiConstants.loginEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    AppLogger.auth('auth repository: login response ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Login failed with status: ${response.statusCode}');
    }

    AuthSession.saveCookieFromHeaders(response.headers);

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid login response');
    }

    final payload = _extractPayload(decoded);
    final status = payload['status']?.toString().toLowerCase();
    if (status == 'success' || !payload.containsKey('status')) {
      final sid = payload['sid']?.toString();
      if (sid != null && sid.isNotEmpty) {
        AuthSession.saveCookie('sid=$sid');
      }

      final token = payload['token']?.toString();
      if (token != null && token.isNotEmpty) {
        AuthSession.saveToken(token);
      }

      if (!AuthSession.hasAuth) {
        AppLogger.auth('auth repository: no session returned, trying fallback');
        await _establishSession(email, password);
      }

      AppLogger.auth('auth repository: login completed successfully');
      return User.fromJson(payload);
    }

    throw Exception(payload['message']?.toString() ?? 'Login failed');
  }

  Map<String, dynamic> _extractPayload(Map<String, dynamic> decoded) {
    final message = decoded['message'];
    if (message is Map<String, dynamic>) return message;

    final data = decoded['data'];
    if (data is Map<String, dynamic>) return data;

    return decoded;
  }

  Future<void> _establishSession(String email, String password) async {
    AppLogger.auth('auth repository: fallback session login started');
    final response = await http.post(
      ApiConstants.uri(ApiConstants.sessionLoginEndpoint),
      body: {'usr': email, 'pwd': password},
    );
    AppLogger.auth(
      'auth repository: fallback session response ${response.statusCode}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Login succeeded but session failed: ${response.statusCode}',
      );
    }

    AuthSession.saveCookieFromHeaders(response.headers);
    if (!AuthSession.hasAuth) {
      throw Exception('Login succeeded but no auth session was returned');
    }
  }
}
