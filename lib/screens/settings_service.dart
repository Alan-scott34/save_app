import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

/// ============================================
/// SETTINGS SERVICE — Service de gestion des paramètres
/// ============================================
/// Persiste les préférences de l'utilisateur :
/// - Thème (Clair/Sombre/Système)
/// - Langue
/// - Devise
/// - Format de date
/// - Notifications
/// ============================================

class SettingsService extends ChangeNotifier {
  static const String _themeModeKey = 'app_theme_mode';
  static const String _languageKey = 'app_language';
  static const String _currencyKey = 'app_currency';
  static const String _dateFormatKey = 'app_date_format';
  static const String _notificationsKey = 'app_notifications_enabled';
  static const String _remindersKey = 'app_reminders_enabled';
  static const String _alertsKey = 'app_alerts_enabled';
  static const String _achievementsKey = 'app_achievements_enabled';
  static const String _geminiApiKeyKey = 'app_gemini_api_key';
  static const String _avatarPathKey = 'app_avatar_path';

  late SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  AppLanguage _language = AppLanguage.english;
  Currency _currency = Currency.xaf;
  String _dateFormat = 'dd/MM/yyyy';
  bool _notificationsEnabled = true;
  bool _remindersEnabled = true;
  bool _alertsEnabled = true;
  bool _achievementsEnabled = true;
  String _geminiApiKey = '';
  String _avatarPath = '';

  // Getters
  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;
  Currency get currency => _currency;
  String get dateFormat => _dateFormat;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get remindersEnabled => _remindersEnabled;
  bool get alertsEnabled => _alertsEnabled;
  bool get achievementsEnabled => _achievementsEnabled;
  String get geminiApiKey => _geminiApiKey;
  bool get hasGeminiApiKey => _geminiApiKey.isNotEmpty;
  String get avatarPath => _avatarPath;
  bool get hasAvatar => _avatarPath.isNotEmpty;

  /// Initialiser avec SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  /// Charger les paramètres depuis SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final themeModeIndex =
          _prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
      _themeMode = ThemeMode.values[themeModeIndex];

      final languageCode = _prefs.getString(_languageKey) ?? 'en';
      _language = AppLanguage.values.firstWhere(
        (l) => l.code == languageCode,
        orElse: () => AppLanguage.english,
      );

      final currencyCode = _prefs.getString(_currencyKey) ?? 'XAF';
      _currency = Currency.values.firstWhere(
        (c) => c.code == currencyCode,
        orElse: () => Currency.xaf,
      );

      _dateFormat = _prefs.getString(_dateFormatKey) ?? 'dd/MM/yyyy';
      _notificationsEnabled = _prefs.getBool(_notificationsKey) ?? true;
      _remindersEnabled = _prefs.getBool(_remindersKey) ?? true;
      _alertsEnabled = _prefs.getBool(_alertsKey) ?? true;
      _achievementsEnabled = _prefs.getBool(_achievementsKey) ?? true;
      _geminiApiKey = _prefs.getString(_geminiApiKeyKey) ?? '';
      _avatarPath = _prefs.getString(_avatarPathKey) ?? '';

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  /// Définir le thème
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  /// Définir la langue
  Future<void> setLanguage(AppLanguage language) async {
    _language = language;
    await _prefs.setString(_languageKey, language.code);
    notifyListeners();
  }

  /// Définir la devise
  Future<void> setCurrency(Currency currency) async {
    _currency = currency;
    await _prefs.setString(_currencyKey, currency.code);
    notifyListeners();
  }

  /// Définir le format de date
  Future<void> setDateFormat(String format) async {
    _dateFormat = format;
    await _prefs.setString(_dateFormatKey, format);
    notifyListeners();
  }

  /// Définir les notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs.setBool(_notificationsKey, enabled);
    notifyListeners();
  }

  /// Définir les rappels
  Future<void> setRemindersEnabled(bool enabled) async {
    _remindersEnabled = enabled;
    await _prefs.setBool(_remindersKey, enabled);
    notifyListeners();
  }

  /// Définir les alertes
  Future<void> setAlertsEnabled(bool enabled) async {
    _alertsEnabled = enabled;
    await _prefs.setBool(_alertsKey, enabled);
    notifyListeners();
  }

  /// Définir les notifications d'accomplissements
  Future<void> setAchievementsEnabled(bool enabled) async {
    _achievementsEnabled = enabled;
    await _prefs.setBool(_achievementsKey, enabled);
    notifyListeners();
  }

  /// Définir la clé API Gemini
  Future<void> setGeminiApiKey(String key) async {
    _geminiApiKey = key.trim();
    await _prefs.setString(_geminiApiKeyKey, _geminiApiKey);
    notifyListeners();
  }

  /// Sauvegarder le chemin de l'avatar
  Future<void> setAvatarPath(String path) async {
    _avatarPath = path;
    await _prefs.setString(_avatarPathKey, path);
    notifyListeners();
  }
}
