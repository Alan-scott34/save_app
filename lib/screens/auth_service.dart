import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_models.dart';

/// ============================================
/// AUTH SERVICE — Service d'authentification
/// ============================================
/// Gère l'état d'authentification de l'utilisateur.
/// Le backend est local pour le moment, ce qui permet
/// de tester avec des informations personnalisées.
/// ============================================

class AuthService extends ChangeNotifier {
  static const String _userPrefsKey = 'save_app_user';
  static const String _loggedInPrefsKey = 'save_app_logged_in';

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  UserModel? _user;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get user => _user;

  /// Charge les informations utilisateur enregistrées localement.
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userPrefsKey);
      final isLogged = prefs.getBool(_loggedInPrefsKey) ?? false;

      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _user = UserModel.fromMap(userMap);
      }

      _isLoggedIn = isLogged && _user != null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load saved user';
      notifyListeners();
    }
  }

  /// Se connecter avec email et mot de passe.
  Future<bool> login(
    String email,
    String password, {
    bool rememberMe = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userPrefsKey);

      if (userJson == null) {
        throw Exception('No account found. Please register first.');
      }

      final storedUser = UserModel.fromMap(jsonDecode(userJson));
      final passwordHash = _hashPassword(password);

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }
      if (storedUser.email.toLowerCase() != email.toLowerCase()) {
        throw Exception('No account found for this email');
      }
      if (storedUser.passwordHash != passwordHash) {
        throw Exception('Invalid password');
      }

      _user = storedUser;
      _isLoggedIn = true;
      await prefs.setBool(_loggedInPrefsKey, rememberMe);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Inscription avec email et mot de passe.
  Future<bool> register(String fullName, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('All fields are required');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      final user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName,
        email: email,
        passwordHash: _hashPassword(password),
        createdAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userPrefsKey, jsonEncode(user.toMap()));
      await prefs.setBool(_loggedInPrefsKey, true);

      _user = user;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Mot de passe oublié.
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (email.isEmpty) {
        throw Exception('Email is required');
      }

      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userPrefsKey);
      if (userJson == null) {
        throw Exception('No account found.');
      }

      final storedUser = UserModel.fromMap(jsonDecode(userJson));
      if (storedUser.email.toLowerCase() != email.toLowerCase()) {
        throw Exception('No account found for this email');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnexion.
  Future<void> logout() async {
    _isLoggedIn = false;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInPrefsKey, false);
    notifyListeners();
  }

  /// Effacer l'erreur.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _hashPassword(String password) {
    return base64Encode(utf8.encode(password));
  }
}
