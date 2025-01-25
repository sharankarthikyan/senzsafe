import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:senzsafe/src/services/auth_service.dart';

class ApiService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  static Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
  };

  /// Add or update headers globally
  static Future<void> setAuthorizationHeader() async {
    final userDetails = await AuthService.getUserDetails();
    final token = userDetails['authToken'] ?? ''; // Replace with token logic
    if (token.isNotEmpty) {
      _defaultHeaders['Authorization'] = 'Bearer $token';
    }
  }

  /// GET Request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(
      url,
      headers: _defaultHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  /// POST Request
  static Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> data, [
        Map<String, String>? headers,
      ]) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final mergedHeaders = {..._defaultHeaders, if (headers != null) ...headers};

    final response = await http.post(
      url,
      headers: mergedHeaders,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
