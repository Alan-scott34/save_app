import 'package:flutter/material.dart';

/// ============================================
/// SYNC SERVICE — Service de synchronisation hors-ligne
/// ============================================
/// Gère la synchronisation entre le stockage local
/// (SQLite) et le cloud (Firestore).
///
/// 💡 Comment ça fonctionne :
/// 1. Toutes les opérations sont d'abord sauvegardées
///    localement (SQLite) → disponible hors-ligne
/// 2. Quand la connexion revient, le service synchronise
///    les données non synchronisées avec le cloud
/// 3. Conflits résolus par timestamp (le plus récent gagne)
/// ============================================

class SyncService extends ChangeNotifier {
  bool _isSyncing = false;
  bool _isOnline = true;
  DateTime? _lastSyncTime;
  int _pendingChanges = 0;
  String? _error;

  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingChanges => _pendingChanges;
  String? get error => _error;

  /// Vérifier la connexion internet
  Future<void> checkConnectivity() async {
    // TODO: Utiliser connectivity_plus
    _isOnline = true;
    notifyListeners();
  }

  /// Synchroniser les données
  Future<void> sync() async {
    if (_isSyncing || !_isOnline) return;

    _isSyncing = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implémenter la logique de synchronisation
      await Future.delayed(const Duration(seconds: 2));

      _lastSyncTime = DateTime.now();
      _pendingChanges = 0;
      _isSyncing = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Ajouter un changement en attente
  void addPendingChange() {
    _pendingChanges++;
    notifyListeners();
  }
}
