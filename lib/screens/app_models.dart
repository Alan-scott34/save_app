/// ============================================
/// DATA MODELS — Modèles de données de l'application
/// ============================================

library;

import 'package:flutter/material.dart';
import 'constants.dart';

// =============================================
// USER MODEL
// =============================================

class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String? passwordHash;
  final String? avatarUrl;
  final Currency preferredCurrency;
  final AppLanguage preferredLanguage;
  final String dateFormat;
  final ThemeMode themeMode;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    this.id,
    required this.fullName,
    required this.email,
    this.passwordHash,
    this.avatarUrl,
    this.preferredCurrency = Currency.xaf,
    this.preferredLanguage = AppLanguage.english,
    this.dateFormat = 'dd/MM/yyyy',
    this.themeMode = ThemeMode.system,
    required this.createdAt,
    this.updatedAt,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? passwordHash,
    String? avatarUrl,
    Currency? preferredCurrency,
    AppLanguage? preferredLanguage,
    String? dateFormat,
    ThemeMode? themeMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      dateFormat: dateFormat ?? this.dateFormat,
      themeMode: themeMode ?? this.themeMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'passwordHash': passwordHash,
      'avatarUrl': avatarUrl,
      'preferredCurrency': preferredCurrency.code,
      'preferredLanguage': preferredLanguage.code,
      'dateFormat': dateFormat,
      'themeMode': themeMode.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    int themeIndex = map['themeMode'] ?? 0;
    if (themeIndex < 0 || themeIndex >= ThemeMode.values.length) {
      themeIndex = 0;
    }

    return UserModel(
      id: map['id']?.toString(),
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      passwordHash: map['passwordHash'],
      avatarUrl: map['avatarUrl'],
      preferredCurrency: Currency.values.firstWhere(
        (c) => c.code == map['preferredCurrency'],
        orElse: () => Currency.xaf,
      ),
      preferredLanguage: AppLanguage.values.firstWhere(
        (l) => l.code == map['preferredLanguage'],
        orElse: () => AppLanguage.english,
      ),
      dateFormat: map['dateFormat'] ?? 'dd/MM/yyyy',
      themeMode: ThemeMode.values[themeIndex],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }
}

// =============================================
// INCOME MODEL
// =============================================

class IncomeModel {
  final String? id;
  final double amount;
  final IncomeCategory category;
  final DateTime date;
  final String? note;
  final String? attachmentUrl;
  final String? voiceNoteUrl;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const IncomeModel({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.attachmentUrl,
    this.voiceNoteUrl,
    this.isSynced = false,
    required this.createdAt,
    this.updatedAt,
  });

  IncomeModel copyWith({
    String? id,
    double? amount,
    IncomeCategory? category,
    DateTime? date,
    String? note,
    String? attachmentUrl,
    String? voiceNoteUrl,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      'note': note,
      'attachmentUrl': attachmentUrl,
      'voiceNoteUrl': voiceNoteUrl,
      'isSynced': isSynced ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['id']?.toString(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: IncomeCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => IncomeCategory.other,
      ),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      note: map['note'],
      attachmentUrl: map['attachmentUrl'],
      voiceNoteUrl: map['voiceNoteUrl'],
      isSynced: (map['isSynced'] ?? 0) == 1,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }
}

// =============================================
// EXPENSE MODEL
// =============================================

class ExpenseModel {
  final String? id;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? note;
  final String? attachmentUrl;
  final String? voiceNoteUrl;
  final double? latitude;
  final double? longitude;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ExpenseModel({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.attachmentUrl,
    this.voiceNoteUrl,
    this.latitude,
    this.longitude,
    this.isSynced = false,
    required this.createdAt,
    this.updatedAt,
  });

  ExpenseModel copyWith({
    String? id,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
    String? attachmentUrl,
    String? voiceNoteUrl,
    double? latitude,
    double? longitude,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      'note': note,
      'attachmentUrl': attachmentUrl,
      'voiceNoteUrl': voiceNoteUrl,
      'latitude': latitude,
      'longitude': longitude,
      'isSynced': isSynced ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id']?.toString(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: ExpenseCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => ExpenseCategory.other,
      ),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      note: map['note'],
      attachmentUrl: map['attachmentUrl'],
      voiceNoteUrl: map['voiceNoteUrl'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isSynced: (map['isSynced'] ?? 0) == 1,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }
}

// =============================================
// GOAL MODEL
// =============================================

class GoalModel {
  final String? id;
  final String title;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final GoalPriority priority;
  final String? category;
  final bool isEmergencyFund;
  final bool isAchieved;
  final double? dailySavingRate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const GoalModel({
    this.id,
    required this.title,
    this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.deadline,
    this.priority = GoalPriority.medium,
    this.category,
    this.isEmergencyFund = false,
    this.isAchieved = false,
    this.dailySavingRate,
    required this.createdAt,
    this.updatedAt,
  });

  double get progressPercent {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get remainingAmount => targetAmount - currentAmount;

  int get daysRemaining => deadline.difference(DateTime.now()).inDays;

  bool get isOverdue => daysRemaining < 0 && !isAchieved;

  double get requiredDailySaving {
    if (daysRemaining <= 0) return 0.0;
    return remainingAmount / daysRemaining;
  }

  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    GoalPriority? priority,
    String? category,
    bool? isEmergencyFund,
    bool? isAchieved,
    double? dailySavingRate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isEmergencyFund: isEmergencyFund ?? this.isEmergencyFund,
      isAchieved: isAchieved ?? this.isAchieved,
      dailySavingRate: dailySavingRate ?? this.dailySavingRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'priority': priority.name,
      'category': category,
      'isEmergencyFund': isEmergencyFund ? 1 : 0,
      'isAchieved': isAchieved ? 1 : 0,
      'dailySavingRate': dailySavingRate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id']?.toString(),
      title: map['title'] ?? '',
      description: map['description'],
      targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (map['currentAmount'] as num?)?.toDouble() ?? 0.0,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'])
          : DateTime.now(),
      priority: GoalPriority.values.firstWhere(
        (p) => p.name == map['priority'],
        orElse: () => GoalPriority.medium,
      ),
      category: map['category'],
      isEmergencyFund: (map['isEmergencyFund'] ?? 0) == 1,
      isAchieved: (map['isAchieved'] ?? 0) == 1,
      dailySavingRate: (map['dailySavingRate'] as num?)?.toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }
}

// =============================================
// TRANSACTION MODEL
// =============================================

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final TransactionType type;
  final double amount;
  final String categoryName;
  final String? categoryIcon;
  final int? categoryColor;
  final DateTime date;
  final String? note;
  final bool isSynced;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.date,
    this.note,
    this.isSynced = false,
  });
}
