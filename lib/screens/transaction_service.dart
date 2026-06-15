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
}
