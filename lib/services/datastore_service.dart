import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:save_app/models/ModelProvider.dart';
import 'dart:async';

class DataStoreService {
  // Singleton pattern
  static final DataStoreService _instance = DataStoreService._internal();

  factory DataStoreService() {
    return _instance;
  }

  DataStoreService._internal();

  /// Initialize DataStore (Usually done in Amplify setup, but kept for compatibility)
  Future<void> init() async {
    // DataStore is initialized through Amplify.addPlugin, 
    // but we can query immediately or start it.
    try {
      await Amplify.DataStore.start();
    } catch (e) {
      safePrint('Error starting DataStore: $e');
    }
  }

  /// Add or update a saving
  Future<void> saveSaving(Saving saving) async {
    try {
      await Amplify.DataStore.save(saving);
    } catch (e) {
      safePrint('Error saving saving: $e');
    }
  }

  /// Get a saving by ID
  Future<Saving?> getSaving(String id) async {
    try {
      final savings = await Amplify.DataStore.query(
        Saving.classType,
        where: Saving.ID.eq(id),
      );
      if (savings.isNotEmpty) {
        return savings.first;
      }
    } catch (e) {
      safePrint('Error getting saving: $e');
    }
    return null;
  }

  /// Get all savings
  Future<List<Saving>> getAllSavings() async {
    try {
      return await Amplify.DataStore.query(Saving.classType);
    } catch (e) {
      safePrint('Error getting all savings: $e');
      return [];
    }
  }

  /// Delete a saving by ID
  Future<void> deleteSaving(String id) async {
    try {
      final savingToDelete = await getSaving(id);
      if (savingToDelete != null) {
        await Amplify.DataStore.delete(savingToDelete);
      }
    } catch (e) {
      safePrint('Error deleting saving: $e');
    }
  }

  /// Get savings by category
  Future<List<Saving>> getSavingsByCategory(String category) async {
    try {
      return await Amplify.DataStore.query(
        Saving.classType,
        where: Saving.CATEGORY.eq(category),
      );
    } catch (e) {
      safePrint('Error querying by category: $e');
      return [];
    }
  }

  /// Get savings within a date range
  Future<List<Saving>> getSavingsByDateRange(DateTime start, DateTime end) async {
    try {
      // Amplify's TemporalDateTime can be used for querying
      return await Amplify.DataStore.query(
        Saving.classType,
        where: Saving.DATE.between(
          TemporalDateTime(start),
          TemporalDateTime(end),
        ),
      );
    } catch (e) {
      safePrint('Error querying by date range: $e');
      return [];
    }
  }

  /// Get total amount of all savings
  Future<double> getTotalAmount() async {
    try {
      final savings = await getAllSavings();
      return savings.fold<double>(0.0, (sum, saving) => sum + saving.amount);
    } catch (e) {
      safePrint('Error calculating total amount: $e');
      return 0.0;
    }
  }

  /// Clear all savings (use with caution)
  Future<void> clearAll() async {
    try {
      await Amplify.DataStore.clear();
    } catch (e) {
      safePrint('Error clearing DataStore: $e');
    }
  }

  /// Stream to listen to real-time changes
  Stream<SubscriptionEvent<Saving>> observeSavings() {
    return Amplify.DataStore.observe(Saving.classType);
  }
}
