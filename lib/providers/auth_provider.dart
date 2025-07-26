import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _rememberMe = false;
  String _username = '';
  String _password = '';

  final _secureStorage = FlutterSecureStorage();

  bool get isLoggedIn => _isLoggedIn;
  bool get rememberMe => _rememberMe;
  String get username => _username;
  String get password => _password;

  AuthProvider() {
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool('rememberMe') ?? false;
    if (_rememberMe) {
      _username = prefs.getString('username') ?? '';
      _password = prefs.getString('password') ?? '';
    }
    notifyListeners();
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('username', _username);
      await prefs.setString('password', _password);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('username');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }
  }

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  Future<bool> login() async {
    try {
      final baseUrl = kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000';
      final url = Uri.parse('$baseUrl/login');  // your backend login route

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _username,
          'password': _password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        _isLoggedIn = true;
        await _secureStorage.write(key: 'jwt', value: token);
        await _saveCredentials();
        notifyListeners();
        return true;
      } else {
        _isLoggedIn = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Login error: $e");
      _isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    _secureStorage.delete(key: 'jwt');
    notifyListeners();
  }

  Future<bool> register({
    required String username,
    required String password,
    required String email,
    required int roleId,
  }) async {
    try {
      final baseUrl = kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000';
      final url = Uri.parse('$baseUrl/register');  // your backend register route

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
          'roleId': roleId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Registered successfully");
        return true;
      } else {
        print("❌ Register failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Register error: $e");
      return false;
    }
  }
}
