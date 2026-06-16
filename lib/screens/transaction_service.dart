import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import "app_models.dart";

/// ============================================
/// TRANSACTION SERVICE — Service de gestion des transactions
/// ============================================
/// Gère les revenus (IncomeModel) et dépenses (ExpenseModel).
/// Persiste les données avec SharedPreferences.
/// ============================================

class TransactionService extends ChangeNotifier {
  static const String _incomesKey = 'app_incomes';
  static const String _expensesKey = 'app_expenses';

  late SharedPreferences _prefs;
  List<IncomeModel> _incomes = [];
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;

  List<IncomeModel> get incomes => _incomes;
  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;

  /// Total des revenus
  double get totalIncome =>
      _incomes.fold(0.0, (sum, item) => sum + item.amount);

  /// Total des dépenses
  double get totalExpense =>
      _expenses.fold(0.0, (sum, item) => sum + item.amount);

  /// Épargne nette
  double get netSavings => totalIncome - totalExpense;

  /// Taux d'épargne (%)
  double get savingsRate =>
      totalIncome > 0 ? (netSavings / totalIncome) * 100 : 0;

  /// Initialiser avec SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await loadTransactions();
  }

  /// Charger les données depuis SharedPreferences
  Future<void> loadTransactions() async {
    try {
      _isLoading = true;
      notifyListeners();

      final incomesJson = _prefs.getStringList(_incomesKey) ?? [];
      final expensesJson = _prefs.getStringList(_expensesKey) ?? [];

      _incomes = incomesJson
          .map((json) => IncomeModel.fromMap(jsonDecode(json)))
          .toList();
      _expenses = expensesJson
          .map((json) => ExpenseModel.fromMap(jsonDecode(json)))
          .toList();

      // Trier par date décroissante
      _incomes.sort((a, b) => b.date.compareTo(a.date));
      _expenses.sort((a, b) => b.date.compareTo(a.date));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sauvegarder les transactions dans SharedPreferences
  Future<void> _saveTransactions() async {
    try {
      final incomesJson = _incomes.map((i) => jsonEncode(i.toMap())).toList();
      final expensesJson = _expenses.map((e) => jsonEncode(e.toMap())).toList();

      await _prefs.setStringList(_incomesKey, incomesJson);
      await _prefs.setStringList(_expensesKey, expensesJson);
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  /// Ajouter un revenu
  Future<void> addIncome(IncomeModel income) async {
    _incomes.insert(0, income);
    await _saveTransactions();
    notifyListeners();
  }

  /// Modifier un revenu
  Future<void> updateIncome(IncomeModel income) async {
    final index = _incomes.indexWhere((i) => i.id == income.id);
    if (index != -1) {
      _incomes[index] = income;
      await _saveTransactions();
      notifyListeners();
    }
  }

  /// Supprimer un revenu
  Future<void> deleteIncome(String id) async {
    _incomes.removeWhere((i) => i.id == id);
    await _saveTransactions();
    notifyListeners();
  }

  /// Ajouter une dépense
  Future<void> addExpense(ExpenseModel expense) async {
    _expenses.insert(0, expense);
    await _saveTransactions();
    notifyListeners();
  }

  /// Modifier une dépense
  Future<void> updateExpense(ExpenseModel expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      await _saveTransactions();
      notifyListeners();
    }
  }

  /// Supprimer une dépense
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await _saveTransactions();
    notifyListeners();
  }

  /// Transactions récentes (pour le Dashboard)
  List<TransactionModel> get recentTransactions {
    final all = <TransactionModel>[];

    for (final income in _incomes.take(5)) {
      all.add(
        TransactionModel(
          id: income.id ?? '',
          type: TransactionType.income,
          amount: income.amount,
          categoryName: income.category.label,
          categoryIcon: income.category.icon,
          categoryColor: income.category.color,
          date: income.date,
          note: income.note,
        ),
      );
    }

    for (final expense in _expenses.take(5)) {
      all.add(
        TransactionModel(
          id: expense.id ?? '',
          type: TransactionType.expense,
          amount: expense.amount,
          categoryName: expense.category.label,
          categoryIcon: expense.category.icon,
          categoryColor: expense.category.color,
          date: expense.date,
          note: expense.note,
        ),
      );
    }

    all.sort((a, b) => b.date.compareTo(a.date));
    return all.take(10).toList();
  }

  /// Get historical savings data for charts (Requirement 2 & 13)
  /// Returns actual values grouped by month from stored transaction records.
  List<Map<String, dynamic>> getMonthlySavingsHistory({int months = 6}) {
    final now = DateTime.now();
    final results = <Map<String, dynamic>>[];

    // Generate data from oldest to newest for chronological chart display
    for (int i = months - 1; i >= 0; i--) {
      // DateTime constructor handles overflow/underflow (e.g. month 0 is Dec of previous year)
      final monthDate = DateTime(now.year, now.month - i);
      
      final monthIncomes = _incomes.where((inc) =>
          inc.date.year == monthDate.year && inc.date.month == monthDate.month);
      final monthExpenses = _expenses.where((exp) =>
          exp.date.year == monthDate.year && exp.date.month == monthDate.month);

      final totalInc = monthIncomes.fold(0.0, (sum, item) => sum + item.amount);
      final totalExp = monthExpenses.fold(0.0, (sum, item) => sum + item.amount);

      results.add({
        'month': monthDate.month,
        'savings': totalInc - totalExp,
      });
    }
    return results;
  }

  /// Get detailed breakdown for reports (Requirement 2 & 13)
  /// Returns a summary of income, expenses, and savings per month.
  List<Map<String, dynamic>> getMonthlyBreakdown({int limit = 6}) {
    final now = DateTime.now();
    final results = <Map<String, dynamic>>[];
    
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    // Generate data from newest to oldest for the report list
    for (int i = 0; i < limit; i++) {
      final monthDate = DateTime(now.year, now.month - i);

      final monthIncomes = _incomes.where((inc) =>
          inc.date.year == monthDate.year && inc.date.month == monthDate.month);
      final monthExpenses = _expenses.where((exp) =>
          exp.date.year == monthDate.year && exp.date.month == monthDate.month);

      final totalInc = monthIncomes.fold(0.0, (sum, item) => sum + item.amount);
      final totalExp = monthExpenses.fold(0.0, (sum, item) => sum + item.amount);
      final savings = totalInc - totalExp;
      final rate = totalInc > 0 ? (savings / totalInc) * 100 : 0.0;

      results.add({
        'month': '${monthNames[monthDate.month - 1]} ${monthDate.year}',
        'income': totalInc,
        'expense': totalExp,
        'savings': savings,
        'rate': rate,
      });
    }
    return results;
  }
}
