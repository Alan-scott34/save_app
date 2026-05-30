import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import "app_theme.dart";
import "goal_service.dart";
import "app_models.dart";
import "constants.dart";

/// ============================================
/// GOAL DETAIL SCREEN — Détail d'un objectif d'épargne
/// ============================================

class GoalDetailScreen extends StatefulWidget {
  final String goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final _contributionController = TextEditingController();

  @override
  void dispose() {
    _contributionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalService>(
      builder: (context, goalService, child) {
        final goal = goalService.goals.firstWhere(
          (g) => g.id == widget.goalId,
          orElse: () => GoalModel(
            title: 'Unknown Goal',
            targetAmount: 0,
            deadline: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(goal.title),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.pencil),
                onPressed: () => context.push('/goals/edit/${goal.id}'),
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2),
                onPressed: () => _confirmDelete(goal),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Carte de progression principale ---
                _buildProgressCard(goal),

                const SizedBox(height: AppSpacing.lg),

                // --- Statistiques ---
                _buildStatsGrid(goal),

                const SizedBox(height: AppSpacing.lg),

                // --- Ajouter une contribution ---
                _buildContributionSection(goal),

                const SizedBox(height: AppSpacing.lg),

                // --- Détails de l'objectif ---
                _buildDetailsSection(goal),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressCard(GoalModel goal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(goal.priority.color),
            Color(goal.priority.color).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          // Icône
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                goal.isEmergencyFund ? LucideIcons.shield : LucideIcons.target,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Pourcentage
          Text(
            '${(goal.progressPercent * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Montant
          Text(
            '${Currency.xaf.symbol} ${_formatAmount(goal.currentAmount)} of ${Currency.xaf.symbol} ${_formatAmount(goal.targetAmount)}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: goal.progressPercent,
              backgroundColor: Colors.white24,
              color: Colors.white,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(GoalModel goal) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: LucideIcons.wallet,
            label: 'Remaining',
            value:
                '${Currency.xaf.symbol} ${_formatAmount(goal.remainingAmount)}',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            icon: LucideIcons.clock,
            label: 'Days Left',
            value: goal.daysRemaining > 0 ? '${goal.daysRemaining}' : 'Overdue',
            color: goal.isOverdue ? AppColors.error : AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionSection(GoalModel goal) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Contribution', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _contributionController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Amount',
                    prefixText: '${Currency.xaf.symbol} ',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_contributionController.text);
                  if (amount != null && amount > 0 && goal.id != null) {
                    Provider.of<GoalService>(
                      context,
                      listen: false,
                    ).addToGoal(goal.id!, amount);
                    _contributionController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contribution added!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: const Icon(
                  LucideIcons.plus,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Daily saving rate needed: ${Currency.xaf.symbol} ${_formatAmount(goal.requiredDailySaving)}/day',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(GoalModel goal) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Details', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow(LucideIcons.flag, 'Priority', goal.priority.label),
          _buildDetailRow(
            LucideIcons.calendarClock,
            'Deadline',
            _formatDate(goal.deadline),
          ),
          _buildDetailRow(
            LucideIcons.shield,
            'Emergency Fund',
            goal.isEmergencyFund ? 'Yes' : 'No',
          ),
          _buildDetailRow(
            LucideIcons.calendar,
            'Created',
            _formatDate(goal.createdAt),
          ),
          if (goal.description != null) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Description',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(goal.description!, style: AppTypography.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(GoalModel goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (goal.id != null) {
                Provider.of<GoalService>(
                  context,
                  listen: false,
                ).deleteGoal(goal.id!);
              }
              Navigator.pop(context);
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount
        .abs()
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
