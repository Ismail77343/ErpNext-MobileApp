class AuthSession {
  static String? _cookie;
  static String? _token;

  static String? get cookie => _cookie;
  static String? get token => _token;

  static bool get hasAuth =>
      (_cookie != null && _cookie!.isNotEmpty) ||
      (_token != null && _token!.isNotEmpty);

  static void saveCookieFromHeaders(Map<String, String> headers) {
    final setCookie = headers['set-cookie'];
    if (setCookie == null || setCookie.isEmpty) return;
    _cookie = setCookie.split(';').first;
  }

  static void saveCookie(String? cookie) {
    if (cookie == null || cookie.isEmpty) return;
    _cookie = cookie;
  }

  static void saveToken(String? token) {
    if (token == null || token.isEmpty) return;
    _token = token;
  }

  static Map<String, String> authHeaders({bool withJson = true}) {
    final headers = <String, String>{};
    if (withJson) headers['Content-Type'] = 'application/json';
    if (_cookie != null && _cookie!.isNotEmpty) headers['Cookie'] = _cookie!;
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static void clear() {
    _cookie = null;
    _token = null;
  }
}
