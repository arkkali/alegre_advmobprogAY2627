import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  Future<User> loginUser(String username, String password) async {
    // Activity 4 demo account: keep the requested project identity available
    // even though DummyJSON's public sample users do not include Arkkali.
    if (username == 'arkkali' && password == 'arkkali123') {
      const user = User(
        id: 1,
        username: 'arkkali',
        email: 'arkkali@email.com',
        firstName: 'Arkkali',
        lastName: '',
        gender: 'female',
        image: '',
        accessToken: 'arkkali-demo-token',
        refreshToken: '',
      );
      await saveUserData(user);
      return user;
    }

    final response = await http.post(
      Uri.parse('$host/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Invalid username or password');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final user = User.fromJson(data);
    await saveUserData(user);
    return user;
  }

  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    await prefs.setInt('userId', user.id);
    await prefs.setString('accessToken', user.accessToken);
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString('user');
    if (savedUser == null || savedUser.isEmpty) return null;
    final saved = User.fromJson(jsonDecode(savedUser) as Map<String, dynamic>);
    if (saved.username != 'arkkali') return null;

    final user = saved.copyWith(
      username: 'arkkali',
      firstName: 'Arkkali',
      email: 'arkkali@email.com',
    );
    await saveUserData(user);
    return user;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}