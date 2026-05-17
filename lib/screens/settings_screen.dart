import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import "app_theme.dart";
import "constants.dart";

/// ============================================
/// SETTINGS SCREEN — Paramètres de l'application
/// ============================================
/// 🎯 Ce que fait cet écran :
/// 1. Apparence : Thème (Clair/Sombre/Système), Langue
/// 2. Préférences : Devise par défaut, Format de date
/// 3. Notifications : Rappels, Alertes, Réalisations
/// 4. Données : Synchroniser, Exporter, Vider le cache
/// 5. Compte : Changer le mot de passe, Supprimer le compte
/// 6. À propos : Version, CGU, Politique de confidentialité
///
/// 🎨 Chaque élément a une icône Lucide, un label et un
/// widget de fin (switch, dropdown, chevron)
///
/// 📦 Pas de Provider requis — les préférences sont gérées
/// localement via setState (peut être migré vers un
/// SettingsService plus tard)
/// ============================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- État des paramètres ---
  ThemeMode _themeMode = ThemeMode.system;
  AppLanguage _language = AppLanguage.english;
  Currency _currency = Currency.xaf;
  String _dateFormat = 'dd/MM/yyyy';

  // --- État des notifications ---
  bool _remindersEnabled = true;
  bool _alertsEnabled = true;
  bool _achievementsEnabled = true;

  // --- État des actions ---
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section : Apparence ---
            _buildSectionHeader(icon: LucideIcons.palette, title: 'Appearance'),
            _buildSettingsGroup([
              _buildDropdownItem<ThemeMode>(
                icon: LucideIcons.sunMoon,
                label: 'Theme',
                value: _themeMode,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _themeMode = value);
                    // TODO: Appliquer le thème via un ThemeService
                  }
                },
              ),
              _buildDivider(),
              _buildDropdownItem<AppLanguage>(
                icon: LucideIcons.globe,
                label: 'Language',
                value: _language,
                items: AppLanguage.values
                    .map(
                      (lang) => DropdownMenuItem(
                        value: lang,
                        child: Text('${lang.nativeName} (${lang.name})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _language = value);
                  }
                },
              ),
            ]),

            // --- Section : Préférences ---
            _buildSectionHeader(
              icon: LucideIcons.slidersHorizontal,
              title: 'Preferences',
            ),
            _buildSettingsGroup([
              _buildDropdownItem<Currency>(
                icon: LucideIcons.coins,
                label: 'Default Currency',
                value: _currency,
                items: Currency.values
                    .map(
                      (curr) => DropdownMenuItem(
                        value: curr,
                        child: Text('${curr.symbol} — ${curr.name}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _currency = value);
                  }
                },
              ),
              _buildDivider(),
              _buildDropdownItem<String>(
                icon: LucideIcons.calendar,
                label: 'Date Format',
                value: _dateFormat,
                items: const [
                  DropdownMenuItem(
                    value: 'dd/MM/yyyy',
                    child: Text('DD/MM/YYYY'),
                  ),
                  DropdownMenuItem(
                    value: 'MM/dd/yyyy',
                    child: Text('MM/DD/YYYY'),
                  ),
                  DropdownMenuItem(
                    value: 'yyyy-MM-dd',
                    child: Text('YYYY-MM-DD'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _dateFormat = value);
                  }
                },
              ),
            ]),

            // --- Section : Notifications ---
            _buildSectionHeader(icon: LucideIcons.bell, title: 'Notifications'),
            _buildSettingsGroup([
              _buildSwitchItem(
                icon: LucideIcons.alarmClock,
                label: 'Savings Reminders',
                subtitle: 'Get reminded to save regularly',
                value: _remindersEnabled,
                onChanged: (value) {
                  setState(() => _remindersEnabled = value);
                },
              ),
              _buildDivider(),
              _buildSwitchItem(
                icon: LucideIcons.alertTriangle,
                label: 'Budget Alerts',
                subtitle: 'Alert when exceeding budget limits',
                value: _alertsEnabled,
                onChanged: (value) {
                  setState(() => _alertsEnabled = value);
                },
              ),
              _buildDivider(),
              _buildSwitchItem(
                icon: LucideIcons.trophy,
                label: 'Achievements',
                subtitle: 'Celebrate milestones and goals',
                value: _achievementsEnabled,
                onChanged: (value) {
                  setState(() => _achievementsEnabled = value);
                },
              ),
            ]),

            // --- Section : Données ---
            _buildSectionHeader(icon: LucideIcons.database, title: 'Data'),
            _buildSettingsGroup([
              _buildActionItem(
                icon: LucideIcons.refreshCw,
                label: 'Sync Now',
                subtitle: _isSyncing ? 'Syncing...' : 'Last synced just now',
                trailing: _isSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(
                        LucideIcons.chevronRight,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                onTap: _syncNow,
              ),
              _buildDivider(),
              _buildActionItem(
                icon: LucideIcons.download,
                label: 'Export All Data',
                subtitle: 'Download your data as CSV or PDF',
                onTap: () {
                  // TODO: Implémenter l'exportation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Export feature coming soon!'),
                      backgroundColor: AppColors.info,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildActionItem(
                icon: LucideIcons.trash2,
                label: 'Clear Cache',
                subtitle: 'Free up storage space',
                color: AppColors.warning,
                onTap: _showClearCacheConfirmation,
              ),
            ]),

            // --- Section : Compte ---
            _buildSectionHeader(icon: LucideIcons.shield, title: 'Account'),
            _buildSettingsGroup([
              _buildActionItem(
                icon: LucideIcons.keyRound,
                label: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () {
                  // TODO: Navigation vers l'écran de changement de mot de passe
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Password change coming soon!'),
                      backgroundColor: AppColors.info,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildActionItem(
                icon: LucideIcons.userX,
                label: 'Delete Account',
                subtitle: 'Permanently delete your account and data',
                color: AppColors.error,
                onTap: _showDeleteAccountConfirmation,
              ),
            ]),

            // --- Section : À propos ---
            _buildSectionHeader(icon: LucideIcons.info, title: 'About'),
            _buildSettingsGroup([
              _buildActionItem(
                icon: LucideIcons.smartphone,
                label: 'App Version',
                subtitle: '${AppConstants.appName} v${AppConstants.appVersion}',
                showChevron: false,
                onTap: () {},
              ),
              _buildDivider(),
              _buildActionItem(
                icon: LucideIcons.fileText,
                label: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                onTap: () {
                  // TODO: Ouvrir les CGU dans un navigateur
                },
              ),
              _buildDivider(),
              _buildActionItem(
                icon: LucideIcons.lock,
                label: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: () {
                  // TODO: Ouvrir la politique de confidentialité
                },
              ),
            ]),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET : En-tête de section
  /// ============================================
  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// WIDGET : Groupe de paramètres avec fond et bordure
  /// ============================================
  Widget _buildSettingsGroup(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: children),
      ),
    );
  }

  /// ============================================
  /// WIDGET : Élément de paramètre avec dropdown
  /// ============================================
  Widget _buildDropdownItem<T>({
    required IconData icon,
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Icône
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Label
          Expanded(
            child: Text(
              label,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Dropdown
          DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            underline: const SizedBox.shrink(),
            isDense: true,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            icon: const Icon(
              LucideIcons.chevronDown,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// WIDGET : Élément de paramètre avec switch
  /// ============================================
  Widget _buildSwitchItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Icône
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Label et sous-titre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Switch
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// WIDGET : Élément de paramètre avec action
  /// ============================================
  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    Color color = AppColors.primary,
    Widget? trailing,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(icon, size: 18, color: color)),
            ),
            const SizedBox(width: AppSpacing.md),

            // Label et sous-titre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Widget de fin (chevron ou personnalisé)
            if (trailing != null)
              trailing
            else if (showChevron)
              const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }

  /// Séparateur entre les éléments
  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Divider(height: 1),
    );
  }

  /// ============================================
  /// ACTION : Synchroniser les données
  /// ============================================
  Future<void> _syncNow() async {
    setState(() => _isSyncing = true);

    // Simuler une synchronisation
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSyncing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Data synced successfully!'),
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
  /// ACTION : Confirmation de vidage du cache
  /// ============================================
  void _showClearCacheConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Row(
          children: [
            const Icon(LucideIcons.trash2, size: 22, color: AppColors.warning),
            const SizedBox(width: AppSpacing.sm),
            const Text('Clear Cache', style: AppTypography.titleLarge),
          ],
        ),
        content: Text(
          'This will clear all cached data. Your transactions and goals will not be affected.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter le vidage du cache
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cache cleared successfully!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// ACTION : Confirmation de suppression de compte
  /// ============================================
  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Row(
          children: [
            const Icon(
              LucideIcons.alertTriangle,
              size: 22,
              color: AppColors.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('Delete Account', style: AppTypography.titleLarge),
          ],
        ),
        content: Text(
          'This action is irreversible. All your data including transactions, goals, and settings will be permanently deleted.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter la suppression de compte
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Account deletion requested.'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
