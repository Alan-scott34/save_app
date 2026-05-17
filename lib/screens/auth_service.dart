import 'package:flutter/material.dart';

/// ============================================
/// AUTH SERVICE — Service d'authentification
/// ============================================
/// Gère l'état d'authentification de l'utilisateur.
/// Pour l'instant, c'est un stub (mock) qui sera
/// connecté à Firebase Auth plus tard.
///
/// 💡 Pourquoi un service séparé ?
/// → Séparation des responsabilités (SRP)
/// → Facile à tester (on peut mock ce service)
/// → Facile à remplacer (Firebase → Supabase, etc.)
/// ============================================

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _user;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;

  /// Connexion avec email et mot de passe
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Remplacer par Firebase Auth
      await Future.delayed(const Duration(seconds: 2)); // Simulation

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      _user = {'id': 'user_001', 'fullName': 'John Doe', 'email': email};
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

  /// Inscription avec email et mot de passe
  Future<bool> register(String fullName, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('All fields are required');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      _user = {'id': 'user_001', 'fullName': fullName, 'email': email};
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

  /// Mot de passe oublié
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (email.isEmpty) {
        throw Exception('Email is required');
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

  /// Déconnexion
  Future<void> logout() async {
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }

  /// Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
