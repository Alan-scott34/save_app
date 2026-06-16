import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages application-wide settings such as theme mode and currency.
class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _currency = 'USD'; // Default currency
  String _userName = "User";
  String _password = "password123"; // Placeholder for local logic

  ThemeMode get themeMode => _themeMode;
  String get currency => _currency;
  String get userName => _userName;
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
    _password = prefs.getString('password') ?? 'password123';
    notifyListeners();
  }

  /// Updates user profile info
  Future<void> updateProfile(String newName, String newPassword) async {
    _userName = newName;
    _password = newPassword;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName);
    await prefs.setString('password', newPassword);
    notifyListeners();
  }

  /// Updates only the application password and persists it.
  Future<void> updatePassword(String newPassword) async {
    _password = newPassword;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', newPassword);
    notifyListeners();
  }

  /// Custom Dark Theme Definition
  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.indigo,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 24,
    ),
  );

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
