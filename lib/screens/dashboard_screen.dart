import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import "app_theme.dart";
import "transaction_service.dart";
import "goal_service.dart";
import "app_models.dart";
import "constants.dart";

/// ============================================
/// DASHBOARD SCREEN — Tableau de bord principal
/// ============================================
/// 🎯 Ce que fait cet écran :
/// 1. Vue d'ensemble financière (revenus, dépenses, épargne)
/// 2. Graphiques visuels (ligne, camembert, barres de progression)
/// 3. Transactions récentes
/// 4. Objectifs actifs avec progression
/// 5. Accès rapide à toutes les fonctionnalités
///
/// 🗺️ Navigation depuis le Dashboard :
/// → Bottom Nav : Income, Expenses, Goals, Profile
/// → Tap sur une carte → écran détaillé
/// → FAB (+) → Ajouter transaction rapide
///
/// 💡 Design :
/// → AppBar personnalisée avec avatar et salutation
/// → Cartes résumées avec dégradés
/// → Liste des transactions récentes
/// → Section objectifs avec progress bars
/// ============================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionService>(
        context,
        listen: false,
      ).loadTransactions();
      Provider.of<GoalService>(context, listen: false).loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          final transactionService = Provider.of<TransactionService>(
            context,
            listen: false,
          );
          final goalService = Provider.of<GoalService>(context, listen: false);
          await transactionService.loadTransactions();
          await goalService.loadGoals();
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // --- AppBar personnalisée ---
            _buildSliverAppBar(),

            // --- Contenu principal ---
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // --- Cartes résumées ---
                  _buildSummaryCards(),

                  const SizedBox(height: AppSpacing.lg),

                  // --- Section Objectifs actifs ---
                  _buildActiveGoalsSection(),

                  const SizedBox(height: AppSpacing.lg),

                  // --- Section Transactions récentes ---
                  _buildRecentTransactionsSection(),

                  const SizedBox(height: 100), // Espace pour le FAB
                ],
              ),
            ),
          ],
        ),
      ),

      // --- Bouton flottant : Ajouter transaction ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text(
          'Add',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET : AppBar personnalisée
  /// ============================================
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        expandedTitleScale: 1.0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning! 👋',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.0,
              ),
            ),
            const Text(
              'John Doe',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                height: 1.0,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // --- Bouton Notifications ---
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () {
              // TODO: Navigation vers les notifications
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.bell,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),

        // --- Avatar ---
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () => context.go('/profile'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Center(
                child: Icon(LucideIcons.user, size: 20, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ============================================
  /// WIDGET : Cartes résumées (revenus, dépenses, épargne)
  /// ============================================
  Widget _buildSummaryCards() {
    return Consumer<TransactionService>(
      builder: (context, service, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              // --- Carte principale : Solde net ---
              _buildMainBalanceCard(service),

              const SizedBox(height: AppSpacing.md),

              // --- Cartes secondaires ---
              Row(
                children: [
                  Expanded(
                    child: _buildMiniCard(
                      title: 'Income',
                      amount: service.totalIncome,
                      icon: LucideIcons.trendingUp,
                      gradient: AppColors.incomeGradient,
                      onTap: () => context.go('/income'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildMiniCard(
                      title: 'Expenses',
                      amount: service.totalExpense,
                      icon: LucideIcons.trendingDown,
                      gradient: AppColors.expenseGradient,
                      onTap: () => context.go('/expense'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Carte principale avec le solde
  Widget _buildMainBalanceCard(TransactionService service) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.savingsGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8B5CF6).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.wallet,
                    size: 20,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Net Savings',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.go('/savings'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${Currency.xaf.symbol} ${_formatAmount(service.netSavings)}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                service.savingsRate >= 0
                    ? LucideIcons.trendingUp
                    : LucideIcons.trendingDown,
                size: 16,
                color: service.savingsRate >= 0
                    ? Colors.greenAccent
                    : Colors.redAccent,
              ),
              const SizedBox(width: 4),
              Text(
                '${service.savingsRate.toStringAsFixed(1)}% savings rate',
                style: AppTypography.bodySmall.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Mini carte (revenu ou dépense)
  Widget _buildMiniCard({
    required String title,
    required double amount,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(icon, size: 18, color: Colors.white)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 2),
            Text(
              '${Currency.xaf.symbol} ${_formatAmount(amount)}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET : Section objectifs actifs
  /// ============================================
  Widget _buildActiveGoalsSection() {
    return Consumer<GoalService>(
      builder: (context, goalService, child) {
        final activeGoals = goalService.activeGoals.take(3).toList();

        return Column(
          children: [
            // --- En-tête de section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Goals', style: AppTypography.titleLarge),
                  TextButton(
                    onPressed: () => context.go('/goals'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See All',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // --- Liste des objectifs ---
            if (activeGoals.isEmpty)
              _buildEmptyGoalsPlaceholder()
            else
              ...activeGoals.map((goal) => _buildGoalCard(goal)),
          ],
        );
      },
    );
  }

  Widget _buildGoalCard(GoalModel goal) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: GestureDetector(
        onTap: () => context.go('/goals/${goal.id}'),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Icône de l'objectif
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Color(goal.priority.color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        goal.isEmergencyFund
                            ? LucideIcons.shield
                            : LucideIcons.target,
                        size: 22,
                        color: Color(goal.priority.color),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Info de l'objectif
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.title, style: AppTypography.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatAmount(goal.currentAmount)} / ${_formatAmount(goal.targetAmount)} FCFA',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pourcentage
                  Text(
                    '${(goal.progressPercent * 100).toStringAsFixed(0)}%',
                    style: AppTypography.titleMedium.copyWith(
                      color: Color(goal.priority.color),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Barre de progression
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.progressPercent,
                  backgroundColor: AppColors.border,
                  color: Color(goal.priority.color),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Jours restants
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    goal.daysRemaining > 0
                        ? '${goal.daysRemaining} days remaining'
                        : goal.isAchieved
                        ? 'Achieved!'
                        : 'Overdue',
                    style: AppTypography.bodySmall.copyWith(
                      color: goal.isOverdue
                          ? AppColors.error
                          : AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    '${_formatAmount(goal.requiredDailySaving)} FCFA/day needed',
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

  Widget _buildEmptyGoalsPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(
              LucideIcons.target,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('No active goals yet', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create your first savings goal to start tracking',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () => context.go('/goals/add'),
              child: const Text('Create Goal'),
            ),
          ],
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET : Section transactions récentes
  /// ============================================
  Widget _buildRecentTransactionsSection() {
    return Consumer<TransactionService>(
      builder: (context, service, child) {
        final transactions = service.recentTransactions.take(5).toList();

        return Column(
          children: [
            // En-tête
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: AppTypography.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.go('/reports'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Liste des transactions
            if (transactions.isEmpty)
              _buildEmptyTransactionsPlaceholder()
            else
              ...transactions.map((tx) => _buildTransactionTile(tx)),
          ],
        );
      },
    );
  }

  Widget _buildTransactionTile(TransactionModel tx) {
    final isIncome = tx.type == TransactionType.income;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Icône de catégorie
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Color(
                  tx.categoryColor ?? 0xFF64748B,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  isIncome
                      ? LucideIcons.arrowDownLeft
                      : LucideIcons.arrowUpRight,
                  size: 22,
                  color: Color(tx.categoryColor ?? 0xFF64748B),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Info transaction
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.categoryName, style: AppTypography.titleMedium),
                  if (tx.note != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      tx.note!,
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

            // Montant
            Text(
              '${isIncome ? '+' : '-'}${_formatAmount(tx.amount)}',
              style: AppTypography.titleMedium.copyWith(
                color: isIncome ? AppColors.income : AppColors.expense,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTransactionsPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(LucideIcons.receipt, size: 48, color: AppColors.textTertiary),
            SizedBox(height: AppSpacing.md),
            Text('No transactions yet', style: AppTypography.titleMedium),
          ],
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET : Bottom Sheet - Ajouter transaction
  /// ============================================
  void _showAddTransactionSheet(BuildContext context) {
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
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            const Text('Add Transaction', style: AppTypography.headlineMedium),

            const SizedBox(height: AppSpacing.xl),

            // --- Option : Revenu ---
            _buildAddOption(
              icon: LucideIcons.trendingUp,
              title: 'Income',
              subtitle: 'Add a new income record',
              gradient: AppColors.incomeGradient,
              onTap: () {
                Navigator.pop(context);
                context.go('/income/add');
              },
            ),

            const SizedBox(height: AppSpacing.md),

            // --- Option : Dépense ---
            _buildAddOption(
              icon: LucideIcons.trendingDown,
              title: 'Expense',
              subtitle: 'Record a new expense',
              gradient: AppColors.expenseGradient,
              onTap: () {
                Navigator.pop(context);
                context.go('/expense/add');
              },
            ),

            const SizedBox(height: AppSpacing.md),

            // --- Option : Note vocale ---
            _buildAddOption(
              icon: LucideIcons.mic,
              title: 'Voice Note',
              subtitle: 'Record a voice note first',
              gradient: AppColors.savingsGradient,
              onTap: () {
                Navigator.pop(context);
                context.go('/voice-recording');
              },
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, size: 24, color: Colors.white)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  /// Formater un montant avec séparateur de milliers
  String _formatAmount(double amount) {
    return amount
        .abs()
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }
}
