import 'package:flutter/material.dart';

import 'app_models.dart';
import 'constants.dart';

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

      await Future.delayed(const Duration(seconds: 1));

      _goals = _generateMockGoals();
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

  /// Génère des données fictives
  List<GoalModel> _generateMockGoals() {
    final now = DateTime.now();

    return [
      GoalModel(
        id: 'goal_001',
        title: 'Emergency Fund',
        description: 'Build a 6-month emergency fund',
        targetAmount: 1500000.0,
        currentAmount: 750000.0,
        deadline: DateTime(now.year + 1, now.month, now.day),
        priority: GoalPriority.high,
        isEmergencyFund: true,
        isAchieved: false,
        createdAt: now,
        updatedAt: now,
      ),

      GoalModel(
        id: 'goal_002',
        title: 'New Laptop',
        description: 'MacBook Pro for freelance work',
        targetAmount: 800000.0,
        currentAmount: 520000.0,
        deadline: DateTime(now.year, now.month + 3, now.day),
        priority: GoalPriority.medium,
        isEmergencyFund: false,
        isAchieved: false,
        createdAt: now,
        updatedAt: now,
      ),

      GoalModel(
        id: 'goal_003',
        title: 'Vacation Trip',
        description: 'Summer vacation to Douala',
        targetAmount: 300000.0,
        currentAmount: 180000.0,
        deadline: DateTime(now.year, 7, 15),
        priority: GoalPriority.low,
        isEmergencyFund: false,
        isAchieved: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
