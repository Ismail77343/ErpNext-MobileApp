import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  String? sessionCookie;

  ApiClient(this.baseUrl);

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/method/login"),
      body: {
        "usr": email,
        "pwd": password,
      },
    );

    if (response.statusCode == 200) {
      sessionCookie = response.headers['set-cookie'];
    } else {
      throw Exception("Login failed");
    }
  }

  Future<http.Response> get(String endpoint) {
    return http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Cookie": sessionCookie ?? "",
      },
    );
  }

  Future<http.Response> post(String endpoint, Map body) {
    return http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Cookie": sessionCookie ?? "",
      },
      body: body,
    );
  }
}
