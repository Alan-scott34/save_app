import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'achievement_service.dart';

/// ============================================
/// ACHIEVEMENTS SCREEN — Écran des accomplissements
/// ============================================
/// 🏆 Affiche :
/// 1. Nombre total d'accomplissements
/// 2. Accomplissements récents
/// 3. Tous les accomplissements par type
/// 4. Possibilité d'ajouter des accomplissements manuels
/// ============================================

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  AchievementType _selectedType = AchievementType.customMilestone;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Achievements'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 22),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, size: 22),
            onPressed: () => _showAddAchievementDialog(),
          ),
        ],
      ),
      body: Consumer<AchievementService>(
        builder: (context, achievementService, child) {
          if (achievementService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (achievementService.achievements.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Stats ---
                  _buildStatsSection(achievementService),

                  const SizedBox(height: AppSpacing.lg),

                  // --- Accomplissements récents ---
                  _buildRecentAchievementsSection(achievementService),

                  const SizedBox(height: AppSpacing.lg),

                  // --- Tous les accomplissements ---
                  _buildAllAchievementsSection(achievementService),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ============================================
  /// WIDGET : État vide
  /// ============================================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.trophy,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Achievements Yet',
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Reach your goals and earn achievements!',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET : Section stats
  /// ============================================
  Widget _buildStatsSection(AchievementService service) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '${service.totalCount}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text('Total', style: TextStyle(color: Colors.white70)),
            ],
          ),
          Column(
            children: [
              Text(
                '${service.recentAchievements.length}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text('Recent', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// WIDGET : Accomplissements récents
  /// ============================================
  Widget _buildRecentAchievementsSection(AchievementService service) {
    if (service.recentAchievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent (30 days)',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...service.recentAchievements
            .take(3)
            .map((achievement) => _buildAchievementCard(achievement)),
      ],
    );
  }

  /// ============================================
  /// WIDGET : Tous les accomplissements
  /// ============================================
  Widget _buildAllAchievementsSection(AchievementService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Achievements',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...service.achievements.map(
          (achievement) => _buildAchievementCard(achievement),
        ),
      ],
    );
  }

  /// ============================================
  /// WIDGET : Carte d'accomplissement
  /// ============================================
  Widget _buildAchievementCard(AchievementModel achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Center(
                  child: Text(
                    achievement.type.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      achievement.type.displayName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (achievement.isNotified)
                const Icon(
                  LucideIcons.check,
                  color: AppColors.success,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            achievement.description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (achievement.targetAmount != null &&
              achievement.currentAmount != null)
            Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: achievement.progress,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      achievement.isCompleted
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${achievement.currentAmount?.toStringAsFixed(0)} / ${achievement.targetAmount?.toStringAsFixed(0)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achieved: ${_formatDate(achievement.achievedAt)}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              if (!achievement.isNotified)
                TextButton.icon(
                  onPressed: () => context
                      .read<AchievementService>()
                      .markAsNotified(achievement.id!),
                  icon: const Icon(LucideIcons.bell, size: 16),
                  label: const Text('Notify'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// DIALOG : Ajouter un accomplissement
  /// ============================================
  void _showAddAchievementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text('New Achievement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Title ---
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // --- Description ---
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),

              // --- Type ---
              DropdownButtonFormField<AchievementType>(
                value: _selectedType,
                items: AchievementType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text('${type.emoji} ${type.displayName}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearForm();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a title')),
                );
                return;
              }

              final achievementService = context.read<AchievementService>();
              await achievementService.addAchievement(
                AchievementModel(
                  id: 'ach_${DateTime.now().millisecondsSinceEpoch}',
                  title: _titleController.text,
                  description: _descriptionController.text,
                  type: _selectedType,
                  achievedAt: DateTime.now(),
                  createdAt: DateTime.now(),
                ),
              );

              if (mounted) {
                Navigator.pop(context);
                _clearForm();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Achievement added!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedType = AchievementType.customMilestone;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
