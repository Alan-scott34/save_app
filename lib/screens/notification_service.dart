import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_models.dart';

/// ============================================
/// NOTIFICATION SERVICE — In-app alert system
/// ============================================
/// Manages a persisted list of AppNotification objects.
/// Checks goal deadlines, budget limits, and milestones.
/// ============================================

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
      };

  factory AppNotification.fromMap(Map<String, dynamic> m) => AppNotification(
        id: m['id'] as String,
        title: m['title'] as String,
        body: m['body'] as String,
        type: NotificationType.values.firstWhere(
          (t) => t.name == m['type'],
          orElse: () => NotificationType.info,
        ),
        createdAt: DateTime.parse(m['createdAt'] as String),
        isRead: m['isRead'] as bool? ?? false,
      );
}

enum NotificationType { info, warning, success, error }

class NotificationService extends ChangeNotifier {
  static const _prefsKey = 'app_notifications';

  late SharedPreferences _prefs;
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  bool get hasUnread => unreadCount > 0;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _load();
  }

  void _load() {
    try {
      final raw = _prefs.getStringList(_prefsKey) ?? [];
      _notifications.clear();
      _notifications.addAll(
        raw.map((s) => AppNotification.fromMap(jsonDecode(s))),
      );
      // newest first
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationService load error: $e');
    }
  }

  Future<void> _save() async {
    final raw = _notifications.map((n) => jsonEncode(n.toMap())).toList();
    await _prefs.setStringList(_prefsKey, raw);
  }

  Future<void> _addNotification(AppNotification notification) async {
    // Avoid duplicate notifications created on the same day for the same title
    final today = DateTime.now();
    final alreadyExists = _notifications.any(
      (n) =>
          n.title == notification.title &&
          n.createdAt.year == today.year &&
          n.createdAt.month == today.month &&
          n.createdAt.day == today.day,
    );
    if (alreadyExists) return;

    _notifications.insert(0, notification);
    await _save();
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // CHECKS
  // ─────────────────────────────────────────────

  /// Check if any goals are approaching their deadline (≤ 7 days).
  Future<void> checkGoalDeadlines(List<GoalModel> goals) async {
    final now = DateTime.now();
    for (final goal in goals) {
      if (goal.isAchieved) continue;
      final diff = goal.deadline.difference(now).inDays;
      if (diff <= 7 && diff >= 0) {
        await _addNotification(AppNotification(
          id: 'deadline_${goal.id}',
          title: 'Goal Deadline Approaching',
          body:
              '"${goal.title}" is due in $diff day${diff == 1 ? '' : 's'}. Keep it up!',
          type: diff <= 2 ? NotificationType.error : NotificationType.warning,
          createdAt: DateTime.now(),
        ));
      }
    }
  }

  /// Trigger a "Goal Achieved" notification.
  Future<void> checkGoalAchieved(GoalModel goal) async {
    if (!goal.isAchieved) return;
    await _addNotification(AppNotification(
      id: 'achieved_${goal.id}',
      title: 'Goal Achieved!',
      body: 'Congratulations! You reached your goal: "${goal.title}"',
      type: NotificationType.success,
      createdAt: DateTime.now(),
    ));
  }

  /// Check if monthly expenses exceed a given budget limit.
  Future<void> checkBudgetExceeded(double expenses, double limit) async {
    if (expenses <= limit) return;
    await _addNotification(AppNotification(
      id: 'budget_${DateTime.now().year}_${DateTime.now().month}',
      title: 'Budget Exceeded',
      body:
          'Your expenses this month exceed your set limit. Review your spending.',
      type: NotificationType.error,
      createdAt: DateTime.now(),
    ));
  }

  /// Generic info notification.
  Future<void> addInfo(String title, String body) async {
    await _addNotification(AppNotification(
      id: 'info_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: NotificationType.info,
      createdAt: DateTime.now(),
    ));
  }

  // ─────────────────────────────────────────────
  // MARK READ / CLEAR
  // ─────────────────────────────────────────────

  Future<void> markRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      await _save();
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    for (final n in _notifications) {
      n.isRead = true;
    }
    await _save();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    await _save();
    notifyListeners();
  }
}
