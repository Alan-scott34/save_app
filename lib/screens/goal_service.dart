import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_models.dart';

/// ============================================
/// GOAL SERVICE — Service de gestion des objectifs
/// ============================================

class GoalService extends ChangeNotifier {
  static const String _goalsKey = 'app_goals';

  late SharedPreferences _prefs;
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

  /// Initialiser avec SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await loadGoals();
  }

  /// Charge les objectifs depuis SharedPreferences
  Future<void> loadGoals() async {
    try {
      _isLoading = true;
      notifyListeners();

      final goalsJson = _prefs.getStringList(_goalsKey) ?? [];

      _goals = goalsJson
          .map((json) => GoalModel.fromMap(jsonDecode(json)))
          .toList();

      // Trier par date de création décroissante
      _goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading goals: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sauvegarder les objectifs dans SharedPreferences
  Future<void> _saveGoals() async {
    try {
      final goalsJson = _goals.map((g) => jsonEncode(g.toMap())).toList();
      await _prefs.setStringList(_goalsKey, goalsJson);
    } catch (e) {
      debugPrint('Error saving goals: $e');
    }
  }

  /// Ajouter un objectif
  Future<void> addGoal(GoalModel goal) async {
    _goals.insert(0, goal);
    await _saveGoals();
    notifyListeners();
  }

  /// Modifier un objectif
  Future<void> updateGoal(GoalModel updatedGoal) async {
    final index = _goals.indexWhere((goal) => goal.id == updatedGoal.id);

    if (index != -1) {
      _goals[index] = updatedGoal.copyWith(updatedAt: DateTime.now());
      await _saveGoals();
      notifyListeners();
    }
  }

  /// Supprimer un objectif
  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((goal) => goal.id == id);
    await _saveGoals();
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

    await _saveGoals();
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
