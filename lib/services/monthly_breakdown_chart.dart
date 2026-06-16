import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:save_app/models/Saving.dart';
import 'package:save_app/services/amplify_service.dart';
import 'package:save_app/utils/savings_analytics.dart';

class MonthlyBreakdownChart extends StatelessWidget {
  final String type; // Expected: 'Income', 'Expense', or 'Goal'

  const MonthlyBreakdownChart({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Saving>>(
      future: AmplifyService.instance.getSavings(type: type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading data: ${snapshot.error}'));
        }

        final savings = snapshot.data ?? [];
        if (savings.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('No entries found for this category.')),
          );
        }

        final monthlyData = SavingsAnalytics.groupSavingsByMonth(savings);
        final keys = monthlyData.keys.toList();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _calculateMaxY(monthlyData),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < keys.length) {
                          // Show only month number for brevity (e.g. '05')
                          final month = keys[index].split('-').last;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              month,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _generateGroups(monthlyData),
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateMaxY(Map<String, double> data) {
    if (data.isEmpty) return 100;
    final maxVal = data.values.reduce((a, b) => a > b ? a : b);
    return maxVal * 1.25; // 25% padding at top
  }

  List<BarChartGroupData> _generateGroups(Map<String, double> data) {
    final List<BarChartGroupData> groups = [];
    int index = 0;

    data.forEach((_, total) {
      groups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: total,
              color: _getBarColor(),
              width: 18,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
      index++;
    });
    return groups;
  }

  Color _getBarColor() {
    if (type == 'Income') return Colors.teal;
    if (type == 'Expense') return Colors.orangeAccent;
    return Colors.indigo;
  }
}
