import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/pref_service.dart';

/// Manages the authentication state of the app.
/// Stores the currently logged-in user and provides login/logout methods.
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoadingSession = true;

  bool get isLoadingSession => _isLoadingSession;

  /// The currently logged-in user, or null if not logged in.
  User? get currentUser => _currentUser;

  /// Whether a user is currently logged in.
  bool get isLoggedIn => _currentUser != null;

  /// The user's display name.
  String get userName => _currentUser?.nom ?? 'Utilisateur';

  /// The user's email.
  String get userEmail => _currentUser?.email ?? '';

  /// The user's ID.
  int get userId => _currentUser?.id ?? 0;

  /// Loads the session from SharedPreferences on app start.
  Future<void> loadSession() async {
    _isLoadingSession = true;
    notifyListeners();

    _currentUser = await PrefService.loadUser();

    _isLoadingSession = false;
    notifyListeners();
  }

  /// Sets the current user after a successful login.
  void login(User user) {
    _currentUser = user;
    PrefService.saveUser(user);
    notifyListeners();
  }

  /// Sets the current user from a JSON response (login/register API).
  void loginFromJson(Map<String, dynamic> json) {
    _currentUser = User.fromJson(json);
    PrefService.saveUser(_currentUser!);
    notifyListeners();
  }

  /// Updates the current user's profile info.
  void updateProfile({String? nom, String? email}) {
    if (_currentUser == null) return;
    _currentUser = User(
      id: _currentUser!.id,
      nom: nom ?? _currentUser!.nom,
      email: email ?? _currentUser!.email,
      role: _currentUser!.role,
    );
    notifyListeners();
  }

  /// Logs out the current user and clears the session.
  void logout() {
    _currentUser = null;
    PrefService.clearUser();
    notifyListeners();
  }
}
