import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'app_theme.dart';
import 'transaction_service.dart';
import 'constants.dart';

class SavingsTrackerScreen extends StatefulWidget {
  const SavingsTrackerScreen({super.key});

  @override
  State<SavingsTrackerScreen> createState() => _SavingsTrackerScreenState();
}

class _SavingsTrackerScreenState extends State<SavingsTrackerScreen>
    with TickerProviderStateMixin {
  late AnimationController _counterController;
  late Animation<double> _counterAnimation;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _counterAnimation = const AlwaysStoppedAnimation<double>(0.0);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _progressAnimation = const AlwaysStoppedAnimation<double>(0.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionService>(
        context,
        listen: false,
      ).loadTransactions().then((_) {
        _startAnimations();
      });
    });
  }

  void _startAnimations() {
    final service = Provider.of<TransactionService>(context, listen: false);

    final targetSavings = service.netSavings;
    final targetRate = service.savingsRate / 100.0;

    setState(() {
      _counterAnimation = Tween<double>(begin: 0, end: targetSavings).animate(
        CurvedAnimation(parent: _counterController, curve: Curves.easeOutCubic),
      );

      _progressAnimation =
          Tween<double>(
            begin: 0,
            end: targetRate.clamp(0.0, 1.0).toDouble(),
          ).animate(
            CurvedAnimation(
              parent: _progressController,
              curve: Curves.easeOutCubic,
            ),
          );
    });

    _counterController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _counterController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Savings Tracker'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 22),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Consumer<TransactionService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return _buildLoadingState();
          }

          return RefreshIndicator(
            color: AppColors.savings,
            onRefresh: () => service.loadTransactions(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNetSavingsCard(service),

                  const SizedBox(height: AppSpacing.lg),

                  _buildSavingsRateCard(service),

                  const SizedBox(height: AppSpacing.lg),

                  _buildSavingsHistoryChart(service),

                  const SizedBox(height: AppSpacing.lg),

                  _buildMonthlyBreakdown(service),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: AppColors.savings,
              strokeWidth: 4,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            'Loading savings data...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetSavingsCard(TransactionService service) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.savingsGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.savings.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.piggyBank,
                size: 24,
                color: Colors.white70,
              ),

              const SizedBox(width: AppSpacing.sm),

              Text(
                'Net Savings',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          AnimatedBuilder(
            animation: _counterAnimation,
            builder: (context, child) {
              return Text(
                '${Currency.xaf.symbol} ${_formatAmount(_counterAnimation.value)}',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIndicatorChip(
                icon: LucideIcons.trendingUp,
                label: 'Income',
                amount: service.totalIncome,
                color: Colors.greenAccent,
              ),

              Container(width: 1, height: 40, color: Colors.white24),

              _buildIndicatorChip(
                icon: LucideIcons.trendingDown,
                label: 'Expenses',
                amount: service.totalExpense,
                color: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorChip({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),

            const SizedBox(width: 4),

            Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: Colors.white70),
            ),
          ],
        ),

        const SizedBox(height: 4),

        Text(
          '${Currency.xaf.symbol} ${_formatAmount(amount)}',
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsRateCard(TransactionService service) {
    final savingsRate = service.savingsRate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.percent,
                size: 20,
                color: AppColors.savings,
              ),

              const SizedBox(width: AppSpacing.sm),

              const Text('Savings Rate', style: AppTypography.titleLarge),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 10,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.surfaceVariant,
                          ),
                        ),

                        CircularProgressIndicator(
                          value: _progressAnimation.value,
                          strokeWidth: 10,
                          strokeCap: StrokeCap.round,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.savings,
                          ),
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(_progressAnimation.value * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.savings,
                              ),
                            ),

                            Text(
                              'of income',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(width: AppSpacing.lg),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRateDetail(
                      'Total Income',
                      '${Currency.xaf.symbol} ${_formatAmount(service.totalIncome)}',
                      AppColors.income,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _buildRateDetail(
                      'Total Expenses',
                      '${Currency.xaf.symbol} ${_formatAmount(service.totalExpense)}',
                      AppColors.expense,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _buildRateDetail(
                      'Net Saved',
                      '${Currency.xaf.symbol} ${_formatAmount(service.netSavings)}',
                      AppColors.savings,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          _buildSavingsTip(savingsRate),
        ],
      ),
    );
  }

  Widget _buildRateDetail(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: AppSpacing.sm),

        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),

        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSavingsTip(double rate) {
    String tip;
    IconData tipIcon;
    Color tipColor;

    if (rate >= 30) {
      tip = 'Excellent! You\'re saving over 30% of your income.';
      tipIcon = LucideIcons.partyPopper;
      tipColor = AppColors.success;
    } else if (rate >= 20) {
      tip = 'Good job! Aim for 30% to build wealth faster.';
      tipIcon = LucideIcons.thumbsUp;
      tipColor = AppColors.savings;
    } else if (rate >= 10) {
      tip = 'Decent start. Try cutting expenses to reach 20%.';
      tipIcon = LucideIcons.info;
      tipColor = AppColors.warning;
    } else if (rate > 0) {
      tip = 'Your savings rate is low. Review your expenses.';
      tipIcon = LucideIcons.alertTriangle;
      tipColor = AppColors.warning;
    } else {
      tip = 'You\'re spending more than earning. Take action!';
      tipIcon = LucideIcons.alertCircle;
      tipColor = AppColors.error;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: tipColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(tipIcon, size: 18, color: tipColor),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Text(
              tip,
              style: AppTypography.bodySmall.copyWith(
                color: tipColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsHistoryChart(TransactionService service) {
    final monthlyData = _generateMonthlyData(service);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.lineChart,
                size: 20,
                color: AppColors.savings,
              ),

              const SizedBox(width: AppSpacing.sm),

              const Text('Savings History', style: AppTypography.titleLarge),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: AppColors.border, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                        ];

                        if (value.toInt() >= 0 &&
                            value.toInt() < months.length) {
                          return SideTitleWidget(
                            meta: meta,
                            angle: meta.axisPosition,
                            child: Text(
                              months[value.toInt()],
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: 50000,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}K',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: monthlyData
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    preventCurveOverShooting: true,
                    color: AppColors.savings,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: AppColors.savings,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.savings.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${Currency.xaf.symbol} ${_formatAmount(spot.y)}',
                          const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                minY: 0,
                maxY: (monthlyData.reduce((a, b) => a > b ? a : b) * 1.2)
                    .toDouble(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _generateMonthlyData(TransactionService service) {
    final double base = service.netSavings > 0
        ? service.netSavings.toDouble()
        : 100000.0;

    return [
      base * 0.4,
      base * 0.55,
      base * 0.6,
      base * 0.75,
      base * 0.85,
      base,
    ];
  }

  Widget _buildMonthlyBreakdown(TransactionService service) {
    final monthlyBreakdown = _generateMonthlyBreakdown(service);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.calendarRange,
                size: 20,
                color: AppColors.savings,
              ),

              const SizedBox(width: AppSpacing.sm),

              const Text('Monthly Breakdown', style: AppTypography.titleLarge),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          ...monthlyBreakdown.map((month) => _buildMonthTile(month)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateMonthlyBreakdown(
    TransactionService service,
  ) {
    final now = DateTime.now();

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final baseIncome = service.totalIncome > 0 ? service.totalIncome : 250000;

    final baseExpense = service.totalExpense > 0
        ? service.totalExpense
        : 108000;

    return List.generate(6, (index) {
      final monthDate = DateTime(now.year, now.month - (5 - index));

      final income = baseIncome * (0.8 + (index * 0.05));

      final expense = baseExpense * (0.85 + (index * 0.03));

      return {
        'month': months[monthDate.month - 1],
        'income': income,
        'expense': expense,
        'savings': income - expense,
        'rate': ((income - expense) / income * 100),
      };
    });
  }

  Widget _buildMonthTile(Map<String, dynamic> data) {
    final savings = data['savings'] as double;

    final isPositive = savings >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['month'] as String, style: AppTypography.titleMedium),

                Row(
                  children: [
                    Icon(
                      isPositive
                          ? LucideIcons.trendingUp
                          : LucideIcons.trendingDown,
                      size: 14,
                      color: isPositive ? AppColors.income : AppColors.expense,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      '${isPositive ? '+' : ''}${Currency.xaf.symbol} ${_formatAmount(savings)}',
                      style: AppTypography.titleMedium.copyWith(
                        color: isPositive
                            ? AppColors.income
                            : AppColors.expense,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (data['rate'] as double).clamp(0.0, 100.0) / 100,
                backgroundColor: AppColors.expense.withValues(alpha: 0.2),
                color: AppColors.savings,
                minHeight: 6,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Income: ${Currency.xaf.symbol} ${_formatAmount(data['income'] as double)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),

                Text(
                  'Expenses: ${Currency.xaf.symbol} ${_formatAmount(data['expense'] as double)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount
        .abs()
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }
}
