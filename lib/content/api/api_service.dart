import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<http.Response> signIn(String email, String password) async {
    final url = Uri.parse(
        'https://test-z77zvpmgsa-uc.a.run.app/v1/tutors/auth/sign-in');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return response;
  }
}
