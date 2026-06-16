import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages application-wide settings such as theme mode and currency.
class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _currency = 'USD'; // Default currency
  String _userName = "User";
  String _userEmail = "user@example.com";
  String _password = "password123"; // Placeholder for local logic

  ThemeMode get themeMode => _themeMode;
  String get currency => _currency;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get password => _password;

  SettingsProvider() {
    _loadSettings();
  }

  /// Loads saved settings from SharedPreferences.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex =
        prefs.getInt('themeMode') ?? 0; // 0: system, 1: light, 2: dark
    _themeMode = ThemeMode.values[themeIndex];
    _currency = prefs.getString('currency') ?? 'USD';
    _userName = prefs.getString('userName') ?? 'User';
    _userEmail = prefs.getString('userEmail') ?? 'user@example.com';
    _password = prefs.getString('password') ?? 'password123';
    notifyListeners();
  }

  /// Updates user profile info
  Future<void> updateProfile({
    required String newName,
    required String newEmail,
  }) async {
    if (newName.isEmpty || !newEmail.contains('@')) return;
    _userName = newName;
    _userEmail = newEmail;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName);
    await prefs.setString('userEmail', newEmail);
    notifyListeners();
  }

  /// Updates only the application password and persists it.
  Future<void> updatePassword(String newPassword) async {
    _password = newPassword;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', newPassword);
    notifyListeners();
  }

  /// Logic to determine greeting based on system time (Requirement 11)
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 18) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  /// Custom Dark Theme Definition
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.emerald,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      cardTheme: CardTheme(
        color: const Color(0xFF1E293B),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        elevation: 0,
      ),
    );
  }

  /// Sets the application's theme mode and persists it.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  /// Sets the application's currency and persists it.
  Future<void> setCurrency(String newCurrency) async {
    if (_currency == newCurrency) return;
    _currency = newCurrency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', newCurrency);
    notifyListeners();
  }
}
