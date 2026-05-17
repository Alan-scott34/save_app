import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import "app_theme.dart";
import "transaction_service.dart";
import "app_models.dart";
import "constants.dart";

/// ============================================
/// REPORTS SCREEN — Rapports financiers
/// ============================================
/// 🎯 Ce que fait cet écran :
/// 1. Sélecteur de plage de dates (début/fin)
/// 2. Cartes résumées : revenus totaux, dépenses totales, épargne nette
/// 3. Graphique camembert pour les catégories de dépenses
/// 4. Boutons d'exportation (PDF et CSV)
/// 5. Liste de l'historique des transactions pour la période
///
/// 📦 Dépendances :
/// → TransactionService (Provider) pour les données
/// → fl_chart pour les graphiques
/// → Lucide Icons pour les icônes
/// ============================================

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // --- Dates de la plage sélectionnée ---
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  // --- État de chargement pour l'export ---
  bool _isExporting = false;

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
        title: const Text('Reports'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          // Bouton de rafraîchissement
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () {
              Provider.of<TransactionService>(
                context,
                listen: false,
              ).loadTransactions();
            },
          ),
        ],
      ),
      body: Consumer<TransactionService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return _buildLoadingState();
          }

          // Filtrer les transactions selon la période
          final filteredIncomes = service.incomes
              .where(
                (i) =>
                    i.date.isAfter(_startDate) &&
                    i.date.isBefore(_endDate.add(const Duration(days: 1))),
              )
              .toList();
          final filteredExpenses = service.expenses
              .where(
                (e) =>
                    e.date.isAfter(_startDate) &&
                    e.date.isBefore(_endDate.add(const Duration(days: 1))),
              )
              .toList();

          // Calculer les totaux filtrés
          final totalIncome = filteredIncomes.fold(
            0.0,
            (sum, i) => sum + i.amount,
          );
          final totalExpense = filteredExpenses.fold(
            0.0,
            (sum, e) => sum + e.amount,
          );
          final netSavings = totalIncome - totalExpense;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Sélecteur de plage de dates ---
                _buildDateRangeSelector(),

                const SizedBox(height: AppSpacing.lg),

                // --- Cartes résumées ---
                _buildSummaryCards(
                  totalIncome: totalIncome,
                  totalExpense: totalExpense,
                  netSavings: netSavings,
                ),

                const SizedBox(height: AppSpacing.lg),

                // --- Graphique camembert des dépenses ---
                _buildExpensePieChart(filteredExpenses),

                const SizedBox(height: AppSpacing.lg),

                // --- Boutons d'exportation ---
                _buildExportButtons(),

                const SizedBox(height: AppSpacing.lg),

                // --- Historique des transactions ---
                _buildTransactionHistory(
                  filteredIncomes: filteredIncomes,
                  filteredExpenses: filteredExpenses,
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ============================================
  /// WIDGET : État de chargement
  /// ============================================
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 4,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Loading report data...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// WIDGET : Sélecteur de plage de dates
  /// ============================================
  /// Permet à l'utilisateur de choisir une date de début
  /// et une date de fin pour filtrer les données du rapport.
  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Row(
            children: [
              const Icon(
                LucideIcons.calendarRange,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text('Date Range', style: AppTypography.titleMedium),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Sélecteurs de date
          Row(
            children: [
              // Date de début
              Expanded(
                child: _buildDateButton(
                  label: 'From',
                  date: _startDate,
                  onTap: () => _selectStartDate(),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Icône flèche
              const Icon(
                LucideIcons.arrowRight,
                size: 18,
                color: AppColors.textTertiary,
              ),

              const SizedBox(width: AppSpacing.md),

              // Date de fin
              Expanded(
                child: _buildDateButton(
                  label: 'To',
                  date: _endDate,
                  onTap: () => _selectEndDate(),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Raccourcis de période
          Row(
            children: [
              _buildPeriodChip('7D', 7),
              const SizedBox(width: AppSpacing.sm),
              _buildPeriodChip('30D', 30),
              const SizedBox(width: AppSpacing.sm),
              _buildPeriodChip('90D', 90),
              const SizedBox(width: AppSpacing.sm),
              _buildPeriodChip('1Y', 365),
            ],
          ),
        ],
      ),
    );
  }

  /// Bouton de sélection de date
  Widget _buildDateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  LucideIcons.calendar,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Puce de raccourci de période
  Widget _buildPeriodChip(String label, int days) {
    final isActive =
        days == 30 &&
        _startDate.isAfter(DateTime.now().subtract(const Duration(days: 31)));

    return GestureDetector(
      onTap: () {
        setState(() {
          _endDate = DateTime.now();
          _startDate = DateTime.now().subtract(Duration(days: days));
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: isActive
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Ouvre le sélecteur de date de début
  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: _endDate,
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  /// Ouvre le sélecteur de date de fin
  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  /// ============================================
  /// WIDGET : Cartes résumées (revenus, dépenses, épargne)
  /// ============================================
  Widget _buildSummaryCards({
    required double totalIncome,
    required double totalExpense,
    required double netSavings,
  }) {
    return Row(
      children: [
        // Revenus totaux
        Expanded(
          child: _buildSummaryCard(
            title: 'Income',
            amount: totalIncome,
            icon: LucideIcons.trendingUp,
            color: AppColors.income,
            gradient: AppColors.incomeGradient,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Dépenses totales
        Expanded(
          child: _buildSummaryCard(
            title: 'Expenses',
            amount: totalExpense,
            icon: LucideIcons.trendingDown,
            color: AppColors.expense,
            gradient: AppColors.expenseGradient,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Épargne nette
        Expanded(
          child: _buildSummaryCard(
            title: 'Net',
            amount: netSavings,
            icon: LucideIcons.wallet,
            color: AppColors.savings,
            gradient: AppColors.savingsGradient,
          ),
        ),
      ],
    );
  }

  /// Carte résumée individuelle
  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 2),
          Text(
            '${Currency.xaf.symbol} ${_formatAmount(amount)}',
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// WIDGET : Graphique camembert des catégories de dépenses
  /// ============================================
  /// Affiche la répartition des dépenses par catégorie
  /// sous forme de graphique camembert avec légende.
  Widget _buildExpensePieChart(List<ExpenseModel> expenses) {
    // Agréger les dépenses par catégorie
    final categoryTotals = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    // Créer les sections du camembert
    final sections = categoryTotals.entries.map((entry) {
      final percentage = expenses.isEmpty
          ? 0.0
          : (entry.value / expenses.fold(0.0, (s, e) => s + e.amount) * 100);
      return PieChartSectionData(
        color: Color(entry.key.color),
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }).toList();

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
          // Titre
          Row(
            children: [
              const Icon(
                LucideIcons.pieChart,
                size: 20,
                color: AppColors.expense,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text('Expense Breakdown', style: AppTypography.titleLarge),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Graphique camembert ou état vide
          if (sections.isEmpty)
            _buildEmptyChartPlaceholder()
          else
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.md),

          // Légende
          if (categoryTotals.isNotEmpty)
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: categoryTotals.entries.map((entry) {
                return _buildLegendItem(
                  label: entry.key.label,
                  color: Color(entry.key.color),
                  amount: entry.value,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// État vide quand il n'y a pas de dépenses
  Widget _buildEmptyChartPlaceholder() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.pieChart,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No expenses in this period',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Élément de légende du camembert
  Widget _buildLegendItem({
    required String label,
    required Color color,
    required double amount,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label (${Currency.xaf.symbol} ${_formatAmount(amount)})',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// ============================================
  /// WIDGET : Boutons d'exportation (PDF et CSV)
  /// ============================================
  Widget _buildExportButtons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Row(
            children: [
              const Icon(
                LucideIcons.download,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text('Export Report', style: AppTypography.titleMedium),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Boutons d'export
          Row(
            children: [
              // Bouton PDF
              Expanded(
                child: _buildExportButton(
                  icon: LucideIcons.fileText,
                  label: 'Export PDF',
                  color: AppColors.error,
                  onTap: () => _exportReport('PDF'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Bouton CSV
              Expanded(
                child: _buildExportButton(
                  icon: LucideIcons.table,
                  label: 'Export CSV',
                  color: AppColors.income,
                  onTap: () => _exportReport('CSV'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bouton d'exportation individuel
  Widget _buildExportButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isExporting ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Action d'exportation (stub — à connecter aux packages pdf/csv)
  Future<void> _exportReport(String format) async {
    setState(() => _isExporting = true);

    // Simuler un délai d'exportation
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isExporting = false);

    // Afficher un message de confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report exported as $format successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );
    }
  }

  /// ============================================
  /// WIDGET : Historique des transactions pour la période
  /// ============================================
  /// Liste toutes les transactions (revenus et dépenses)
  /// comprises dans la plage de dates sélectionnée.
  Widget _buildTransactionHistory({
    required List<IncomeModel> filteredIncomes,
    required List<ExpenseModel> filteredExpenses,
  }) {
    // Combiner et trier toutes les transactions par date
    final allTransactions = <Map<String, dynamic>>[];

    for (final income in filteredIncomes) {
      allTransactions.add({
        'type': 'income',
        'category': income.category.label,
        'categoryColor': income.category.color,
        'amount': income.amount,
        'date': income.date,
        'note': income.note,
      });
    }

    for (final expense in filteredExpenses) {
      allTransactions.add({
        'type': 'expense',
        'category': expense.category.label,
        'categoryColor': expense.category.color,
        'amount': expense.amount,
        'date': expense.date,
        'note': expense.note,
      });
    }

    allTransactions.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

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
          // Titre
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.list,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'Transaction History',
                    style: AppTypography.titleLarge,
                  ),
                ],
              ),
              Text(
                '${allTransactions.length} items',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Liste des transactions
          if (allTransactions.isEmpty)
            _buildEmptyTransactionList()
          else
            ...allTransactions.map((tx) => _buildTransactionTile(tx)),
        ],
      ),
    );
  }

  /// État vide quand il n'y a pas de transactions
  Widget _buildEmptyTransactionList() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            const Icon(
              LucideIcons.inbox,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No transactions in this period',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tuile d'une transaction dans l'historique
  Widget _buildTransactionTile(Map<String, dynamic> tx) {
    final isIncome = tx['type'] == 'income';
    final categoryColor = tx['categoryColor'] as int;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            // Icône de catégorie
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(categoryColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  isIncome
                      ? LucideIcons.arrowDownLeft
                      : LucideIcons.arrowUpRight,
                  size: 18,
                  color: Color(categoryColor),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Info transaction
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx['category'] as String,
                    style: AppTypography.titleMedium,
                  ),
                  if (tx['note'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      tx['note'] as String,
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

            // Montant et date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${Currency.xaf.symbol} ${_formatAmount(tx['amount'] as double)}',
                  style: AppTypography.titleMedium.copyWith(
                    color: isIncome ? AppColors.income : AppColors.expense,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(tx['date'] as DateTime),
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

  /// Formate une date en dd/MM/yyyy
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formater un montant avec séparateur de milliers
  String _formatAmount(double amount) {
    return amount
        .abs()
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }
}
