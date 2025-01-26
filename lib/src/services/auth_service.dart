import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'socket_service.dart';

class AuthService {
  static const String _loginEndpoint = '/api/auth/login';

  /// Sign in with email and password.
  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final data = {
      'username': email,
      'password': password,
      'mobile_no': "",
    };

    final headers = {
      'Authorization': '77654AADE331DFECED6FC14341B305E8',
    };

    try {
      final response = await ApiService.post(_loginEndpoint, data, headers);

      if (response.containsKey('data')) {
        final data = response['data'];
        if (data.containsKey('token') &&
            data.containsKey('user_id') &&
            data.containsKey('company_id') &&
            data.containsKey('role_id')) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', data['token']);
          await prefs.setString('userId', data['user_id'].toString());
          await prefs.setString('companyId', data['company_id'].toString());
          await prefs.setString('roleId', data['role_id'].toString());
          await ApiService.setAuthorizationHeader();
        } else {
          throw Exception('Invalid response structure: Missing keys in "data".');
        }
      } else {
        throw Exception('Invalid response: "data" key not found.');
      }
    } catch (error) {
      throw Exception('Login failed: $error');
    }
  }

  /// Check if user is signed in.
  static Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('authToken');
  }

  /// Retrieve user details.
  static Future<Map<String, String>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'authToken': prefs.getString('authToken') ?? '',
      'userId': prefs.getString('userId') ?? '',
      'companyId': prefs.getString('companyId') ?? '',
      'roleId': prefs.getString('roleId') ?? '',
    };
  }

  /// Sign out and clear all stored data.
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userId');
    await prefs.remove('companyId');
    await prefs.remove('roleId');
    await prefs.remove('dismissedAlertIds');
    final socketService = SocketService();
    socketService.disconnectAll();
  }

  /// Validate token with the server.
  // static Future<bool> isTokenValid() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('authToken');
  //   if (token == null || token.isEmpty) return false;
  //
  //   try {
  //     final response = await ApiService.get('/api/auth/validate-token');
  //     return response['isValid'] ?? false;
  //   } catch (error) {
  //     return false;
  //   }
  // }
}
