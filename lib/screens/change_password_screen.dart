import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'auth_service.dart';

/// ============================================
/// CHANGE PASSWORD SCREEN
/// ============================================
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final authService = context.read<AuthService>();
    final success = await authService.changePassword(
      _currentController.text,
      _newController.text,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.error ?? 'Failed to change password'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      authService.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Change Password'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.info,
                        size: 18, color: AppColors.info),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Use at least 6 characters including letters and numbers.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              _buildLabel('Current Password'),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _currentController,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  hintText: 'Enter current password',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Icon(LucideIcons.lock,
                        size: 20, color: AppColors.textTertiary),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Current password is required'
                    : null,
              ),

              const SizedBox(height: AppSpacing.lg),

              _buildLabel('New Password'),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _newController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  hintText: 'Enter new password',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Icon(LucideIcons.keyRound,
                        size: 20, color: AppColors.textTertiary),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'New password is required';
                  if (v.length < 6) return 'At least 6 characters required';
                  if (v == _currentController.text) {
                    return 'New password must differ from current';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              _buildLabel('Confirm New Password'),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Re-enter new password',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Icon(LucideIcons.checkCircle,
                        size: 20, color: AppColors.textTertiary),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please confirm your password';
                  if (v != _newController.text) return 'Passwords do not match';
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.xxl),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update Password',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
    );
  }
}
