import 'package:flutter/material.dart';

import 'app_models.dart';

/// ============================================
/// GOAL SERVICE — Service de gestion des objectifs
/// ============================================

class GoalService extends ChangeNotifier {
  List<GoalModel> _goals = [];
  bool _isLoading = false;

  /// Liste complète des objectifs
  List<GoalModel> get goals => List.unmodifiable(_goals);

  /// État de chargement
  bool get isLoading => _isLoading;

  /// Objectifs actifs (non atteints)
  List<GoalModel> get activeGoals =>
      _goals.where((goal) => !goal.isAchieved).toList();

  /// Objectifs atteints
  List<GoalModel> get achievedGoals =>
      _goals.where((goal) => goal.isAchieved).toList();

  /// Fonds d'urgence
  List<GoalModel> get emergencyFunds =>
      _goals.where((goal) => goal.isEmergencyFund).toList();

  /// Total cible des objectifs actifs
  double get totalTargetAmount =>
      activeGoals.fold<double>(0.0, (sum, goal) => sum + goal.targetAmount);

  /// Total déjà épargné
  double get totalSavedAmount =>
      activeGoals.fold<double>(0.0, (sum, goal) => sum + goal.currentAmount);

  /// Progression globale
  double get overallProgress {
    if (totalTargetAmount <= 0) return 0.0;

    return (totalSavedAmount / totalTargetAmount).clamp(0.0, 1.0).toDouble();
  }

  /// Charge les objectifs (simulation)
  Future<void> loadGoals() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));

      // Start with empty list
      _goals = [];
    } catch (e) {
      debugPrint('Error loading goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajouter un objectif
  Future<void> addGoal(GoalModel goal) async {
    _goals.insert(0, goal);
    notifyListeners();
  }

  /// Modifier un objectif
  Future<void> updateGoal(GoalModel updatedGoal) async {
    final index = _goals.indexWhere((goal) => goal.id == updatedGoal.id);

    if (index != -1) {
      _goals[index] = updatedGoal.copyWith(updatedAt: DateTime.now());

      notifyListeners();
    }
  }

  /// Supprimer un objectif
  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((goal) => goal.id == id);
    notifyListeners();
  }

  /// Ajouter un montant à un objectif
  Future<void> addToGoal(String id, double amount) async {
    final index = _goals.indexWhere((goal) => goal.id == id);

    if (index == -1) return;

    final goal = _goals[index];

    final double newAmount = goal.currentAmount + amount;

    final bool achieved = newAmount >= goal.targetAmount;

    _goals[index] = goal.copyWith(
      currentAmount: newAmount,
      isAchieved: achieved,
      updatedAt: DateTime.now(),
    );

    notifyListeners();
  }

  /// Réinitialiser les objectifs
  void clearGoals() {
    _goals.clear();
    notifyListeners();
  }

  /// Recherche par ID
  GoalModel? getGoalById(String id) {
    try {
      return _goals.firstWhere((goal) => goal.id == id);
    } catch (e) {
      return null;
    }
  }
}
