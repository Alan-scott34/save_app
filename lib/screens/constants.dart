/// ============================================
/// CONSTANTS — Valeurs globales de l'application
/// ============================================
/// Ce fichier contient toutes les constantes utilisées
/// dans l'application : catégories, devises, langues, etc.
///
/// 💡 Pourquoi centraliser les constantes ?
/// → Un seul endroit pour modifier les valeurs
/// → Évite les "magic numbers" et strings en dur
/// → Facilite la maintenance et l'évolution
/// ============================================
library;

class AppConstants {
  // --- Nom de l'application ---
  static const String appName = 'SaveApp';
  static const String appTagline = 'Track. Save. Grow.';

  // --- Versions ---
  static const String appVersion = '1.0.0';

  // --- Durées d'animation ---
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 3);

  // --- Limites ---
  static const int maxGoals = 20;
  static const int maxTransactionsPerPage = 20;
  static const double minGoalAmount = 1000.0;

  // --- Format de date ---
  static const String dateFormatFR = 'dd/MM/yyyy';
  static const String dateFormatEN = 'MM/dd/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
}

/// ============================================
/// CATÉGORIES DE DÉPENSES
/// ============================================
/// Chaque catégorie a :
/// - un nom (affiché à l'utilisateur)
/// - une icône Lucide correspondante
/// - une couleur unique pour les graphiques
///
/// 💡 Pourquoi des catégories prédéfinies ?
/// → Standardise les données pour les graphiques
/// → Meilleure expérience utilisateur (pas besoin de réfléchir)
/// → L'utilisateur peut aussi créer ses propres catégories
/// ============================================

enum ExpenseCategory {
  food(label: 'Food & Dining', icon: 'utensils', color: 0xFFEF4444),
  transport(label: 'Transport', icon: 'car', color: 0xFF3B82F6),
  housing(label: 'Housing & Rent', icon: 'home', color: 0xFF8B5CF6),
  healthcare(label: 'Healthcare', icon: 'heart-pulse', color: 0xFFEC4899),
  education(label: 'Education', icon: 'graduation-cap', color: 0xFF06B6D4),
  entertainment(label: 'Entertainment', icon: 'gamepad-2', color: 0xFFF59E0B),
  shopping(label: 'Shopping', icon: 'shopping-bag', color: 0xFF10B981),
  utilities(label: 'Utilities', icon: 'zap', color: 0xFF6366F1),
  insurance(label: 'Insurance', icon: 'shield', color: 0xFF14B8A6),
  personal(label: 'Personal Care', icon: 'sparkles', color: 0xFFF472B6),
  debt(label: 'Debt Payments', icon: 'landmark', color: 0xFFDC2626),
  savings(label: 'Savings', icon: 'piggy-bank', color: 0xFF10B981),
  gifts(label: 'Gifts & Donations', icon: 'gift', color: 0xFFA855F7),
  travel(label: 'Travel', icon: 'plane', color: 0xFF0EA5E9),
  subscriptions(label: 'Subscriptions', icon: 'repeat', color: 0xFF8B5CF6),
  other(label: 'Other', icon: 'more-horizontal', color: 0xFF64748B);

  const ExpenseCategory({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final String icon;
  final int color;
}

/// ============================================
/// CATÉGORIES DE REVENU
/// ============================================

enum IncomeCategory {
  salary(label: 'Salary', icon: 'briefcase', color: 0xFF10B981),
  freelance(label: 'Freelance', icon: 'laptop', color: 0xFF3B82F6),
  business(label: 'Business', icon: 'building-2', color: 0xFF8B5CF6),
  investment(label: 'Investment', icon: 'trending-up', color: 0xFF06B6D4),
  rental(label: 'Rental Income', icon: 'home', color: 0xFFF59E0B),
  gift(label: 'Gift Received', icon: 'gift', color: 0xFFEC4899),
  refund(label: 'Refund', icon: 'rotate-ccw', color: 0xFF14B8A6),
  other(label: 'Other', icon: 'more-horizontal', color: 0xFF64748B);

  const IncomeCategory({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final String icon;
  final int color;
}

/// ============================================
/// PRIORITÉS DES OBJECTIFS
/// ============================================

enum GoalPriority {
  low(label: 'Low', icon: 'arrow-down', color: 0xFF10B981),
  medium(label: 'Medium', icon: 'minus', color: 0xFFF59E0B),
  high(label: 'High', icon: 'arrow-up', color: 0xFFEF4444),
  critical(label: 'Critical', icon: 'alert-triangle', color: 0xFFDC2626);

  const GoalPriority({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final String icon;
  final int color;
}

/// ============================================
/// DEVISES SUPPORTÉES
/// ============================================

enum Currency {
  xaf(code: 'XAF', symbol: 'FCFA', name: 'CFA Franc BEAC', locale: 'fr_CM'),
  usd(code: 'USD', symbol: '\$', name: 'US Dollar', locale: 'en_US'),
  eur(code: 'EUR', symbol: '€', name: 'Euro', locale: 'fr_FR'),
  gbp(code: 'GBP', symbol: '£', name: 'British Pound', locale: 'en_GB'),
  jpy(code: 'JPY', symbol: '¥', name: 'Japanese Yen', locale: 'ja_JP'),
  cad(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar', locale: 'en_CA'),
  cny(code: 'CNY', symbol: '¥', name: 'Chinese Yuan', locale: 'zh_CN');

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.locale,
  });

  final String code;
  final String symbol;
  final String name;
  final String locale;
}

/// ============================================
/// LANGUES SUPPORTÉES
/// ============================================

enum AppLanguage {
  english(code: 'en', name: 'English', nativeName: 'English'),
  french(code: 'fr', name: 'French', nativeName: 'Français');

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  final String code;
  final String name;
  final String nativeName;
}

/// ============================================
/// PÉRIODES DE TEMPS
/// ============================================

enum TimePeriod {
  daily(label: 'Daily', icon: 'calendar-days'),
  weekly(label: 'Weekly', icon: 'calendar'),
  monthly(label: 'Monthly', icon: 'calendar-range'),
  yearly(label: 'Yearly', icon: 'calendar-check'),
  custom(label: 'Custom', icon: 'calendar-clock');

  const TimePeriod({
    required this.label,
    required this.icon,
  });

  final String label;
  final String icon;
}
