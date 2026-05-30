import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'transaction_service.dart';
import 'app_models.dart';
import 'constants.dart';

/// ============================================
/// INCOME LIST SCREEN — Liste des revenus
/// ============================================

class IncomeListScreen extends StatefulWidget {
  const IncomeListScreen({super.key});

  @override
  State<IncomeListScreen> createState() => _IncomeListScreenState();
}

class _IncomeListScreenState extends State<IncomeListScreen> {
  TimePeriod _selectedPeriod = TimePeriod.monthly;
  IncomeCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionService>(
        context,
        listen: false,
      ).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Income'),
        actions: [
          IconButton(icon: const Icon(LucideIcons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Consumer<TransactionService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Apply filters
          List<IncomeModel> incomes = service.incomes;

          if (_selectedCategory != null) {
            incomes = incomes
                .where((income) => income.category == _selectedCategory)
                .toList();
          }

          if (incomes.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildSummaryHeader(service, incomes),
              _buildPeriodFilters(),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: 80,
                  ),
                  itemCount: incomes.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    return _buildIncomeCard(incomes[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/income/add'),
        backgroundColor: AppColors.income,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryHeader(
    TransactionService service,
    List<IncomeModel> incomes,
  ) {
    final filteredTotal = incomes.fold<double>(
      0.0,
      (sum, income) => sum + income.amount,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.incomeGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.trendingUp, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text(
                'Total Income',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${Currency.xaf.symbol} ${_formatAmount(filteredTotal)}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${incomes.length} income records',
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: TimePeriod.values.map((period) {
          final isSelected = period == _selectedPeriod;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(period.label),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              labelStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIncomeCard(IncomeModel income) {
    return Dismissible(
      key: Key(income.id ?? DateTime.now().toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      onDismissed: (_) {
        if (income.id != null) {
          Provider.of<TransactionService>(
            context,
            listen: false,
          ).deleteIncome(income.id!);
        }
      },
      child: GestureDetector(
        onTap: () {
          if (income.id != null) {
            context.push('/income/edit/${income.id}');
          }
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color(income.category.color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.arrowDownLeft,
                    size: 22,
                    color: Color(income.category.color),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      income.category.label,
                      style: AppTypography.titleMedium,
                    ),
                    if (income.note != null && income.note!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        income.note!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+ ${Currency.xaf.symbol} '
                    '${_formatAmount(income.amount)}',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.income,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _formatDate(income.date),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.trendingUp,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'No income records yet',
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap + to add your first income',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => context.push('/income/add'),
              child: const Text('Add Income'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Category',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: IncomeCategory.values.map((category) {
                final isSelected = _selectedCategory == category;

                return ChoiceChip(
                  label: Text(category.label),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = isSelected ? null : category;
                    });
                    Navigator.pop(context);
                  },
                  selectedColor: Color(category.color).withValues(alpha: 0.15),
                  side: BorderSide(
                    color: isSelected
                        ? Color(category.color)
                        : AppColors.border,
                  ),
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: isSelected
                        ? Color(category.color)
                        : AppColors.textSecondary,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatAmount(double amount) {
    return amount
        .abs()
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
