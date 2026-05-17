// ================= FIX FOR PROFILE SCREEN =================
//
// Main issue:
// The import below is not used and may also cause conflicts:
//
// import "app_models.dart";
//
// Remove it if you are not using any model directly in this file.
//
// Also, AuthService.user is likely returning Map<String, dynamic>?.
// The code below safely extracts values.
//
// =========================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'auth_service.dart';
import 'transaction_service.dart';
import 'goal_service.dart';
import 'constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionService>().loadTransactions();
      context.read<GoalService>().loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: AppSpacing.lg),
            _buildStatsCards(),
            const SizedBox(height: AppSpacing.lg),
            _buildMenuSection(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // PROFILE HEADER
  // ======================================================
  Widget _buildProfileHeader() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.user;

        final String fullName = user?['fullName']?.toString() ?? 'John Doe';
        final String email = user?['email']?.toString() ?? 'john@example.com';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: AppSpacing.xxl,
            bottom: AppSpacing.lg,
            left: AppSpacing.md,
            right: AppSpacing.md,
          ),
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppSpacing.radiusXl),
              bottomRight: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(fullName),
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Avatar edit coming soon!'),
                            backgroundColor: AppColors.info,
                          ),
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.camera,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              Text(
                fullName,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.mail, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    email,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      size: 12,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Member since 2024',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ======================================================
  // STATS CARDS
  // ======================================================
  Widget _buildStatsCards() {
    return Consumer2<TransactionService, GoalService>(
      builder: (context, txService, goalService, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard(
                title: 'Total Income',
                value:
                    '${Currency.xaf.symbol} ${_formatAmount(txService.totalIncome)}',
                icon: LucideIcons.trendingUp,
                color: AppColors.income,
              ),
              _buildStatCard(
                title: 'Total Expenses',
                value:
                    '${Currency.xaf.symbol} ${_formatAmount(txService.totalExpense)}',
                icon: LucideIcons.trendingDown,
                color: AppColors.expense,
              ),
              _buildStatCard(
                title: 'Net Savings',
                value:
                    '${Currency.xaf.symbol} ${_formatAmount(txService.netSavings)}',
                icon: LucideIcons.wallet,
                color: AppColors.savings,
              ),
              _buildStatCard(
                title: 'Active Goals',
                value: goalService.activeGoals.length.toString(),
                icon: LucideIcons.target,
                color: AppColors.warning,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, size: 18, color: color)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ======================================================
  // MENU SECTION
  // ======================================================
  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            _buildMenuItem(
              icon: LucideIcons.settings,
              label: 'Settings',
              subtitle: 'App preferences',
              onTap: () => context.go('/settings'),
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: LucideIcons.piggyBank,
              label: 'Savings Tracker',
              subtitle: 'Monitor savings',
              onTap: () => context.go('/savings'),
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: LucideIcons.barChart3,
              label: 'Reports',
              subtitle: 'Financial reports',
              onTap: () => context.go('/reports'),
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: LucideIcons.logOut,
              label: 'Logout',
              subtitle: 'Sign out',
              color: AppColors.error,
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    Color color = AppColors.textPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return const Divider(height: 1);
  }

  // ======================================================
  // LOGOUT
  // ======================================================
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthService>().logout();

              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // HELPERS
  // ======================================================
  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }

    return '?';
  }

  String _formatAmount(double amount) {
    return amount
        .abs()
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }
}
