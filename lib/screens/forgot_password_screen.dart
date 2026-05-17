import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import "app_theme.dart";
import "auth_service.dart";

/// ============================================
/// FORGOT PASSWORD SCREEN — Mot de passe oublié
/// ============================================
/// 🎯 Ce que fait cet écran :
/// 1. Permet à l'utilisateur de saisir son email
/// 2. Envoie un lien de réinitialisation par email
/// 3. Affiche un message de confirmation
/// 4. Redirige vers le Login après succès
///
/// 💡 Design :
/// → Illustration en haut (cadenas + email)
/// → Champ email unique (simple et rapide)
/// → Bouton d'envoi avec loading state
/// → Message de succès avec animation
/// ============================================

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Envoyer le lien de réinitialisation
  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.resetPassword(
      _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() => _emailSent = true);
    } else if (authService.error != null) {
      _showErrorSnackBar(authService.error!);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.alertCircle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _emailSent ? _buildSuccessView() : _buildFormView(authService),
        ),
      ),
    );
  }

  /// ============================================
  /// VUE : Formulaire de réinitialisation
  /// ============================================
  Widget _buildFormView(AuthService authService) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),

          // --- Bouton retour ---
          _buildBackButton(),

          const SizedBox(height: AppSpacing.xxl),

          // --- Illustration ---
          _buildIllustration(),

          const SizedBox(height: AppSpacing.xl),

          // --- Titre ---
          const Text('Forgot Password?', style: AppTypography.headlineLarge),

          const SizedBox(height: AppSpacing.sm),

          Text(
            "Don't worry! It happens to the best of us. Enter your email and we'll send you a reset link.",
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // --- Champ Email ---
          _buildEmailField(),

          const SizedBox(height: AppSpacing.xl),

          // --- Bouton Envoyer ---
          _buildResetButton(authService),

          const SizedBox(height: AppSpacing.xl),

          // --- Lien retour ---
          _buildBackToLoginLink(),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  /// ============================================
  /// VUE : Confirmation d'envoi
  /// ============================================
  Widget _buildSuccessView() {
    return Column(
      children: [
        const SizedBox(height: 80),

        // --- Icône de succès ---
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              LucideIcons.mailCheck,
              size: 48,
              color: AppColors.primary,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // --- Titre ---
        const Text(
          'Email Sent!',
          style: AppTypography.headlineLarge,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.md),

        // --- Description ---
        Text(
          'We\'ve sent a password reset link to\n${_emailController.text}',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xxl),

        // --- Bouton retour ---
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: const Text(
              'Back to Sign In',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // --- Renvoyer ---
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: Text(
            'Didn\'t receive the email? Resend',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => context.go('/login'),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(
          LucideIcons.arrowLeft,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(LucideIcons.keyRound, size: 52, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleResetPassword(),
          decoration: const InputDecoration(
            hintText: 'Enter your email address',
            prefixIcon: Padding(
              padding: EdgeInsets.all(14.0),
              child: Icon(
                LucideIcons.mail,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            if (!value.contains('@') || !value.contains('.')) {
              return 'Enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildResetButton(AuthService authService) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: authService.isLoading ? null : _handleResetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: authService.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Send Reset Link',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildBackToLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          LucideIcons.arrowLeft,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: () => context.go('/login'),
          child: Text(
            'Back to Sign In',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
