import 'package:flutter/material.dart';
import "app_models.dart";
import "constants.dart";

/// ============================================
/// TRANSACTION SERVICE — Service de gestion des transactions
/// ============================================
/// Gère les revenus (IncomeModel) et dépenses (ExpenseModel).
/// Pour l'instant, c'est un stub avec des données mock.
/// Sera connecté à SQLite + Cloud Firestore.
/// ============================================

class TransactionService extends ChangeNotifier {
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

  /// Charger les données (mock pour l'instant)
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _incomes = _generateMockIncomes();
    _expenses = _generateMockExpenses();

    _isLoading = false;
    notifyListeners();
  }

  /// Ajouter un revenu
  Future<void> addIncome(IncomeModel income) async {
    _incomes.insert(0, income);
    notifyListeners();
  }

  /// Modifier un revenu
  Future<void> updateIncome(IncomeModel income) async {
    final index = _incomes.indexWhere((i) => i.id == income.id);
    if (index != -1) {
      _incomes[index] = income;
      notifyListeners();
    }
  }

  /// Supprimer un revenu
  Future<void> deleteIncome(String id) async {
    _incomes.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  /// Ajouter une dépense
  Future<void> addExpense(ExpenseModel expense) async {
    _expenses.insert(0, expense);
    notifyListeners();
  }

  /// Modifier une dépense
  Future<void> updateExpense(ExpenseModel expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  /// Supprimer une dépense
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Transactions récentes (pour le Dashboard)
  List<TransactionModel> get recentTransactions {
    final all = <TransactionModel>[];

    for (final income in _incomes.take(5)) {
      all.add(TransactionModel(
        id: income.id ?? '',
        type: TransactionType.income,
        amount: income.amount,
        categoryName: income.category.label,
        categoryIcon: income.category.icon,
        categoryColor: income.category.color,
        date: income.date,
        note: income.note,
      ));
    }

    for (final expense in _expenses.take(5)) {
      all.add(TransactionModel(
        id: expense.id ?? '',
        type: TransactionType.expense,
        amount: expense.amount,
        categoryName: expense.category.label,
        categoryIcon: expense.category.icon,
        categoryColor: expense.category.color,
        date: expense.date,
        note: expense.note,
      ));
    }

    all.sort((a, b) => b.date.compareTo(a.date));
    return all.take(10).toList();
  }

  // --- Données mock ---
  List<IncomeModel> _generateMockIncomes() {
    final now = DateTime.now();
    return [
      IncomeModel(
        id: 'inc_001',
        amount: 250000,
        category: IncomeCategory.salary,
        date: DateTime(now.year, now.month, 1),
        note: 'Monthly salary',
        createdAt: now,
      ),
      IncomeModel(
        id: 'inc_002',
        amount: 50000,
        category: IncomeCategory.freelance,
        date: DateTime(now.year, now.month, 5),
        note: 'Web design project',
        createdAt: now,
      ),
      IncomeModel(
        id: 'inc_003',
        amount: 15000,
        category: IncomeCategory.investment,
        date: DateTime(now.year, now.month, 10),
        note: 'Dividend payment',
        createdAt: now,
      ),
    ];
  }

  List<ExpenseModel> _generateMockExpenses() {
    final now = DateTime.now();
    return [
      ExpenseModel(
        id: 'exp_001',
        amount: 60000,
        category: ExpenseCategory.housing,
        date: DateTime(now.year, now.month, 1),
        note: 'Monthly rent',
        createdAt: now,
      ),
      ExpenseModel(
        id: 'exp_002',
        amount: 25000,
        category: ExpenseCategory.food,
        date: DateTime(now.year, now.month, 3),
        note: 'Groceries',
        createdAt: now,
      ),
      ExpenseModel(
        id: 'exp_003',
        amount: 5000,
        category: ExpenseCategory.transport,
        date: DateTime(now.year, now.month, 7),
        note: 'Fuel',
        createdAt: now,
      ),
      ExpenseModel(
        id: 'exp_004',
        amount: 10000,
        category: ExpenseCategory.healthcare,
        date: DateTime(now.year, now.month, 12),
        note: 'Doctor visit',
        createdAt: now,
      ),
      ExpenseModel(
        id: 'exp_005',
        amount: 8000,
        category: ExpenseCategory.entertainment,
        date: DateTime(now.year, now.month, 15),
        note: 'Movie night',
        createdAt: now,
      ),
    ];
  }
}
