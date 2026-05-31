import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

/// Service to manage SharedPreferences for offline session persistence.
class PrefService {
  static const String _userKey = 'cached_user';

  /// Saves the current user to SharedPreferences.
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final String userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  /// Loads the cached user from SharedPreferences, if any.
  static Future<User?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(userJson);
        return User.fromJson(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Removes the cached user (Logout).
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
