import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================
/// ACHIEVEMENT MODEL — Modèle d'accomplissement
/// ============================================

enum AchievementType {
  savingsTarget('💰', 'Savings Target'),
  goalReached('🎯', 'Goal Reached'),
  streakMilestone('🔥', 'Streak Milestone'),
  expenseBeaten('💪', 'Expense Beaten'),
  incomeGrowth('📈', 'Income Growth'),
  customMilestone('⭐', 'Custom Milestone');

  final String emoji;
  final String displayName;

  const AchievementType(this.emoji, this.displayName);
}

class AchievementModel {
  final String? id;
  final String title;
  final String description;
  final AchievementType type;
  final double? targetAmount;
  final double? currentAmount;
  final DateTime achievedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isNotified;
  final String? relatedGoalId;

  const AchievementModel({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    this.targetAmount,
    this.currentAmount,
    required this.achievedAt,
    required this.createdAt,
    this.updatedAt,
    this.isNotified = false,
    this.relatedGoalId,
  });

  bool get isCompleted => currentAmount != null && targetAmount != null
      ? currentAmount! >= targetAmount!
      : true;

  double get progress {
    if (targetAmount == null || currentAmount == null) return 1.0;
    if (targetAmount! <= 0) return 1.0;
    return (currentAmount! / targetAmount!).clamp(0.0, 1.0).toDouble();
  }

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    AchievementType? type,
    double? targetAmount,
    double? currentAmount,
    DateTime? achievedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isNotified,
    String? relatedGoalId,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      achievedAt: achievedAt ?? this.achievedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isNotified: isNotified ?? this.isNotified,
      relatedGoalId: relatedGoalId ?? this.relatedGoalId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'achievedAt': achievedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isNotified': isNotified ? 1 : 0,
      'relatedGoalId': relatedGoalId,
    };
  }

  factory AchievementModel.fromMap(Map<String, dynamic> map) {
    return AchievementModel(
      id: map['id']?.toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: AchievementType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => AchievementType.customMilestone,
      ),
      targetAmount: (map['targetAmount'] as num?)?.toDouble(),
      currentAmount: (map['currentAmount'] as num?)?.toDouble(),
      achievedAt: map['achievedAt'] != null
          ? DateTime.parse(map['achievedAt'])
          : DateTime.now(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      isNotified: (map['isNotified'] ?? 0) == 1,
      relatedGoalId: map['relatedGoalId'],
    );
  }
}

/// ============================================
/// ACHIEVEMENT SERVICE — Service de gestion des accomplissements
/// ============================================

class AchievementService extends ChangeNotifier {
  static const String _achievementsKey = 'app_achievements';

  late SharedPreferences _prefs;
  List<AchievementModel> _achievements = [];
  bool _isLoading = false;

  List<AchievementModel> get achievements => List.unmodifiable(_achievements);
  bool get isLoading => _isLoading;

  /// Accomplissements récents (derniers 30 jours)
  List<AchievementModel> get recentAchievements {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _achievements
        .where((a) => a.achievedAt.isAfter(thirtyDaysAgo))
        .toList();
  }

  /// Nombre total d'accomplissements
  int get totalCount => _achievements.length;

  /// Accomplissements non notifiés
  List<AchievementModel> get unnotifiedAchievements =>
      _achievements.where((a) => !a.isNotified).toList();

  /// Initialiser avec SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await loadAchievements();
  }

  /// Charger les accomplissements depuis SharedPreferences
  Future<void> loadAchievements() async {
    try {
      _isLoading = true;
      notifyListeners();

      final achievementsJson = _prefs.getStringList(_achievementsKey) ?? [];

      _achievements = achievementsJson
          .map((json) => AchievementModel.fromMap(jsonDecode(json)))
          .toList();

      // Trier par date décroissante
      _achievements.sort((a, b) => b.achievedAt.compareTo(a.achievedAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading achievements: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sauvegarder les accomplissements
  Future<void> _saveAchievements() async {
    try {
      final achievementsJson = _achievements
          .map((a) => jsonEncode(a.toMap()))
          .toList();
      await _prefs.setStringList(_achievementsKey, achievementsJson);
    } catch (e) {
      debugPrint('Error saving achievements: $e');
    }
  }

  /// Ajouter un accomplissement
  Future<void> addAchievement(AchievementModel achievement) async {
    _achievements.insert(0, achievement);
    await _saveAchievements();
    notifyListeners();
  }

  /// Ajouter un accomplissement auto-déclenché
  Future<void> addAutoAchievement({
    required String title,
    required String description,
    required AchievementType type,
    double? targetAmount,
    double? currentAmount,
    String? relatedGoalId,
  }) async {
    final achievement = AchievementModel(
      id: 'ach_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      type: type,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      achievedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
    await addAchievement(achievement);
  }

  /// Marquer comme notifié
  Future<void> markAsNotified(String id) async {
    final index = _achievements.indexWhere((a) => a.id == id);
    if (index != -1) {
      _achievements[index] = _achievements[index].copyWith(isNotified: true);
      await _saveAchievements();
      notifyListeners();
    }
  }

  /// Supprimer un accomplissement
  Future<void> deleteAchievement(String id) async {
    _achievements.removeWhere((a) => a.id == id);
    await _saveAchievements();
    notifyListeners();
  }

  /// Obtenir un accomplissement par ID
  AchievementModel? getById(String id) {
    try {
      return _achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
