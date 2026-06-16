import 'package:save_app/models/Saving.dart';

class SavingsAnalytics {
  /// Groups savings by month and calculates the total amount.
  /// Returns a Map where the key is a string "YYYY-MM" and the value is the total sum.
  static Map<String, double> groupSavingsByMonth(List<Saving> savings) {
    final Map<String, double> monthlyTotals = {};

    // Sort data chronologically to ensure the chart order is correct
    final sortedSavings = List<Saving>.from(savings)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final saving in sortedSavings) {
      final date = saving.date.getDateTimeInUtc();
      // Create a key like "2024-05"
      final String monthKey =
          "${date.year}-${date.month.toString().padLeft(2, '0')}";

      monthlyTotals[monthKey] =
          (monthlyTotals[monthKey] ?? 0.0) + saving.amount;
    }

    return monthlyTotals;
  }

  /// Groups savings by category for breakdown reports (e.g. Pie Chart).
  static Map<String, double> groupSavingsByCategory(List<Saving> savings) {
    final Map<String, double> categoryTotals = {};

    for (final saving in savings) {
      final category = saving.category ?? 'Other';
      categoryTotals[category] =
          (categoryTotals[category] ?? 0.0) + saving.amount;
    }

    return categoryTotals;
  }
}
